--[[
##########################################################
S V U I   By: Munglunch
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
--BLIZZARD API
local Quit         			= _G.Quit;
local Logout         		= _G.Logout;
local ReloadUI         		= _G.ReloadUI;
local GameTooltip          	= _G.GameTooltip;
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
local IsInRaid              = _G.IsInRaid;
local IsInGroup             = _G.IsInGroup;
local IsInInstance          = _G.IsInInstance;
local ROLE_POLL          	= _G.ROLE_POLL;
local READY_CHECK          	= _G.READY_CHECK;
local RAID_CONTROL          = _G.RAID_CONTROL;
--[[
##########################################################
GET ADDON DATA
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
local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if ((IsInGroup() and not IsInRaid()) or UnitIsGroupLeader('player') or UnitIsGroupAssistant("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

local Button_OnEnter = function(self)
	self:SetPanelColor("highlight")
end

local Button_OnLeave = function(self)
	self:SetPanelColor("default")
	GameTooltip:Hide()
end

local ToolButton_OnEnter = function(self, ...)
	CUSTOM_UI_RaidToolDockButton:SetPanelColor("highlight")
	CUSTOM_UI_RaidToolDockButton.Icon:SetGradient(unpack(UI.Media.gradient.highlight))

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine("[Left-Click]", RAID_CONTROL, 0, 1, 0, 1, 1, 1)
	GameTooltip:Show()
end

local ToolButton_OnLeave = function(self, ...)
	CUSTOM_UI_RaidToolDockButton:SetPanelColor("default")
	CUSTOM_UI_RaidToolDockButton.Icon:SetGradient(unpack(UI.Media.gradient.icon))

	GameTooltip:Hide()
end

local function NewToolButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, textDisplay)
	local button = CreateFrame("Button", name, parent, template)
	button:RemoveTextures()
	button:SetWidth(width)
	button:SetHeight(height)
	button:SetPoint(point, relativeto, point2, xOfs, yOfs)
	button:SetStyle("DockButton")

	if(textDisplay) then
		local text = button:CreateFontString(nil,"OVERLAY")
		text:SetFont(UI.Media.font.default, 14, "NONE")
		text:SetAllPoints(button)
		text:SetJustifyH("CENTER")
		text:SetText(textDisplay)

		button:SetFontString(text)
	end

	button:HookScript("OnEnter", Button_OnEnter)
	button:HookScript("OnLeave", Button_OnLeave)

	return button;
end

function MOD:UpdateRaidLeader(event)
	if InCombatLockdown() then
		self.RaidLeaderNeedsUpdate = true;
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		return
	end
	if CheckRaidStatus() then
		self.RaidTool:SetDocked(true)
		if self.RaidTool.Menu.toggled == true then
			self.RaidTool.Menu:Show()
		else
			self.RaidTool.Menu:Hide()
		end
	else
		self.RaidTool:SetDocked()
		self.RaidTool.Menu:Hide()
	end
end

function MOD:LoadRaidLeaderTools()
	if(not UI.db.Dock.dockTools.leader) then return end

	self.RaidTool = UI.Dock:SetDockButton("TopLeft", RAID_CONTROL, "CUSTOM_UI_RaidToolDockButton", UI.Media.dock.raidToolIcon);

	local dock = self.RaidTool.Parent

	self.RaidTool.Menu = CreateFrame("Frame", "CUSTOM_UI_RaidToolMenu", self.RaidTool, "SecureHandlerClickTemplate");
	self.RaidTool.Menu:SetStyle("Frame", 'Transparent');
	self.RaidTool.Menu:SetWidth(120);
	self.RaidTool.Menu:SetHeight(140);
	self.RaidTool.Menu:SetPoint("TOPLEFT", dock.ToolBar, "BOTTOMLEFT", 0, -2);
	self.RaidTool.Menu:SetFrameLevel(3);
	self.RaidTool.Menu.toggled = false;
	self.RaidTool.Menu:SetFrameStrata("HIGH");

	local CUSTOM_UI_RaidToolToggle = CreateFrame("Button", "CUSTOM_UI_RaidToolToggle", self.RaidTool, "SecureHandlerClickTemplate")
	CUSTOM_UI_RaidToolToggle:SetAllPoints(self.RaidTool)
	CUSTOM_UI_RaidToolToggle:RemoveTextures()
	CUSTOM_UI_RaidToolToggle:SetNormalTexture("")
	CUSTOM_UI_RaidToolToggle:SetPushedTexture("")
	CUSTOM_UI_RaidToolToggle:SetHighlightTexture("")
	CUSTOM_UI_RaidToolToggle:SetFrameRef("CUSTOM_UI_RaidToolMenu", CUSTOM_UI_RaidToolMenu)
	CUSTOM_UI_RaidToolToggle:SetAttribute("_onclick", [=[
		local raidUtil = self:GetFrameRef("CUSTOM_UI_RaidToolMenu");
		local closeButton = self:GetFrameRef("CUSTOM_UI_RaidToolCloseButton");
		raidUtil:Show();
		local point = self:GetPoint();
		local raidUtilPoint, raidUtilRelative, closeButtonPoint, closeButtonRelative
		if point:find("BOTTOM") then
			raidUtilPoint = "BOTTOMLEFT"
			raidUtilRelative = "TOPLEFT"
		else
			raidUtilPoint = "TOPLEFT"
			raidUtilRelative = "BOTTOMLEFT"
		end

		raidUtil:ClearAllPoints()
		closeButton:ClearAllPoints()
		raidUtil:SetPoint(raidUtilPoint, self, raidUtilRelative, 2, -2)
		closeButton:SetPoint("BOTTOM", raidUtil, "BOTTOM", 0, 2)
	]=]);
	CUSTOM_UI_RaidToolToggle:SetScript("PostClick", function(self) self:RemoveTextures(); CUSTOM_UI_RaidToolMenu.toggled = true end);
	CUSTOM_UI_RaidToolToggle:HookScript("OnEnter", ToolButton_OnEnter)
	CUSTOM_UI_RaidToolToggle:HookScript("OnLeave", ToolButton_OnLeave)
	UI:ManageVisibility(self.RaidTool);

	--Close Button
	local close = NewToolButton("CUSTOM_UI_RaidToolCloseButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 30, 18, "BOTTOM", self.RaidTool.Menu, "BOTTOM", 0, 2, "X");
	close:SetAttribute("_onclick", [=[ self:GetParent():Hide(); ]=]);
	CUSTOM_UI_RaidToolToggle:SetFrameRef("CUSTOM_UI_RaidToolCloseButton", close)
	close:SetScript("PostClick", function() CUSTOM_UI_RaidToolMenu.toggled = false end);

	local disband = NewToolButton("CUSTOM_UI_RaidToolDisbandButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate", 109, 18, "TOP", self.RaidTool.Menu, "TOP", 0, -5, L['Disband Group'])
	disband:SetScript("OnMouseUp", function(self)
		if CheckRaidStatus() then
			UI:StaticPopup_Show("DISBAND_RAID")
		end
	end)

	local rolecheck = NewToolButton("CUSTOM_UI_RaidToolRoleButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate", 109, 18, "TOP", disband, "BOTTOM", 0, -5, ROLE_POLL)
	rolecheck:SetScript("OnMouseUp", function(self)
		if CheckRaidStatus() then
			InitiateRolePoll()
		end
	end)

	local ready = NewToolButton("CUSTOM_UI_RaidToolReadyButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate", 109, 18, "TOP", rolecheck, "BOTTOM", 0, -5, READY_CHECK)
	ready:SetScript("OnMouseUp", function(self)
		if CheckRaidStatus() then
			DoReadyCheck()
		end
	end)

	local control = NewToolButton("CUSTOM_UI_RaidToolControlButton", self.RaidTool.Menu, "UIMenuButtonStretchTemplate", 109, 18, "TOP", ready, "BOTTOM", 0, -5, L['Raid Menu'])
	control:SetScript("OnMouseUp", function(self)
		ToggleFriendsFrame(4)
	end)

	local markerButton = _G["CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton"];
	local oldReadyCheck = _G["CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck"];
	local oldRollCheck = _G["CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll"];

	if(markerButton) then
		markerButton:ClearAllPoints()
		markerButton:SetPoint("TOP", control, "BOTTOM", 0, -5)
		markerButton:SetParent(self.RaidTool.Menu)
		markerButton:SetHeight(18)
		markerButton:SetWidth(109)
		markerButton:RemoveTextures()
		markerButton:SetStyle("DockButton")

		local markersText = markerButton:CreateFontString(nil,"OVERLAY")
		markersText:SetFont(UI.Media.font.default, 14, "NONE")
		markersText:SetAllPoints(markerButton)
		markersText:SetJustifyH("CENTER")
		markersText:SetText("World Markers")

		markerButton:SetFontString(markersText)

		markerButton:HookScript("OnEnter", Button_OnEnter)
		markerButton:HookScript("OnLeave", Button_OnLeave)
	end

	if(oldReadyCheck) then
		oldReadyCheck:ClearAllPoints()
		oldReadyCheck:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLockedModeToggle, "TOPLEFT", 0, 1)
		oldReadyCheck:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameHiddenModeToggle, "TOPRIGHT", 0, 1)
		if(oldRollCheck) then
			oldRollCheck:ClearAllPoints()
			oldRollCheck:SetPoint("BOTTOMLEFT", oldReadyCheck, "TOPLEFT", 0, 1)
			oldRollCheck:SetPoint("BOTTOMRIGHT", oldReadyCheck, "TOPRIGHT", 0, 1)
		end
	end

	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateRaidLeader")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateRaidLeader")
	self:UpdateRaidLeader()
end
