--[[
 /$$$$$$$                      /$$            /$$
| $$__  $$                    |__/           | $$
| $$  \ $$  /$$$$$$   /$$$$$$  /$$  /$$$$$$$/$$$$$$    /$$$$$$  /$$   /$$
| $$$$$$$/ /$$__  $$ /$$__  $$| $$ /$$_____/_  $$_/   /$$__  $$| $$  | $$
| $$__  $$| $$$$$$$$| $$  \ $$| $$|  $$$$$$  | $$    | $$  \__/| $$  | $$
| $$  \ $$| $$_____/| $$  | $$| $$ \____  $$ | $$ /$$| $$      | $$  | $$
| $$  | $$|  $$$$$$$|  $$$$$$$| $$ /$$$$$$$/ |  $$$$/| $$      |  $$$$$$$
|__/  |__/ \_______/ \____  $$|__/|_______/   \___/  |__/       \____  $$
                     /$$  \ $$                                  /$$  | $$
                    |  $$$$$$/                                 |  $$$$$$/
                     \______/                                   \______/

Registry is a component used to manage packages and scripts embedded
into the CUSTOM_UI core addon.

It's main purpose is to keep all methods and logic needed to properly keep
core add-ins functioning outside of the core object.
--]]

--[[ LOCALIZED GLOBALS ]]--
--GLOBAL NAMESPACE
local _G = getfenv(0);
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local floor         = math.floor
--TABLE
local table         = _G.table;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local wipe          = _G.wipe;

local date          = _G.date;

--BLIZZARD API
local ReloadUI              = _G.ReloadUI;
local GetLocale             = _G.GetLocale;
local CreateFrame           = _G.CreateFrame;
local IsAddOnLoaded         = _G.IsAddOnLoaded;
local GetNumAddOns          = _G.GetNumAddOns;
local GetAddOnInfo          = _G.GetAddOnInfo;
local IsLoggedIn            = _G.IsLoggedIn;
local LoadAddOn             = _G.LoadAddOn;
local EnableAddOn           = _G.EnableAddOn;
local DisableAddOn          = _G.DisableAddOn;
local GetAddOnMetadata      = _G.GetAddOnMetadata;
local InCombatLockdown      = _G.InCombatLockdown;
local IsAddOnLoadOnDemand   = _G.IsAddOnLoadOnDemand;
local GetSpecialization     = _G.GetSpecialization;
local GetSpecializationInfo = _G.GetSpecializationInfo;
local C_PetBattles          = _G.C_PetBattles;

--[[ LIB CONSTRUCT ]]--

local Librarian = _G.Librarian;
local lib = Librarian:NewLibrary("Registry")

if not lib then return end -- No upgrade needed

--[[ ADDON DATA ]]--

local CoreName, CoreObject  = ...
local SchemaFromMeta        = "X-UI-Schema";
local HeaderFromMeta        = "X-UI-Name";
local ThemeFromMeta         = "X-UI-Theme";
local CoreGlobalName        = GetAddOnMetadata(..., HeaderFromMeta);
local AddonVersion          = GetAddOnMetadata(..., "Version");
local InterfaceVersion      = select(4, GetBuildInfo());

--[[ COMMON LOCAL VARS ]]--

local GLOBAL_FILENAME       = CoreGlobalName.."_Global";
local ERROR_FILENAME        = CoreGlobalName.."_Errors";
local PRIVATE_FILENAME      = CoreGlobalName.."_Private";
local MEDIA_FILENAME        = CoreGlobalName.."_Media";
local PRIVATE_FILENAME      = CoreGlobalName.."_Private";
local GLOBAL_UI, PRIVATE_UI, FILTER_UI, MEDIA_UI, ERROR_UI;
local MODULES, PLUGINS;
local LoadOnDemand, ScriptQueue = {},{};
local DirtyDataList, DirtyMediaList = {},{};
local debugHeader = "|cffFF2F00%s|r [|cff992FFF%s|r]|cffFF2F00:|r";
local debugPattern = '|cffFF2F00%s|r [|cff0affff%s|r]|cffFF2F00:|r @|cffFF0000(|r%s|cffFF0000)|r - %s';

local playerClass           = select(2,UnitClass("player"));
local playerRealm           = GetRealmName();
local playerName            = UnitName("player");
local DEFAULT_PROFILE_KEY   = ("%s - Default"):format(playerName);
--local DEFAULT_PROFILE_KEY   = ("%s [%s] - Default"):format(playerName, playerRealm);
local PROFILE_KEY           = DEFAULT_PROFILE_KEY;
local DEFAULT_THEME_KEY     = "Default";
local THEME_KEY             = DEFAULT_THEME_KEY;
local DATESTAMP             = date("%m_%d_%y");
local DEEP_CLEAN_REQUESTED  = false;

local INFO_FORMAT = "|cffFFFF00%s|r\n        |cff33FF00Version: %s|r |cff0099FFby %s|r";

if GetLocale() == "ruRU" then
    INFO_FORMAT = "|cffFFFF00%s|r\n        |cff33FF00Версия: %s|r |cff0099FFот %s|r";
end

--[[ LIB EVENT LISTENER ]]--

lib.EventManager = CreateFrame("Frame", nil)

--[[ LIB VARS ]]--

lib.CURRENT_SCHEMA = 'GENERAL';

--[[ LIB CONSTRAINTS ]]--

lib.CONSTRAINTS = {
    ["IGNORED"] = {},
    ["PROTECTED"] = {}
}

--[[ COMMON META METHODS ]]--

local rootstring = function(self) return self.NameID end

--DATABASE LOCAL HELPERS

local function copydefaults(d, s)
    if(type(s) ~= "table") then return end
    if(type(d) ~= "table") then return end
    for k, v in pairs(s) do
        local saved = rawget(d, k)
        if type(v) == "table" then
            if not saved then rawset(d, k, {}) end
            copydefaults(d[k], v)
        else
            rawset(d, k, v)
        end
    end
end

