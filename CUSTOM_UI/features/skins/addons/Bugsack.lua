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
--[[ STRING METHODS ]]--
local format = string.format;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local UI = _G['CUSTOM_UI'];
local L = UI.L;
local MOD = UI.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
BUGSACK
##########################################################
]]--
local function StyleBugSack(event, addon)
	assert(BugSack, "AddOn Not Loaded")
	hooksecurefunc(BugSack, "OpenSack", function()
		if BugSackFrame.Panel then return end
		BugSackFrame:RemoveTextures()
		BugSackFrame:SetStyle("Frame", 'Transparent')
		UI.API:Set("Tab", BugSackTabAll)
		BugSackTabAll:SetPoint("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, 1)
		UI.API:Set("Tab", BugSackTabSession)
		UI.API:Set("Tab", BugSackTabLast)
		BugSackNextButton:SetStyle("Button")
		BugSackSendButton:SetStyle("Button")
		BugSackPrevButton:SetStyle("Button")
		UI.API:Set("ScrollBar", BugSackScrollScrollBar)
	end)
end

MOD:SaveAddonStyle("Bugsack", StyleBugSack)