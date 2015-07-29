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
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local find, format, split = string.find, string.format, string.split;
local gsub = string.gsub;
--[[ MATH METHODS ]]--
local ceil = math.ceil;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local UI = _G['CUSTOM_UI']
local L = UI.L;
local MOD = UI.ActionBars;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local NewFrame = CreateFrame
local NewHook = hooksecurefunc
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function RefreshMicrobar()
	if not CUSTOM_UI_MicroBar then return end 
	local lastParent = CUSTOM_UI_MicroBar;
	local buttonSize =  UI.db.ActionBars.Micro.buttonsize or 30;
	local spacing =  UI.db.ActionBars.Micro.buttonspacing or 1;
	local barWidth = (buttonSize + spacing) * 13;
	CUSTOM_UI_MicroBar_MOVE:SetSize(barWidth, buttonSize)
	CUSTOM_UI_MicroBar:SetAllPoints(CUSTOM_UI_MicroBar_MOVE)
	for i=1,13 do
		local data = MOD.Media.microMenuCoords[i]
		local button = _G[data[1]]
		if(button) then
			button:ClearAllPoints()
			button:SetSize(buttonSize, buttonSize + 28)
			button._fade = UI.db.ActionBars.Micro.mouseover
			if lastParent == CUSTOM_UI_MicroBar then 
				button:SetPoint("BOTTOMLEFT", lastParent, "BOTTOMLEFT", 0, 0)
			else 
				button:SetPoint("BOTTOMLEFT", lastParent, "BOTTOMRIGHT", spacing, 0)
			end 
			lastParent = button;
			button:Show()
		end
	end 
end

local CUSTOM_UIMicroButton_SetNormal = function()
	local level = MainMenuMicroButton:GetFrameLevel()
	if(level > 0) then 
		MainMenuMicroButton:SetFrameLevel(level - 1)
	else 
		MainMenuMicroButton:SetFrameLevel(0)
	end
	MainMenuMicroButton:SetFrameStrata("BACKGROUND")
	MainMenuMicroButton.overlay:SetFrameLevel(level + 1)
	MainMenuMicroButton.overlay:SetFrameStrata("HIGH")
	MainMenuBarPerformanceBar:Hide()
	HelpMicroButton:Show()
end 

local CUSTOM_UIMicroButtonsParent = function(self)
	if self ~= CUSTOM_UI_MicroBar then 
		self = CUSTOM_UI_MicroBar 
	end 
	for i=1,13 do
		local data = MOD.Media.microMenuCoords[i]
		if(data) then
			local mButton = _G[data[1]]
			if(mButton) then mButton:SetParent(CUSTOM_UI_MicroBar) end
		end
	end 
end 

local MicroButton_OnEnter = function(self)
	if(self._fade) then
		CUSTOM_UI_MicroBar:FadeIn(0.2,CUSTOM_UI_MicroBar:GetAlpha(),1)
	end
	if InCombatLockdown()then return end 
	self.overlay:SetPanelColor("highlight")
	self.overlay.icon:SetGradient("VERTICAL", 0.75, 0.75, 0.75, 1, 1, 1)
end

local MicroButton_OnLeave = function(self)
	if(self._fade) then
		CUSTOM_UI_MicroBar:FadeOut(1,CUSTOM_UI_MicroBar:GetAlpha(),0)
	end
	if InCombatLockdown()then return end 
	self.overlay:SetPanelColor("default")
	self.overlay.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
end
--[[ 
########################################################## 
BAR CREATION
##########################################################
]]--
function MOD:UpdateMicroButtons()
	if(not UI.db.ActionBars.Micro.mouseover) then
		CUSTOM_UI_MicroBar:SetAlpha(1)
	else
		CUSTOM_UI_MicroBar:SetAlpha(0)
	end
	GuildMicroButtonTabard:ClearAllPoints();
	GuildMicroButtonTabard:Hide();
	RefreshMicrobar()
end

function MOD:InitializeMicroBar()
	if(not UI.db.ActionBars.Micro.enable) then return end
	local buttonSize = UI.db.ActionBars.Micro.buttonsize or 30;
	local spacing =  UI.db.ActionBars.Micro.buttonspacing or 1;
	local barWidth = (buttonSize + spacing) * 13;
	local barHeight = (buttonSize + 6);
	local microBar = NewFrame('Frame', 'CUSTOM_UI_MicroBar', UIParent)
	microBar:SetSize(barWidth, barHeight)
	microBar:SetFrameStrata("HIGH")
	microBar:SetFrameLevel(0)
	microBar:SetPoint('BOTTOMLEFT', UI.Dock.TopLeft.Bar.ToolBar, 'BOTTOMRIGHT', 4, 0)
	UI:ManageVisibility(microBar)

	for i=1,13 do
		local data = MOD.Media.microMenuCoords[i]
		if(data) then
			local button = _G[data[1]]
			if(button) then
				button:SetParent(CUSTOM_UI_MicroBar)
				button:SetSize(buttonSize, buttonSize + 28)
				button.Flash:SetTexture("")
				if button.SetPushedTexture then 
					button:SetPushedTexture("")
				end 
				if button.SetNormalTexture then 
					button:SetNormalTexture("")
				end 
				if button.SetDisabledTexture then 
					button:SetDisabledTexture("")
				end 
				if button.SetHighlightTexture then 
					button:SetHighlightTexture("")
				end 
				button:RemoveTextures()

				local buttonMask = NewFrame("Frame",nil,button)
				buttonMask:SetPoint("TOPLEFT",button,"TOPLEFT",0,-28)
				buttonMask:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",0,0)
				buttonMask:SetStyle("DockButton") 
				buttonMask:SetPanelColor()
				buttonMask.icon = buttonMask:CreateTexture(nil,"OVERLAY",nil,2)
				buttonMask.icon:InsetPoints(buttonMask,2,2)
				buttonMask.icon:SetTexture(MOD.Media.microMenuFile)
				buttonMask.icon:SetTexCoord(data[2],data[3],data[4],data[5])
				buttonMask.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
				button.overlay = buttonMask;
				button._fade = UI.db.ActionBars.Micro.mouseover
				button:HookScript('OnEnter', MicroButton_OnEnter)
				button:HookScript('OnLeave', MicroButton_OnLeave)
				button:Show()
			end
		end
	end 

	MicroButtonPortrait:ClearAllPoints()
	MicroButtonPortrait:Hide()
	MainMenuBarPerformanceBar:ClearAllPoints()
	MainMenuBarPerformanceBar:Hide()

	NewHook('MainMenuMicroButton_SetNormal', CUSTOM_UIMicroButton_SetNormal)
	NewHook('UpdateMicroButtonsParent', CUSTOM_UIMicroButtonsParent)
	NewHook('MoveMicroButtons', RefreshMicrobar)
	NewHook('UpdateMicroButtons', MOD.UpdateMicroButtons)

	CUSTOM_UIMicroButtonsParent(microBar)
	CUSTOM_UIMicroButton_SetNormal()

	UI:NewAnchor(microBar, L["Micro Bar"])

	RefreshMicrobar()
	CUSTOM_UI_MicroBar:SetAlpha(0)
end