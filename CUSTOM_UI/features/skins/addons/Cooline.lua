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
COOLINE
##########################################################
]]--
local function StyleCoolLine()
	assert(CoolLineDB, "AddOn Not Loaded")
	
	CoolLineDB.bgcolor = { r = 0, g = 0, b = 0, a = 0, }
	CoolLineDB.border = "None"
	CoolLine.updatelook()

	if(not CoolLine.Panel) then
		UI.API:Set("Frame", CoolLine, "Transparent")
	end

	UI:ManageVisibility(CoolLine)

	if MOD:IsAddonReady("CoolLine_Anchored") then
		if(not CoolLineDB.vertical and (UI.ActionBars and UI.ActionBars.MainAnchor)) then
			CoolLine:ClearAllPoints()
			CoolLine:SetPoint('BOTTOMRIGHT', UI.ActionBars.MainAnchor, 'TOPRIGHT', 0, 4)
			CoolLine:SetPoint("BOTTOMLEFT", UI.ActionBars.MainAnchor, "TOPLEFT", 0, 4)
		end
	end
end
MOD:SaveAddonStyle("CoolLine", StyleCoolLine)