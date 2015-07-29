--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local UI = _G['CUSTOM_UI'];
local L = UI.L;
local MOD = UI.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
TIMEMANAGER MODR
##########################################################
]]--
local function TimeManagerStyle()
	if UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.timemanager ~= true then
		 return 
	end 
	
	UI.API:Set("Window", TimeManagerFrame, true)

	UI.API:Set("CloseButton", TimeManagerFrameCloseButton)
	TimeManagerFrameInset:Die()
	UI.API:Set("DropDown", TimeManagerAlarmHourDropDown, 80)
	UI.API:Set("DropDown", TimeManagerAlarmMinuteDropDown, 80)
	UI.API:Set("DropDown", TimeManagerAlarmAMPMDropDown, 80)
	TimeManagerAlarmMessageEditBox:SetStyle("Editbox")
	TimeManagerAlarmEnabledButton:SetStyle("CheckButton")
	TimeManagerMilitaryTimeCheck:SetStyle("CheckButton")
	TimeManagerLocalTimeCheck:SetStyle("CheckButton")
	TimeManagerStopwatchFrame:RemoveTextures()
	TimeManagerStopwatchCheck:SetStyle("!_Frame", "Default")
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
	TimeManagerStopwatchCheck:GetNormalTexture():InsetPoints()
	local sWatch = TimeManagerStopwatchCheck:CreateTexture(nil, "OVERLAY")
	sWatch:SetTexture(1, 1, 1, 0.3)
	sWatch:SetPoint("TOPLEFT", TimeManagerStopwatchCheck, 2, -2)
	sWatch:SetPoint("BOTTOMRIGHT", TimeManagerStopwatchCheck, -2, 2)
	TimeManagerStopwatchCheck:SetHighlightTexture(sWatch)

	StopwatchFrame:RemoveTextures()
	StopwatchFrame:SetStyle("Frame", 'Transparent')
	StopwatchFrame.Panel:SetPoint("TOPLEFT", 0, -17)
	StopwatchFrame.Panel:SetPoint("BOTTOMRIGHT", 0, 2)

	StopwatchTabFrame:RemoveTextures()
	
	UI.API:Set("CloseButton", StopwatchCloseButton)
	UI.API:Set("PageButton", StopwatchPlayPauseButton)
	UI.API:Set("PageButton", StopwatchResetButton)
	StopwatchPlayPauseButton:SetPoint("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
	StopwatchResetButton:SetPoint("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TimeManager",TimeManagerStyle)