local function tablecopy(d, s, debug)
    if(debug) then
        print(debug)
        assert(type(s) == "table", "tablecopy ERROR: source (" .. debug .. ") is not a table")
        assert(type(d) == "table", "tablecopy ERROR: destination (" .. debug .. ") is not a table")
    end
    if(type(s) ~= "table") then return end
    if(type(d) ~= "table") then return end
    for k, v in pairs(s) do
        local saved = rawget(d, k)
        if type(v) == "table" then
            if not saved then rawset(d, k, {}) end
            if(debug) then debug = k end
            tablecopy(d[k], v, debug)
        elseif(saved == nil or (saved and type(saved) ~= type(v))) then
            rawset(d, k, v)
        end
    end
end

local function importdata(s, d)
    if type(d) ~= "table" then d = {} end
    if type(s) == "table" then
        for k,v in pairs(s) do
            if type(v) == "table" then
                v = importdata(v, d[k])
            end
            d[k] = v
        end
    end
    return d
end

local function remove_undefined(src, db)
    if(type(src) ~= "table") then return end
    if(type(db) ~= "table") then return end
    for k,v in pairs(db) do
        if src[k] == nil then
            db[k] = nil
        elseif type(v) == "table" and type(src[k]) == "table" then
            remove_undefined(src[k], v)
        end
    end
end

local function remove_defaults(db, src, nometa)
    if(type(src) ~= "table") then
        if(db == src) then db = nil end
        return
    end
    if(not nometa) then
        setmetatable(db, nil)
    end
    for k,v in pairs(src) do
        if type(v) == "table" and type(db[k]) == "table" then
            remove_defaults(db[k], v, nometa)
            if next(db[k]) == nil then
                db[k] = nil
            end
        else
            if db[k] == v then
                db[k] = nil
            end
        end
    end
end

local function sanitize(db, src, double)
    local ignored   = lib.CONSTRAINTS.IGNORED;
    local protected = lib.CONSTRAINTS.PROTECTED;
    if((type(src) == "table")) then
        if(type(db) == "table") then
            for k,v in pairs(db) do
                if(not ignored[k]) then
                    if((src[k] == nil) and (protected[k] == nil)) then
                        db[k] = nil
                    elseif(src[k] ~= nil) then
                        remove_defaults(db[k], src[k])
                        if(double and (protected[k] == nil)) then
                            remove_undefined(src[k], db[k])
                        end
                    end
                end
            end
        end
    end
end

--DATABASE META METHODS
local meta_transdata = {
    __index = function(t, k)
        if(not k or k == "") then return end
        local sv = rawget(t, "data")
        local dv = rawget(t, "defaults")
        local src = dv and dv[k]

        if(src ~= nil) then
            if(type(src) == "table") then
                if(sv[k] == nil or (sv[k] ~= nil and type(sv[k]) ~= "table")) then sv[k] = {} end
                tablecopy(sv[k], src)
            else
                if(sv[k] == nil or (sv[k] ~= nil and type(sv[k]) ~= type(src))) then sv[k] = src end
            end
        end

        rawset(t, k, sv[k])
        return rawget(t, k)
    end,
}

local meta_database = {
    __index = function(t, k)
        if(not k or k == "") then return end
        local sv = rawget(t, "data")
        if(not sv[k]) then sv[k] = {} end
        rawset(t, k, sv[k])
        return rawget(t, k)
    end,
}

--REGISTRY LOCAL HELPERS

local function LoadingProxy(schema, obj)
    if(not obj) then print(schema .. ' not found') return end
    lib.CURRENT_SCHEMA = schema;
    if(not obj.initialized) then
        if(obj.Load and type(obj.Load) == "function") then
            local _, catch = pcall(obj.Load, obj)
            if(catch) then
                CoreObject:HandleError(schema, "Load", catch)
            else
                obj.initialized = true
            end
        end
    else
        if(obj.ReLoad and type(obj.ReLoad) == "function") then
            --print(schema .. ' Reloading')
            local _, catch = pcall(obj.ReLoad, obj)
            if(catch) then
                CoreObject:HandleError(schema, "ReLoad", catch)
            end
        end
    end
    lib.CURRENT_SCHEMA = 'GENERAL';
end

local function OptionsProxy(schema, obj)
    if(not obj) then return end
    if(not obj.optionsLoaded) then
        if(obj.LoadOptions and type(obj.LoadOptions) == "function") then
            local _, catch = pcall(obj.LoadOptions, obj)
            if(catch) then
                CoreObject:HandleError(schema, "LoadOptions", catch)
            else
                obj.optionsLoaded = true
            end
        end
    end
end

--OBJECT INTERNALS

local changeDBVar = function(self, value, key, sub1, sub2, sub3)
    local db = CoreObject.db[self.Schema]
    if((sub1 and sub2 and sub3) and (db[sub1] and db[sub1][sub2] and db[sub1][sub2][sub3])) then
        db[sub1][sub2][sub3][key] = value
    elseif((sub1 and sub2) and (db[sub1] and db[sub1][sub2])) then
        db[sub1][sub2][key] = value
    elseif(sub1 and db[sub1]) then
        db[sub1][key] = value
    else
        db[key] = value
    end

    if(self.UpdateLocals) then
        self:UpdateLocals()
    end
end

local innerOnEvent = function(self, event, ...)
    local obj = self.___owner
    local fn = self[event]
    if(fn and type(fn) == "function" and obj.initialized) then
        local _, catch = pcall(fn, obj, event, ...)
        if(catch) then
            local schema = obj.Schema
            CoreObject:HandleError(schema, event, catch)
        end
    end
end

local registerEvent = function(self, eventname, eventfunc)
    if not self.___eventframe then
        self.___eventframe = CreateFrame("Frame", nil)
        self.___eventframe.___owner = self
        self.___eventframe:SetScript("OnEvent", innerOnEvent)
    end

    if(not self.___eventframe[eventname]) then
        local fn = eventfunc
        if(type(eventfunc) == "string") then
            fn = self[eventfunc]
        elseif(not fn and self[eventname]) then
            fn = self[eventname]
        end
        self.___eventframe[eventname] = fn
    end

    self.___eventframe:RegisterEvent(eventname)
