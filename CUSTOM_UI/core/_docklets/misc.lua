--[[
##########################################################
S V U I   By: Munglunch
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;

--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--TABLE
local table 		= _G.table;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe 		= _G.wipe;
--MATH
local math      	= _G.math;
local min 			= math.min;
local floor         = math.floor
local ceil          = math.ceil
--BLIZZARD API
local Quit         			= _G.Quit;
local Logout         		= _G.Logout;
local ReloadUI         		= _G.ReloadUI;
local GameTooltip          	= _G.GameTooltip;
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
local GetTime         		= _G.GetTime;
local GetItemCooldown       = _G.GetItemCooldown;
local GetItemCount         	= _G.GetItemCount;
local GetItemInfo          	= _G.GetItemInfo;
local GetSpellInfo         	= _G.GetSpellInfo;
local IsSpellKnown         	= _G.IsSpellKnown;
local GetProfessions       	= _G.GetProfessions;
local GetProfessionInfo    	= _G.GetProfessionInfo;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local hooksecurefunc     	= _G.hooksecurefunc;
local GetSpecialization    	= _G.GetSpecialization;
local GetNumSpecGroups    	= _G.GetNumSpecGroups;
local GetActiveSpecGroup    = _G.GetActiveSpecGroup;
local SetActiveSpecGroup    = _G.SetActiveSpecGroup;
local GetSpecializationInfo = _G.GetSpecializationInfo;
--[[
##########################################################
ADDON
##########################################################
]]--
local UI = select(2, ...)
local L = UI.L

local MOD = UI.Dock;
--[[
##########################################################
LOCALS
##########################################################
]]--
local HEARTH_SPELLS = {556,50977,18960,126892};
local HEARTH_ITEMS = {6948,110560,64488,54452,93672,28585};
local HEARTH_LEFT_CLICK, HEARTH_RIGHT_CLICK = 6948, 110560;
local HEARTH_HEADER = "HearthStone";

local function GetMacroCooldown(itemID)
	local start,duration = GetItemCooldown(itemID)
	local expires = duration - (GetTime() - start)
	if expires > 0.05 then
		local timeLeft = 0;
		local calc = 0;
		if expires < 4 then
			return format("|cffff0000%.1f|r", expires)
		elseif expires < 60 then
			return format("|cffffff00%d|r", floor(expires))
		elseif expires < 3600 then
			timeLeft = ceil(expires / 60);
			calc = floor((expires / 60) + .5);
			return format("|cffff9900%dm|r", timeLeft)
		elseif expires < 86400 then
			timeLeft = ceil(expires / 3600);
			calc = floor((expires / 3600) + .5);
			return format("|cff66ffff%dh|r", timeLeft)
		else
			timeLeft = ceil(expires / 86400);
			calc = floor((expires / 86400) + .5);
			return format("|cff6666ff%dd|r", timeLeft)
		end
	else
		return "|cff6666ffReady|r"
	end
end

local function GetHearthOption(selected)
	local option,found;
	for i = 1, #HEARTH_SPELLS do
		if(not found) then
			local optionID = HEARTH_SPELLS[i];
			if(optionID == selected) then
				found = true;
				if(IsSpellKnown(optionID)) then
					option = GetSpellInfo(optionID);
				end
			end
		end
	end
	if(not option) then
		for i = 1, #HEARTH_ITEMS do
			if(not found) then
				local optionID = HEARTH_ITEMS[i];
				if(optionID == selected) then
					found = true;
					local test = GetItemInfo(optionID);
					if(test and type(test) == 'string') then
						local owned = GetItemCount(optionID,false)
						if(owned and owned > 0) then
							option = test;
						end
					end
				end
			end
		end
	end
	return option;
end

local function UpdateHearthOptions()
	HEARTH_LEFT_CLICK = UI.db.Dock.hearthOptions.left;
	HEARTH_RIGHT_CLICK = UI.db.Dock.hearthOptions.right;

	local leftClick = GetHearthOption(HEARTH_LEFT_CLICK);
	if(leftClick and type(leftClick) == "string") then
		CUSTOM_UI_Hearth:SetAttribute("tipText", leftClick)
		CUSTOM_UI_Hearth:SetAttribute("macrotext1", "/use [nomod]" .. leftClick)
	end

	local rightClick = GetHearthOption(HEARTH_RIGHT_CLICK);
	if(rightClick and type(rightClick) == "string") then
		CUSTOM_UI_Hearth:SetAttribute("tipExtraText", rightClick)
		CUSTOM_UI_Hearth:SetAttribute("macrotext2", "/use [nomod]" .. rightClick)
	end
end

local Hearth_OnEnter = function(self)
	GameTooltip:AddLine(HELPFRAME_STUCK_HEARTHSTONE_HEADER, 1, 1, 0)
	GameTooltip:AddLine(" ", 1, 1, 1)
	local location = GetBindLocation()
	GameTooltip:AddDoubleLine(LOCATION_COLON, location, 1, 0.5, 0, 1, 1, 1)
	if InCombatLockdown() then return end
	local remaining = GetMacroCooldown(6948)
	GameTooltip:AddDoubleLine(L["Time Remaining"], remaining, 1, 0.5, 0, 1, 1, 1)
	local text1 = self:GetAttribute("tipText")
	local text2 = self:GetAttribute("tipExtraText")
	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddDoubleLine("[Left-Click]", text1, 0, 1, 0, 1, 1, 1)
	if(text2 and text2 ~= "") then
		GameTooltip:AddDoubleLine("[Right-Click]", text2, 0, 1, 0, 1, 1, 1)
	end
	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddDoubleLine("|cff0099FFSHIFT|r + Left-Click", "Left Click Options", 0, 1, 0, 0.5, 1, 0.5)
	GameTooltip:AddDoubleLine("|cff0099FFSHIFT|r + Right-Click", "Right Click Options", 0, 1, 0, 0.5, 1, 0.5)
end

local Hearth_OnShiftLeftClick = function(self)
	if(IsShiftKeyDown()) then

		local t = {};
		tinsert(t, { title = "Left Click Options", divider = true });
		for i = 1, #HEARTH_SPELLS do
			local optionID = HEARTH_SPELLS[i];
			if(IsSpellKnown(optionID)) then
				local hearthOption = GetSpellInfo(optionID);
				if(hearthOption and type(hearthOption) == 'string') then
					tinsert(t, { text = hearthOption, func = function() UI.db.Dock.hearthOptions.left = optionID; UpdateHearthOptions(); end });
				end
			end
		end
		for i = 1, #HEARTH_ITEMS do
			local optionID = HEARTH_ITEMS[i];
			local hearthOption = GetItemInfo(optionID);
			if(hearthOption and type(hearthOption) == 'string') then
				local owned = GetItemCount(optionID,false)
				if(owned and owned > 0) then
					tinsert(t, { text = hearthOption, func = function() UI.db.Dock.hearthOptions.left = optionID; UpdateHearthOptions(); end });
				end
			end
		end

		UI.Dropdown:Open(self, t, HEARTH_HEADER);
	end
end

local Hearth_OnShiftRightClick = function(self)
	if(IsShiftKeyDown()) then

		local t = {};
		tinsert(t, { title = "Right Click Options", divider = true });
		for i = 1, #HEARTH_SPELLS do
			local optionID = HEARTH_SPELLS[i];
			if(IsSpellKnown(optionID)) then
				local hearthOption = GetSpellInfo(optionID);
				if(hearthOption and type(hearthOption) == 'string') then
					tinsert(t, { text = hearthOption, func = function() UI.db.Dock.hearthOptions.right = optionID; UpdateHearthOptions(); end });
				end
			end
		end
		for i = 1, #HEARTH_ITEMS do
			local optionID = HEARTH_ITEMS[i];
			local hearthOption = GetItemInfo(optionID);
			if(hearthOption and type(hearthOption) == 'string') then
				local owned = GetItemCount(optionID,false)
				if(owned and owned > 0) then
					tinsert(t, { text = hearthOption, func = function() UI.db.Dock.hearthOptions.right = optionID; UpdateHearthOptions(); end });
				end
			end
		end

		UI.Dropdown:Open(self, t, HEARTH_HEADER);
	end
end

local SpecSwap_OnClick = function(self)
	if InCombatLockdown() then return end
	local current = GetActiveSpecGroup()
	if(current == 2) then
		SetActiveSpecGroup(1)
	else
		SetActiveSpecGroup(2)
	end
end

local SpecSwap_OnEnter = function(self)
	local currentGroup = GetActiveSpecGroup()
	local currentSpec = GetSpecialization(false, false, currentGroup);
	local text1 = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
	local otherGroup = 1;
	local activeText = SPECIALIZATION_SECONDARY_ACTIVE;
	local otherText = SPECIALIZATION_PRIMARY;
	if(currentGroup == 1) then
		otherGroup = 2
		activeText = SPECIALIZATION_PRIMARY_ACTIVE;
		otherText = SPECIALIZATION_SECONDARY;
	end
	local otherSpec = GetSpecialization(false, false, otherGroup);
	local text2 = otherSpec and select(2, GetSpecializationInfo(otherSpec)) or "None"
	GameTooltip:AddLine(GARRISON_SWITCH_SPECIALIZATIONS, 1, 1, 0)
	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddDoubleLine(activeText, text1, 1, 0.5, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine(otherText, text2, 1, 0.5, 0, 1, 1, 1)
end

local PowerButton_OnLeftClick = function(self)
	if(IsShiftKeyDown()) then
		ReloadUI()
	else
		Logout()
	end
end

local PowerButton_OnRightClick = function(self)
	if(IsShiftKeyDown()) then
		Quit()
	end
end

local PowerButton_OnEnter = function(self)
	GameTooltip:AddLine(OTHER .. " " .. OPTIONS_MENU, 1, 1, 0)
	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddDoubleLine("[Left-Click]", LOGOUT, 0, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("[SHIFT + Left-Click]", RELOADUI, 0, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("[SHIFT + Right-Click]", EXIT_GAME, 0, 1, 0, 1, 1, 1)
end

local function LoadMiscTools()
	if(MOD.MiscToolsLoaded) then return end

	if(InCombatLockdown()) then
		MOD.MiscNeedsUpdate = true;
		MOD:RegisterEvent("PLAYER_REGEN_ENABLED");
		return
	end

	-- HEARTH BUTTON
	HEARTH_HEADER = GetHearthOption(6948);

	if(UI.db.Dock.dockTools.hearth) then
		if(HEARTH_HEADER and type(HEARTH_HEADER) == "string") then
			local hearth = UI.Dock:SetDockButton("BottomLeft", HEARTH_HEADER, "CUSTOM_UI_Hearth", UI.Media.dock.hearthIcon, Hearth_OnEnter, "SecureActionButtonTemplate")
			hearth.Icon:SetTexCoord(0,0.5,0,1)
			hearth:SetAttribute("type1", "macro")
			hearth:SetAttribute("type2", "macro")

			UpdateHearthOptions();

			hearth:SetClickCallbacks(Hearth_OnShiftLeftClick, Hearth_OnShiftRightClick)
		end
	end

	-- SPEC BUTTON
	if(UI.db.Dock.dockTools.specswap) then
		local numSpecGroups = GetNumSpecGroups()
		if(numSpecGroups and numSpecGroups == 2) then
			local specSwap = UI.Dock:SetDockButton("BottomLeft", L["Spec Swap"], "CUSTOM_UI_SpecSwap", UI.Media.dock.specSwapIcon, SpecSwap_OnEnter)
			specSwap:SetClickCallbacks(SpecSwap_OnClick);
		end
	end

	-- POWER BUTTON
	if(UI.db.Dock.dockTools.power) then
		local power = UI.Dock:SetDockButton("BottomLeft", L["Power Button"], "CUSTOM_UI_PowerButton", UI.Media.dock.powerIcon, PowerButton_OnEnter)
		power:SetClickCallbacks(PowerButton_OnLeftClick, PowerButton_OnRightClick);
	end

	MOD.MiscToolsLoaded = true
end
--[[
##########################################################
BUILD/UPDATE
##########################################################
]]--
function MOD:UpdateMiscTools()
	if(self.MiscToolsLoaded) then return end
	LoadMiscTools()
end

function MOD:LoadAllMiscTools()
	if(self.MiscToolsLoaded) then return end
	UI.Timers:ExecuteTimer(LoadMiscTools, 5)
end
