--[[
##############################################################################
S V U I   By: Munglunch
############################################################################## ]]--

--[[ GLOBALS ]]--

local _G = _G;
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
local split         = string.split;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local floor         = math.floor
local random        = math.random;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local wipe          = _G.wipe;

_G.SlashCmdList.RELOADUI = ReloadUI
_G.SLASH_RELOADUI1 = "/rl"
_G.SLASH_RELOADUI2 = "/reloadui"
_G.CUSTOM_UI_ICON_COORDS = {0.1, 0.9, 0.1, 0.9};

--[[ GET THE REGISTRY LIB ]]--

local UI_Registry = Librarian("Registry");

--[[ LOCALS ]]--

local rez = GetCVar("gxResolution");
local baseHeight = tonumber(rez:match("%d+x(%d+)"))
local baseWidth = tonumber(rez:match("(%d+)x%d+"))
local defaultDockWidth = baseWidth * 0.66;
local defaultCenterWidth = min(defaultDockWidth, 900);
local callbacks = {};
local numCallbacks = 0;
local playerName = UnitName("player");
local playerRealm = GetRealmName();
local playerClass = select(2, UnitClass("player"));
local errorPattern = "|cffff0000Error -- |r|cffff9900Required addon '|r|cffffff00%s|r|cffff9900' is %s.|r";

--[[ CORE ENGINE CONSTRUCT ]]--

-- We have to send the names of our three SavedVariables files since the WoW API
-- has no method for parsing them in LUA.
local UI = UI_Registry:NewCore("CUSTOM_UI_Global", "CUSTOM_UI_Errors", "CUSTOM_UI_Private", "CUSTOM_UI_Media")

UI.ConfigID           = "CUSTOM_UI_!Options";
UI.class              = playerClass;
UI.GUID               = UnitGUID('player');
UI.Allegiance         = UnitFactionGroup("player");
UI.ClassRole          = "";
UI.SpecificClassRole  = "NONE";

UI.Screen = CreateFrame("Frame", "CUSTOM_UIParent", UIParent);
UI.Screen:SetFrameLevel(UIParent:GetFrameLevel());
UI.Screen:SetPoint("CENTER", UIParent, "CENTER");
UI.Screen:SetSize(UIParent:GetSize());

UI.Hidden = CreateFrame("Frame", nil, UIParent);
UI.Hidden:Hide();

UI.RollFrames         = {};
UI.SystemAlert        = {};

UI_Registry.CONSTRAINTS.IGNORED["LAYOUT"] = true;
UI_Registry.CONSTRAINTS.IGNORED["REPORT_SLOTS"] = true;

UI_Registry.CONSTRAINTS.PROTECTED["extended"] = true;
UI_Registry.CONSTRAINTS.PROTECTED["shared"] = true;
UI_Registry.CONSTRAINTS.PROTECTED["color"] = true;
UI_Registry.CONSTRAINTS.PROTECTED["bordercolor"] = true;
UI_Registry.CONSTRAINTS.PROTECTED["Filters"] = true;

UI.Mediadefaults      = {};
UI.defaults           = {
    ["LAYOUT"] = {},
    ["Filters"] = {},
    ["screen"] = {
        ["autoScale"] = true,
        ["multiMonitor"] = false,
        ["advanced"] = false,
        ["scaleAdjust"] = 0.64,
        ["forcedWidth"] = baseWidth,
        ["forcedHeight"] = baseHeight,
    },
    ["general"] = {
        ["useDraggable"] = true,
        ["saveDraggable"] = false,
        ["taintLog"] = false,
        ["stickyFrames"] = true,
        ["graphSize"] = 50,
        ["hideErrorFrame"] = true,
    },
};

--[[ EMBEDDED LIBS ]]--

UI.Options = {
    type = "group",
    name = "|cff339fffUI Options|r",
    args = {
        CUSTOM_UI_Header = {
            order = 1,
            type = "header",
            name = ("Powered By |cffff9900CUSTOM_UI|r - %s: |cff99ff33%s|r"):format(UI.L["Version"], UI.Version),
            width = "full"
        },
        profiles = {
            order = 9997,
            type = "group",
            name = UI.L["Profiles"],
            childGroups = "tab",
            args = {}
        },
        credits = {
            type = "group",
            name = UI.L["Credits"],
            order = -1,
            args = {
                new = {
                    order = 1,
                    type = "description",
                    name = function() return UI:PrintCredits() end
                }
            }
        }
    }
};

local function _tablecopy(d, s)
    if(type(s) ~= "table") then return end
    if(type(d) ~= "table") then return end
    for k, v in pairs(s) do
        local saved = d[k]
        if type(v) == "table" then
            if not saved then d[k] = {} end
            _tablecopy(d[k], v)
        elseif(saved == nil or (saved and type(saved) ~= type(v))) then
            d[k] = v
        end
    end
end

local function _needsupdate(value, lowMajor, lowMinor, lowPatch)
    lowMajor = lowMajor or 0;
    lowMinor = lowMinor or 0;
    lowPatch = lowPatch or 0;
    local version = value or '0.0';
    if(version and type(version) ~= string) then
        version = tostring(version)
    end
    if(not version) then
       -- print('No Version Found')
        return true
    end
    local vt = version:explode(".")
    local MAJOR,MINOR,PATCH = unpack(vt)
    --print(PATCH)
    --print(type(lowPatch))
    if(PATCH and (lowPatch > 0)) then
        if(type(PATCH) == "string") then
            PATCH = tonumber(PATCH)
        end
        if(type(PATCH) == "number" and PATCH < lowPatch) then
            UI_Registry:CleanUpData(true);
            UI_Registry:SaveSafeData("install_version", UI.Version);
        end
    end
    if(MINOR and (lowMinor > 0)) then
        if(type(MINOR) == "string") then
            MINOR = tonumber(MINOR)
        end
        if(type(MINOR) == "number" and MINOR < lowMinor) then
            UI_Registry:CleanUpData(true);
            UI_Registry:SaveSafeData("install_version", UI.Version);
        end
    end
    if(MAJOR and (lowMajor > 0)) then
        if(type(MAJOR) == "string") then
            MAJOR = tonumber(MAJOR)
        end
        if(type(MAJOR) == "number" and MAJOR < lowMajor) then
            return true
        else
            return false
        end
    else
        return true
    end
end

--[[ BUILD LOGIN MESSAGES ]]--
do
    local messagePattern = "|cffFF2F00%s:|r";

    local function _send_message(msg, prefix)
        if(type(msg) == "table") then
             msg = tostring(msg)
        end
        if(not msg) then return end
        if(prefix) then
            local outbound = ("%s %s"):format(prefix, msg);
            print(outbound)
        else
            print(msg)
        end
    end

    function UI:SCTMessage(message, r, g, b, displayType)
        --/script CombatText_AddMessage("TESTING", COMBAT_TEXT_SCROLL_FUNCTION, 1, 1, 0)
        if not _G.CombatText_AddMessage then return end
        _G.CombatText_AddMessage(message, COMBAT_TEXT_SCROLL_FUNCTION, r, g, b, displayType)
    end

    function UI:AddonMessage(msg)
        local outbound = (messagePattern):format(self.NameID)
        _send_message(msg, outbound)
    end

    function UI:CharacterMessage(msg)
        local outbound = (messagePattern):format(playerName)
        _send_message(msg, outbound)
    end
end

--[[ CORE FUNCTIONS ]]--

function UI:fubar() return end

function UI:StaticPopup_Show(arg)
    if arg == "ADDON_ACTION_FORBIDDEN" then
        StaticPopup_Hide(arg)
    end
end

function UI:ResetAllUI(confirmed)
    if InCombatLockdown()then
        UI:AddonMessage(ERR_NOT_IN_COMBAT)
        return
    end
    if(not confirmed) then
        UI:StaticPopup_Show('RESET_UI_CHECK')
        return
    end
    UI.Setup:Reset()
    UI.Events:Trigger("FULL_UI_RESET");
end

function UI:ResetUI(confirmed)
    if InCombatLockdown()then
        self:AddonMessage(ERR_NOT_IN_COMBAT)
        return
    end
    if(not confirmed) then
        self:StaticPopup_Show('RESETMOVERS_CHECK')
        return
    end
    self:ResetAnchors()
end

function UI:ToggleConfig()
    if InCombatLockdown() then
        self:AddonMessage(ERR_NOT_IN_COMBAT)
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    self.OptionsStandby = nil
    if not IsAddOnLoaded(self.ConfigID) then
        local _,_,_,_,_,state = GetAddOnInfo(self.ConfigID)
        if state ~= "MISSING" and state ~= "DISABLED" then
            LoadAddOn(self.ConfigID)
        else
            local errorMessage = (errorPattern):format(self.ConfigID, state)
            self:AddonMessage(errorMessage)
            return
        end
    end
    local aceConfig = LibStub("AceConfigDialog-1.0", true)
    if(aceConfig) then
        local switch = not aceConfig.OpenFrames[self.NameID] and "Open" or "Close"
        aceConfig[switch](aceConfig, self.NameID)
        GameTooltip:Hide()
    end
end

function UI:VersionCheck()
    local delayed;
    if(_G.CUSTOM_UI_TRANSFER_WIZARD) then
        local copied = UI_Registry:GetSafeData("transfer_wizard_used");
        if(not copied) then
            delayed = true;
            _G.CUSTOM_UI_TRANSFER_WIZARD()
        end
    end
    if(not delayed) then
        local version = UI_Registry:GetSafeData("install_version");
        if(not version or (version and _needsupdate(version, 1, 1, 0))) then
            self.Setup:Install(true)
        end
    end
end

function UI:RefreshEverything(bypass)
    self:UpdateSharedMedia();
    self:UpdateAnchors();
    UI_Registry:RefreshAll();
    if not bypass then
        self:VersionCheck()
    end
end

--[[ EVENT HANDLERS ]]--
local VISIBILITY_FRAMELIST = {};

function UI:ManageVisibility(frame)
    if(not frame) then return end
    local parent = UIParent;
    if(frame.GetParent) then
        parent = frame:GetParent();
    end
    tinsert(VISIBILITY_FRAMELIST, {frame = frame, parent = parent})
end

local function AuditVisibility(hidden)
    if(hidden) then
      UI.NeedsFrameAudit = true
      if(InCombatLockdown()) then return end
      for i=1, #VISIBILITY_FRAMELIST do
        local data = VISIBILITY_FRAMELIST[i]
        data.frame:SetParent(UI.Hidden)
      end
    else
      if(InCombatLockdown()) then return end
      for i=1, #VISIBILITY_FRAMELIST do
        local data = VISIBILITY_FRAMELIST[i]
        data.frame:SetParent(data.parent or UIParent)
      end
      UI.NeedsFrameAudit = false
    end
end

function UI:PLAYER_ENTERING_WORLD()
    if(not self.MediaInitialized) then
        self:RefreshAllMedia()
    end
    if(not InCombatLockdown()) then
        collectgarbage("collect")
    end
end

function UI:PET_BATTLE_CLOSE()
    AuditVisibility()
    UI_Registry:LiveUpdate()
end

function UI:PET_BATTLE_OPENING_START()
    AuditVisibility(true);
end

function UI:PLAYER_REGEN_DISABLED()
    local forceClosed = false;

    if(self.OptionsLoaded) then
        local aceConfig = LibStub("AceConfigDialog-1.0")
        if aceConfig.OpenFrames[self.NameID] then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            aceConfig:Close(self.NameID)
            self.OptionsStandby = true
            forceClosed = true
        end
    end

    if(self:ForceAnchors(forceClosed) == true) then
        self:AddonMessage(ERR_NOT_IN_COMBAT)
    end

    if(self.NeedsFrameAudit) then
        AuditVisibility()
    end
end

function UI:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if(self.OptionsStandby) then
        self:ToggleConfig()
    end
end

function UI:TaintHandler(event, taint, sourceName, sourceFunc)
    if GetCVarBool('scriptErrors') ~= 1 then return end
    local errorString = ("Error Captured: %s->%s->{%s}"):format(taint, sourceName or "Unknown", sourceFunc or "Unknown")
    self:AddonMessage(errorString)
end

--[[ LOAD FUNCTIONS ]]--

function UI:ReLoad()
    self:RefreshAllMedia();
    self:UpdateAnchors();
    if(self.DebugMode) then
        self:AddonMessage("User settings updated");
    end
end

function UI:PreLoad()
    self:RegisterEvent('PLAYER_REGEN_DISABLED');
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UI_SCALE_CHANGED");
    self:RegisterEvent("PET_BATTLE_CLOSE");
    self:RegisterEvent("PET_BATTLE_OPENING_START");
    self:RegisterEvent("ADDON_ACTION_BLOCKED", "TaintHandler");
    self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "TaintHandler");
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "PlayerInfoUpdate");
    self:RegisterEvent("CHARACTER_POINTS_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "PlayerInfoUpdate");
end

function UI:Initialize()
    self:UI_SCALE_CHANGED()
    self.Events:TriggerOnce("LOAD_ALL_ESSENTIALS");
    self.Events:TriggerOnce("LOAD_ALL_WIDGETS");

    UI_Registry:Launch();

    self:UI_SCALE_CHANGED("PLAYER_LOGIN")
    self:PlayerInfoUpdate();
    self:VersionCheck();
    self:RefreshAllMedia();

    UI_Registry:LoadScripts();
    self.Events:TriggerOnce("CORE_INITIALIZED");

    hooksecurefunc("StaticPopup_Show", self.StaticPopup_Show);
    hooksecurefunc("CloseSpecialWindows", function() UI.OptionsStandby = nil; UI.Events:Trigger("SPECIAL_FRAMES_CLOSED") end)

    if(self.DebugMode and self.HasErrors and self.ScriptError) then
        self:ShowErrors();
        wipe(self.ERRORLOG)
    end

    collectgarbage("collect");
end
--[[
##########################################################
THE CLEANING LADY
##########################################################
]]--
local LemonPledge = 0;
local Consuela = CreateFrame("Frame")
Consuela:RegisterAllEvents()
Consuela:SetScript("OnEvent", function(self, event)
    LemonPledge = LemonPledge  +  1
    --print(event)
    if(InCombatLockdown()) then return end;
    if(LemonPledge > 10000) then
        collectgarbage("collect");
        LemonPledge = 0;
    end
end)