end

local unregisterEvent = function(self, event, ...)
    if(self.___eventframe) then
        self.___eventframe:UnregisterEvent(event)
    end
end

local innerOnUpdate = function(self, elapsed)
    if self.elapsed and self.elapsed > (self.throttle) then
        local obj = self.___owner
        local callbacks = self.callbacks

        for name, fn in pairs(callbacks) do
            local _, catch = pcall(fn, obj)
            if(catch and CoreObject.Debugging) then
                local schema = obj.Schema
                CoreObject:HandleError(schema, "OnUpdate", catch)
            end
        end

        self.elapsed = 0
    else
        self.elapsed = (self.elapsed or 0) + elapsed
    end
end

local registerUpdate = function(self, updatefunc, throttle)
    if not self.___updateframe then
        self.___updateframe = CreateFrame("Frame", nil);
        self.___updateframe.___owner = self;
        self.___updateframe.callbacks = {};
        self.___updateframe.elapsed = 0;
        self.___updateframe.throttle = throttle or 0.2;
    end

    if(updatefunc and type(updatefunc) == "string" and self[updatefunc]) then
        self.___updateframe.callbacks[updatefunc] = self[updatefunc]
    end

    self.___updateframe:SetScript("OnUpdate", innerOnUpdate)
end

local unregisterUpdate = function(self, updatefunc)
    if(updatefunc and type(updatefunc) == "string" and self.___updateframe.callbacks[updatefunc]) then
        self.___updateframe.callbacks[updatefunc] = nil
        if(#self.___updateframe.callbacks == 0) then
            self.___updateframe:SetScript("OnUpdate", nil)
        end
    else
        self.___updateframe:SetScript("OnUpdate", nil)
    end
end

local function SetPluginString(addonName)
    local author = GetAddOnMetadata(addonName, "Author") or "Unknown"
    local name = GetAddOnMetadata(addonName, "Title") or addonName
    local version = GetAddOnMetadata(addonName, "Version") or "???"
    return INFO_FORMAT:format(name, version, author)
end

--REGISTRY PUBLIC METHODS

function lib:RefreshModule(schema)
    local obj = CoreObject[schema]
    LoadingProxy(schema, obj)
end

function lib:RefreshPlugin(schema)
    local obj = _G[schema]
    LoadingProxy(schema, obj)
end

function lib:RefreshAll()
    if(MODULES) then
        for i=1, #MODULES do
            local schema = MODULES[i];
            local obj = CoreObject[schema];
            if(obj) then
                LoadingProxy(schema, obj)
            end
        end
    end
    if(PLUGINS) then
        for i=1, #PLUGINS do
            local schema = PLUGINS[i];
            local obj = _G[schema];
            if(obj) then
                LoadingProxy(schema, obj)
            end
        end
    end
end

function lib:LoadModuleOptions()
    if(MODULES) then
        for i=1,#MODULES do
            local schema = MODULES[i]
            local obj = CoreObject[schema]
            if(obj and (not obj.optionsLoaded)) then
                OptionsProxy(schema, obj)
            end
        end
    end
    if(PLUGINS) then
        for i=1, #PLUGINS do
            local schema = PLUGINS[i];
            local obj = _G[schema];
            if(obj and (not obj.optionsLoaded)) then
                OptionsProxy(schema, obj)
            end
        end
    end
end

function lib:LiveUpdate(forced)
    if(forced or PRIVATE_UI.SAFEDATA.NEEDSLIVEUPDATE) then
        if(CoreObject.ReLoad) then
            CoreObject.Timers:ClearAllTimers()
            if(forced) then CoreObject:ReLoad() end
        end
        self:RefreshAll()
        if((not InCombatLockdown()) and (not C_PetBattles.IsInBattle())) then
            PRIVATE_UI.SAFEDATA.NEEDSLIVEUPDATE = false
        end
    end
end

function lib:GetModuletable()
    return MODULES
end

function lib:CleanUpData(deep)
    local defaults = CoreObject.defaults
    local media = CoreObject.Mediadefaults
    if(DEEP_CLEAN_REQUESTED) then
        for key,data in pairs(GLOBAL_UI.profiles) do
            sanitize(data, defaults, true)
        end
        for theme,realms in pairs(MEDIA_UI.profiles) do
            if(CoreObject.AvailableThemes[theme]) then
                for key,data in pairs(MEDIA_UI.profiles[theme]) do
                    if(not GLOBAL_UI.profileKeys[key]) then
                        MEDIA_UI.profiles[theme][key] = nil
                    else
                        sanitize(data, media)
                    end
                end
            end
        end
    elseif(not deep) then
        for key,data in pairs(GLOBAL_UI.profiles) do
            local linked = DirtyDataList[key]
            if(linked) then
                sanitize(data, defaults, true)
                sanitize(MEDIA_UI.profiles[linked][key], media)
            end
        end
    else
        DEEP_CLEAN_REQUESTED = true;
    end
end

--[[ CONSTRUCTORS ]]--

local function CheckForDeprecated(oldKey)
  if(GLOBAL_UI.profiles[oldKey]) then
    local export = GLOBAL_UI.profiles[oldKey];
    local saved = GLOBAL_UI.profiles[PROFILE_KEY];
    tablecopy(saved, export);
    GLOBAL_UI.profiles[oldKey] = nil
  end

  if(MEDIA_UI.profiles[THEME_KEY][oldKey]) then
    local export = MEDIA_UI.profiles[THEME_KEY][oldKey];
    local saved = MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY];
    tablecopy(saved, export);
    MEDIA_UI.profiles[THEME_KEY][oldKey] = nil
  end
end

-- local function GenerateProfileKey(key)
--     local safeKey = key or PRIVATE_UI.SAFEDATA.CurrentProfile;
--     key = safeKey or "Default";
--     if(key and key:find(playerName)) then
--         safeKey = safeKey or ("%s - %s"):format(playerName, "Default");
--         if(not GLOBAL_UI.profileRealms[safeKey]) then
--             GLOBAL_UI.profileRealms[safeKey] = playerRealm;
--         elseif(GLOBAL_UI.profileRealms[safeKey] ~= playerRealm) then
--             if(not safeKey:find(playerRealm)) then
--               safeKey = ("%s [%s] - %s"):format(playerName, playerRealm, "Default");
--             end
--             GLOBAL_UI.profileRealms[safeKey] = playerRealm;
--         end
--     end

--     PRIVATE_UI.SAFEDATA.CurrentProfile = safeKey
--     return safeKey
-- end

local function GenerateProfileKey(key)
    local safeKey = key;
    if(not safeKey) then
        safeKey = PRIVATE_UI.SAFEDATA.CurrentProfile or ("%s - %s"):format(playerName, "Default");
    end
    key = key or "Default";
    if(not GLOBAL_UI.profileRealms[safeKey]) then
        GLOBAL_UI.profileRealms[safeKey] = playerRealm;
    elseif(safeKey:find(playerName) and GLOBAL_UI.profileRealms[safeKey] ~= playerRealm) then
        if(key:find(playerName)) then
            safeKey = ("%s [%s] - %s"):format(playerName, playerRealm, "Default");
        else
            safeKey = ("%s [%s] - %s"):format(playerName, playerRealm, key);
        end
        GLOBAL_UI.profileRealms[safeKey] = playerRealm;
    end
    PRIVATE_UI.SAFEDATA.CurrentProfile = safeKey

    return safeKey
end

local function UpdateProfileSources(newKey)
    local SOURCE_KEY = newKey;
    local PREVIOUS_PROFILE_KEY = PROFILE_KEY;
    if(PRIVATE_UI.SAFEDATA.DUALSPEC) then
        local specID = GetSpecialization();
        if(specID) then
            local _, talentKey, _, _, _, _ = GetSpecializationInfo(specID);
            SOURCE_KEY = talentKey or "Default";
        end
        lib.EventManager:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    else
        lib.EventManager:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    end

    PROFILE_KEY = GenerateProfileKey(SOURCE_KEY)

    if(not GLOBAL_UI.profiles[PROFILE_KEY]) then GLOBAL_UI.profiles[PROFILE_KEY] = {} end
    if(not GLOBAL_UI.profileKeys[PROFILE_KEY]) then
        for k,v in pairs(GLOBAL_UI.profiles) do
            GLOBAL_UI.profileKeys[k] = k
        end
    end

    if(PRIVATE_UI.SAFEDATA.THEME) then
        THEME_KEY = PRIVATE_UI.SAFEDATA.THEME;
    else
        THEME_KEY = DEFAULT_THEME_KEY;
    end
    if(not MEDIA_UI.profiles[THEME_KEY]) then MEDIA_UI.profiles[THEME_KEY] = {} end
    if(not MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY]) then MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY] = {} end

    DirtyDataList[PROFILE_KEY] = THEME_KEY;

    if(not newKey) then
        if((CoreObject.initialized) and (PREVIOUS_PROFILE_KEY ~= PROFILE_KEY)) then
            local db           = setmetatable({}, meta_transdata)
            db.data            = GLOBAL_UI.profiles[PROFILE_KEY]
            db.defaults        = CoreObject.defaults
            if(CoreObject.db) then wipe(CoreObject.db) end
            CoreObject.db      = db

            local media        = setmetatable({}, meta_transdata)
            media.data         = MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY]
            media.defaults     = CoreObject.Mediadefaults
            if(CoreObject.Media) then wipe(CoreObject.Media) end
            CoreObject.Media   = media

            lib:LiveUpdate(true)
        end
    end
end

local function UpdateConstraints()
    for k,v in pairs(PRIVATE_UI.SAFEDATA.SAVED) do
        lib.CONSTRAINTS.PROTECTED[k] = true
    end
end

local function UpdateCoreDatabases()
    UpdateProfileSources()

    local db           = setmetatable({}, meta_transdata)
    db.data            = GLOBAL_UI.profiles[PROFILE_KEY]
    db.defaults        = CoreObject.defaults
    CoreObject.db      = db

    local media        = setmetatable({}, meta_transdata)
    media.data         = MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY]
    media.defaults     = CoreObject.Mediadefaults
    CoreObject.Media   = media

    local private      = setmetatable({}, meta_database)
    private.data       = PRIVATE_UI
    CoreObject.private = private

    CoreObject.ERRORLOG = ERROR_UI.FOUND

    UpdateConstraints()
end

local function CorePreInitialize()
    --PROFILE SAVED VARIABLES
    if not _G[PRIVATE_FILENAME] then _G[PRIVATE_FILENAME] = {} end
    PRIVATE_UI = _G[PRIVATE_FILENAME]
    --PROFILE SAFE VARIABLES
    if(not PRIVATE_UI.SAFEDATA) then PRIVATE_UI.SAFEDATA = {} end
    if(not PRIVATE_UI.SAFEDATA.SAVED) then PRIVATE_UI.SAFEDATA.SAVED = {} end
    if(not PRIVATE_UI.SAFEDATA.THEME) then PRIVATE_UI.SAFEDATA.THEME = DEFAULT_THEME_KEY end
    if(not PRIVATE_UI.SAFEDATA.DUALSPEC) then PRIVATE_UI.SAFEDATA.DUALSPEC = false end
    if(not PRIVATE_UI.SAFEDATA.NEEDSLIVEUPDATE) then PRIVATE_UI.SAFEDATA.NEEDSLIVEUPDATE = false end
    --GLOBAL SAVED VARIABLES
    if(not _G[GLOBAL_FILENAME]) then _G[GLOBAL_FILENAME] = {} end
    GLOBAL_UI = _G[GLOBAL_FILENAME]
    --GLOBAL PROFILE DATA
    if(not GLOBAL_UI.profiles) then GLOBAL_UI.profiles = {} end
    if(not GLOBAL_UI.profiles[PROFILE_KEY]) then GLOBAL_UI.profiles[PROFILE_KEY] = {} end
    if(not GLOBAL_UI.profileRealms) then GLOBAL_UI.profileRealms = {} end
    if(not GLOBAL_UI.profileRealms[PROFILE_KEY]) then GLOBAL_UI.profileRealms[PROFILE_KEY] = playerRealm end
    if(not GLOBAL_UI.SAFEDATA) then GLOBAL_UI.SAFEDATA = {} end
    if(not GLOBAL_UI.SAFEDATA.MasterProfile) then GLOBAL_UI.SAFEDATA.MasterProfile = false; end
    --GLOBAL KEY STORAGE (ALWAYS EMPTY ON LOGIN)
    GLOBAL_UI.profileKeys = {}
    --SAVED ERRORS
    if not _G[ERROR_FILENAME] then _G[ERROR_FILENAME] = {} end
    ERROR_UI = _G[ERROR_FILENAME]
    --ONLY ALLOW TODAYS ERRORS
    if(ERROR_UI.TODAY and ERROR_UI.TODAY ~= DATESTAMP) then
        ERROR_UI.FOUND = {}
    elseif(not ERROR_UI.FOUND) then
        ERROR_UI.FOUND = {}
    end
    --UPDATE THE ERROR DATESTAMP
    ERROR_UI.TODAY = DATESTAMP
    --MEDIA SAVED VARIABLES
    if not _G[MEDIA_FILENAME] then _G[MEDIA_FILENAME] = {} end
    MEDIA_UI = _G[MEDIA_FILENAME]
    --MEDIA PROFILE DATA
    if(not MEDIA_UI.profiles) then MEDIA_UI.profiles = {} end
    if(not MEDIA_UI.profiles[THEME_KEY]) then MEDIA_UI.profiles[THEME_KEY] = {} end
    if(not MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY]) then MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY] = {} end

    --CheckForDeprecated(OLD_PROFILE_KEY);

    THEME_KEY = PRIVATE_UI.SAFEDATA.THEME;

    for i = 1, GetNumAddOns() do
        local addonName, _, _, _, _, reason = GetAddOnInfo(i)

        if(IsAddOnLoadOnDemand(i)) then
            local header = GetAddOnMetadata(i, HeaderFromMeta)
            local schema = GetAddOnMetadata(i, SchemaFromMeta)
            local theme  = GetAddOnMetadata(i, ThemeFromMeta)

            if(header and schema) then
                LoadOnDemand[schema] = addonName;
                if(not PRIVATE_UI.SAFEDATA.SAVED[schema]) then
                    PRIVATE_UI.SAFEDATA.SAVED[schema] = true
                end
                CoreObject.Options.args[schema] = {
                    type = "group",
                    name = header,
                    childGroups = "tree",
                    args = {
                        enable = {
                            order = 1,
                            type = "execute",
                            width = "full",
                            name = function()
                                local nameString = "Disable"
                                if(not IsAddOnLoaded(addonName)) then
                                    nameString = "Enable"
                                end
                                return nameString
                            end,
                            func = function()
                                if(not IsAddOnLoaded(addonName)) then
                                    local loaded, reason = LoadAddOn(addonName)
                                    PRIVATE_UI.SAFEDATA.SAVED[schema] = true
                                    EnableAddOn(addonName)
                                    CoreObject:StaticPopup_Show("RL_CLIENT")
                                else
                                    PRIVATE_UI.SAFEDATA.SAVED[schema] = false
                                    DisableAddOn(addonName)
                                    CoreObject:StaticPopup_Show("RL_CLIENT")
                                end
                            end,
                        }
                    }
                }

                local enabled = PRIVATE_UI.SAFEDATA.SAVED[schema]

                if(enabled) then
                    EnableAddOn(addonName)
                    if(not IsAddOnLoaded(addonName)) then
                        local loaded, reason = LoadAddOn(addonName)
                    end
                else
                    DisableAddOn(addonName)
                end
            elseif(theme) then
                CoreObject.AvailableThemes[theme] = theme;
                if(theme == THEME_KEY) then
                    EnableAddOn(addonName)
                    if(not IsAddOnLoaded(addonName)) then
                        local loaded, reason = LoadAddOn(addonName)
                    end
                else
                    DisableAddOn(addonName)
                end
            end
        end
    end

    UpdateCoreDatabases()
    CoreObject.___preinitialized = true
end

--LIBRARY EVENT HANDLING

local Library_OnEvent = function(self, event, arg, ...)
    if(event == "PLAYER_LOGOUT") then
        -- local key = PRIVATE_UI.SAFEDATA.CurrentProfile
        -- if(key) then
        --     local export, saved
        --     if(not GLOBAL_UI.profiles[key]) then GLOBAL_UI.profiles[key] = {} end;
        --     export = rawget(CoreObject.db, "data");
        --     saved = GLOBAL_UI.profiles[key];
        --     tablecopy(saved, export);
        -- end
        lib:CleanUpData()
    elseif(event == "ADDON_LOADED") then
        if(arg == CoreName) then
            CorePreInitialize()
            if(not CoreObject.___loaded and CoreObject.PreLoad) then
                CoreObject.Timers:ClearAllTimers()
                CoreObject:PreLoad()
                CoreObject.___loaded = true
                self:UnregisterEvent("ADDON_LOADED")
            end
        end
    elseif(event == "PLAYER_LOGIN") then
        if(not CoreObject.initialized and CoreObject.Initialize and IsLoggedIn()) then
            if(CoreObject.LoadTheme) then
                CoreObject:LoadTheme()
            end
            UpdateCoreDatabases()
            CoreObject:Initialize()
            CoreObject.initialized = true
            self:UnregisterEvent("PLAYER_LOGIN")
        end
        PRIVATE_UI.SAFEDATA.NEEDSLIVEUPDATE = C_PetBattles.IsInBattle()
    elseif(event == "ACTIVE_TALENT_GROUP_CHANGED") then
        UpdateProfileSources()
    end
end

-- CORE OBJECT CONSTRUCT

local Core_NewPlugin = function(self, addonName, addonObject, gfile, pfile)
    local version   = GetAddOnMetadata(addonName, "Version")
    local header    = GetAddOnMetadata(addonName, HeaderFromMeta)
    local schema    = GetAddOnMetadata(addonName, SchemaFromMeta)

    if((not schema) or (schema and _G[schema])) then return end

    if(not PLUGINS) then PLUGINS = {} end
    PLUGINS[#PLUGINS+1] = schema

    local lod       = IsAddOnLoadOnDemand(addonName)
    local addonmeta = {}
    local oldmeta   = getmetatable(addonObject)

    if oldmeta then
        for k, v in pairs(oldmeta) do addonmeta[k] = v end
    end

    addonmeta.__tostring = rootstring
    setmetatable( addonObject, addonmeta )

    local infoString = SetPluginString(addonName)

    addonObject.Version             = version
    addonObject.NameID              = addonName
    addonObject.TitleID             = header
    addonObject.Info                = infoString
    addonObject.Schema              = schema
    addonObject.LoD                 = lod
    addonObject.initialized         = false
    addonObject.CombatLocked        = false
    addonObject.ChangeDBVar         = changeDBVar
    addonObject.RegisterEvent       = registerEvent
    addonObject.UnregisterEvent     = unregisterEvent
    addonObject.RegisterUpdate      = registerUpdate
    addonObject.UnregisterUpdate    = unregisterUpdate

    addonObject.public              = addonObject.public or {}
    addonObject.private             = addonObject.private or {}

    addonObject.___svfiles          = {["PUBLIC"] = gfile, ["PRIVATE"] = pfile}

    _G[schema] = addonObject

    return addonObject
end

local Core_NewPackage = function(self, schema, header)
    if(self[schema]) then return end

    if(not MODULES) then MODULES = {} end
    MODULES[#MODULES+1] = schema

    local addonName = ("CUSTOM_UI [%s]"):format(schema)

    local obj = {
        NameID              = addonName,
        TitleID             = header,
        Schema              = schema,
        initialized         = false,
        CombatLocked        = false,
        ChangeDBVar         = changeDBVar,
        RegisterEvent       = registerEvent,
        UnregisterEvent     = unregisterEvent,
        RegisterUpdate      = registerUpdate,
        UnregisterUpdate    = unregisterUpdate
    }

    local addonmeta = {}
    local oldmeta = getmetatable(obj)
    if oldmeta then
        for k, v in pairs(oldmeta) do addonmeta[k] = v end
    end
    addonmeta.__tostring = rootstring
    setmetatable( obj, addonmeta )

    self[schema] = obj

    return self[schema]
end

local Core_NewScript = function(self, fn)
    if(fn and type(fn) == "function") then
        ScriptQueue[#ScriptQueue+1] = fn
    end
end

local Core_NewModule = function(self, addonName, addonObject, gfile, pfile)
    local version   = GetAddOnMetadata(addonName, "Version")
    local header    = GetAddOnMetadata(addonName, HeaderFromMeta)
    local schema    = GetAddOnMetadata(addonName, SchemaFromMeta)

    if(self[schema]) then return end

    if(not MODULES) then MODULES = {} end
    MODULES[#MODULES+1] = schema

    local lod       = IsAddOnLoadOnDemand(addonName)
    local addonmeta = {}
    local oldmeta   = getmetatable(addonObject)

    if oldmeta then
        for k, v in pairs(oldmeta) do addonmeta[k] = v end
    end

    addonmeta.__tostring = rootstring
    setmetatable( addonObject, addonmeta )

    local packageName = ("CUSTOM_UI [%s]"):format(schema)

    addonObject.Version             = version
    addonObject.NameID              = packageName
    addonObject.TitleID             = header
    addonObject.Schema              = schema
    addonObject.LoD                 = lod
    addonObject.initialized         = false
    addonObject.CombatLocked        = false
    addonObject.ChangeDBVar         = changeDBVar
    addonObject.RegisterEvent       = registerEvent
    addonObject.UnregisterEvent     = unregisterEvent
    addonObject.RegisterUpdate      = registerUpdate
    addonObject.UnregisterUpdate    = unregisterUpdate

    addonObject.public              = addonObject.public or {}
    addonObject.private             = addonObject.private or {}

    addonObject.___svfiles          = {["PUBLIC"] = gfile, ["PRIVATE"] = pfile}

    self[schema] = addonObject

    return self[schema]
end

local Core_ResetData = function(self, sub, sub2, sub3)
    local data = self.db
    local sv = rawget(data, "data")
    local src = rawget(data, "defaults")
    local targetData
    if(sub3 and sub2 and sv and sv[sub] and sv[sub][sub2]) then
        targetData = sv[sub][sub2][sub3]
    elseif(sub2 and sv and sv[sub]) then
        targetData = sv[sub][sub2]
    elseif(sub and sv) then
        targetData = sv[sub]
    else
        targetData = sv
    end
    if(targetData) then
        if(type(targetData) == 'table') then
            for k,v in pairs(targetData) do
                targetData[k] = nil
            end
        else
            targetData = nil
        end
    else
        sv = {}
    end
    tablecopy(sv, src)
end

local Core_ResetFilter = function(self, key)
    local data = self.db.Filters
    local sv = rawget(data, "data")
    local src = rawget(data, "defaults")
    local targetData
    if(key and sv[key]) then
        targetData = sv[key]
    else
        targetData = sv
    end
    if(targetData) then
        if(type(targetData) == 'table') then
            for k,v in pairs(targetData) do
                targetData[k] = nil
            end
        else
            targetData = nil
        end
    else
        sv = {}
    end
    tablecopy(sv, src)
end

local Core_HandleError = function(self, schema, action, catch)
    schema = schema or "Lib:Registry"
    action = action or "Unknown Function"
    local timestamp = date("%m/%d/%y %H:%M:%S")
    local err_message = (debugPattern):format(schema, action, timestamp, catch)
    tinsert(self.ERRORLOG, err_message)
    if(self.DebugMode == true) then
        self.HasErrors = true;
        --self:Debugger(err_message)
    end
end

function lib:NewCore(gfile, efile, pfile, mfile)
    --meta assurance
    local mt = {};
    local old = getmetatable(CoreObject);
    if old then
        for k, v in pairs(old) do mt[k] = v end
    end
    mt.__tostring = rootstring;
    setmetatable(CoreObject, mt);

    --database
    GLOBAL_FILENAME     = gfile or GLOBAL_FILENAME
    ERROR_FILENAME      = efile or ERROR_FILENAME
    PRIVATE_FILENAME    = pfile or PRIVATE_FILENAME
    MEDIA_FILENAME      = mfile or MEDIA_FILENAME

    --events
    if(not self.EventManager.Initialized) then
        self.EventManager:RegisterEvent("ADDON_LOADED")
        self.EventManager:RegisterEvent("PLAYER_LOGIN")
        self.EventManager:RegisterEvent("PLAYER_LOGOUT")
        self.EventManager:SetScript("OnEvent", Library_OnEvent)
        self.EventManager.Initialized = true
    end

    --internals
    CoreObject.___errors            = {};

    CoreObject.NameID               = CoreGlobalName;
    CoreObject.Version              = AddonVersion;
    CoreObject.GameVersion          = tonumber(InterfaceVersion);
    CoreObject.DebugMode            = true;
    CoreObject.HasErrors            = false;
    CoreObject.Schema               = GetAddOnMetadata(CoreName, SchemaFromMeta);
    CoreObject.TitleID              = GetAddOnMetadata(CoreName, HeaderFromMeta);

    CoreObject.RegisterEvent        = registerEvent
    CoreObject.UnregisterEvent      = unregisterEvent
    CoreObject.RegisterUpdate       = registerUpdate
    CoreObject.UnregisterUpdate     = unregisterUpdate

    CoreObject.AvailableThemes      = {["Default"] = "Default"};

    CoreObject.NewScript            = Core_NewScript
    CoreObject.NewModule            = Core_NewModule
    CoreObject.NewPackage           = Core_NewPackage
    CoreObject.NewPlugin            = Core_NewPlugin
    CoreObject.ResetData            = Core_ResetData
    CoreObject.ResetFilter          = Core_ResetFilter
    CoreObject.HandleError          = Core_HandleError

    --[[ EMBEDDED LIBS ]]--

    CoreObject.L                    = Librarian("Linguist"):Lang()
    CoreObject.Events               = Librarian("Events")
    CoreObject.Animate              = Librarian("Animate")
    CoreObject.Timers               = Librarian("Timers")
    CoreObject.Sounds               = Librarian("Sounds")
    CoreObject.SpecialFX            = Librarian("SpecialFX")
    CoreObject.Media                = Librarian("Media")
    CoreObject.API                  = Librarian("API")

    -- if(playerName == 'Munglunch') then
    --     CoreObject.DebugMode = true;
    -- end

    --set global
    _G[CoreGlobalName] = CoreObject;

    return _G[CoreGlobalName]
end

-- INITIALIZE AND LAUNCH

function lib:Launch()
    local settings = CoreObject.db;
    CoreObject.Timers:Initialize();

    if MODULES then
        for i=1,#MODULES do
            local halt = false;
            local schema = MODULES[i];
            local obj = CoreObject[schema];
            if(obj and (not obj.initialized)) then
                if(settings[schema] and settings[schema].incompatible) then
                    for addon,_ in pairs(settings[schema].incompatible) do
                        if IsAddOnLoaded(addon) then halt = true end
                    end
                end
                if(not halt) then
                    local files = obj.___svfiles;
                    if(files) then
                        if(not PRIVATE_UI.SAFEDATA.SAVED[schema]) then
                            PRIVATE_UI.SAFEDATA.SAVED[schema] = true
                        end

                        if(files.PRIVATE) then
                            if not _G[files.PRIVATE] then _G[files.PRIVATE] = {} end
                            local private = setmetatable({}, meta_database)
                            private.data = _G[files.PRIVATE]
                            obj.private = private
                        end

                        if(files.PUBLIC) then
                            if not _G[files.PUBLIC] then _G[files.PUBLIC] = {} end
                            local public = setmetatable({}, meta_database)
                            public.data = _G[files.PUBLIC]
                            obj.public = public
                        end
                    end

                    LoadingProxy(schema, obj)
                end
            end
        end
    end

    if PLUGINS then
        for i=1,#PLUGINS do
            local halt = false;
            local schema = PLUGINS[i];
            local obj = _G[schema];
            if(obj and (not obj.initialized)) then
                local files = obj.___svfiles;
                if(files) then
                    if(not PRIVATE_UI.SAFEDATA.SAVED[schema]) then
                        PRIVATE_UI.SAFEDATA.SAVED[schema] = true
                    end

                    if(files.PRIVATE) then
                        if not _G[files.PRIVATE] then _G[files.PRIVATE] = {} end
                        local private = setmetatable({}, meta_database)
                        private.data = _G[files.PRIVATE]
                        obj.private = private

                        if(obj.private and obj.private.incompatible) then
                            for addon,_ in pairs(obj.private.incompatible) do
                                if IsAddOnLoaded(addon) then halt = true end
                            end
                        end
                    end

                    if((not halt) and files.PUBLIC) then
                        if not _G[files.PUBLIC] then _G[files.PUBLIC] = {} end
                        local public = setmetatable({}, meta_database)
                        public.data = _G[files.PUBLIC]
                        obj.public = public
                    end
                end

                if(not halt) then
                    LoadingProxy(schema, obj)
                end
            end
        end
    end

    UpdateConstraints()
end

function lib:LoadScripts()
    if ScriptQueue then
        for i=1, #ScriptQueue do
            local fn = ScriptQueue[i]
            if(fn and type(fn) == "function") then
                fn()
            end
        end

        ScriptQueue = nil
    end
end

--DATABASE PUBLIC METHODS
function lib:Remove(key)
    if(GLOBAL_UI.profiles[key]) then GLOBAL_UI.profiles[key] = nil end
    if(GLOBAL_UI.profileRealms[key]) then GLOBAL_UI.profileRealms[key] = nil end
    wipe(GLOBAL_UI.profileKeys)
    for k,v in pairs(GLOBAL_UI.profiles) do
        GLOBAL_UI.profileKeys[k] = k
    end
end

function lib:GetProfiles()
    local list = GLOBAL_UI.profileKeys or {}
    return list
end

function lib:CheckProfiles()
    local hasProfile = false
    local list = GLOBAL_UI.profileKeys or {}
    for key,_ in pairs(list) do
        hasProfile = true
    end
    return hasProfile
end

function lib:CurrentProfile()
    return PRIVATE_UI.SAFEDATA.CurrentProfile
end

function lib:UnsetProfile()
    PRIVATE_UI.SAFEDATA.CurrentProfile = nil;
end

function lib:CopyDatabase(key, linked)
    if((not key) or (not GLOBAL_UI.profiles[key])) then return end
    PRIVATE_UI.SAFEDATA["install_version"] = CoreObject.Version
    if(not linked) then
        wipe(GLOBAL_UI.profiles[PROFILE_KEY])
        local export = GLOBAL_UI.profiles[key];
        local saved = GLOBAL_UI.profiles[PROFILE_KEY];
        tablecopy(saved, export);

        if(MEDIA_UI.profiles[THEME_KEY][key]) then
            wipe(MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY])
            export = MEDIA_UI.profiles[THEME_KEY][key];
            saved = MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY];
            tablecopy(saved, export);
        end
        ReloadUI()
    else
        UpdateProfileSources(key)
        ReloadUI()
    end
end

function lib:CloneDatabase(key)
    if(not key) then return end
    PRIVATE_UI.SAFEDATA["install_version"] = CoreObject.Version
    local export, saved
    if(not GLOBAL_UI.profiles[key]) then GLOBAL_UI.profiles[key] = {} end;
    export = GLOBAL_UI.profiles[PROFILE_KEY];
    saved = GLOBAL_UI.profiles[key];
    tablecopy(saved, export);

    if(not MEDIA_UI.profiles[THEME_KEY][key]) then MEDIA_UI.profiles[THEME_KEY][key] = {} end;
    export = MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY];
    saved = MEDIA_UI.profiles[THEME_KEY][key];
    tablecopy(saved, export);

    DirtyDataList[key] = THEME_KEY;

    UpdateProfileSources(key)
end

function lib:ExportDatabase()
    local t = {["PROFILE"] = {}, ["MEDIA"] = {[THEME_KEY] = {}}};
    tablecopy(t["PROFILE"], GLOBAL_UI.profiles[PROFILE_KEY]);
    tablecopy(t["MEDIA"][THEME_KEY], MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY]);

    sanitize(t["PROFILE"], CoreObject.defaults, true)
    sanitize(t["MEDIA"][THEME_KEY], CoreObject.Mediadefaults)

    local export = pickle(t)

    return export:encode()
end

function lib:ImportDatabase(encoded)
    if(not encoded) then return end

    local decoded = encoded:decode();
    local newtable = unpickle(decoded);
    local import, saved;

    wipe(GLOBAL_UI.profiles[PROFILE_KEY])
    import = newtable["PROFILE"];
    saved = GLOBAL_UI.profiles[PROFILE_KEY];
    tablecopy(saved, import);

    if(newtable["MEDIA"][THEME_KEY]) then
        wipe(MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY])
        import = newtable["MEDIA"][THEME_KEY];
        saved = MEDIA_UI.profiles[THEME_KEY][PROFILE_KEY];
        tablecopy(saved, import);
    end

    ReloadUI()
end

function lib:WipeDatabase()
    for k,v in pairs(GLOBAL_UI.profiles[PROFILE_KEY]) do
        GLOBAL_UI.profiles[PROFILE_KEY][k] = nil
    end
end

function lib:WipeCache(index)
    if(index) then
        if(index ~= "SAFEDATA") then PRIVATE_UI[index] = nil end
    else
        for k,v in pairs(PRIVATE_UI) do
            if(k ~= "SAFEDATA") then
                PRIVATE_UI[k] = nil
            end
        end
    end
end

function lib:WipeGlobal()
    for k,v in pairs(GLOBAL_UI) do
        GLOBAL_UI[k] = nil
    end
end

function lib:GetSafeData(index)
    if(index) then
        return PRIVATE_UI.SAFEDATA[index]
    else
        return PRIVATE_UI.SAFEDATA
    end
end

function lib:SaveSafeData(index, value)
    PRIVATE_UI.SAFEDATA[index] = value
end

function lib:CheckData(schema, key)
    local file = GLOBAL_UI.profiles[PROFILE_KEY][schema]
    print("______" .. schema .. ".db[" .. key .. "]_____")
    print(file[key])
    print("______SAVED_____")
end

function lib:NewGlobal(index)
    index = index or CoreObject.Schema
    if(not GLOBAL_UI[index]) then
        GLOBAL_UI[index] = {}
    end
    return GLOBAL_UI[index]
end

function lib:CheckDualProfile()
    return PRIVATE_UI.SAFEDATA.DUALSPEC
end

function lib:ToggleDualProfile(enabled)
    PRIVATE_UI.SAFEDATA.DUALSPEC = enabled
    UpdateProfileSources()
end

function lib:CheckMasterProfile()
    local mp = GLOBAL_UI.SAFEDATA.MasterProfile
    if(mp and GLOBAL_UI.profiles[mp]) then
      return mp
    else
      return false
    end
end

function lib:SetMasterProfile(key)
    if((not key) or (not GLOBAL_UI.profiles[key])) then
      GLOBAL_UI.SAFEDATA.MasterProfile = false;
    else
      GLOBAL_UI.SAFEDATA.MasterProfile = key;
    end
end
