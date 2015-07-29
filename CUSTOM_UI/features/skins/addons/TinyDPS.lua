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
TINYDPS
##########################################################
]]--
local function StyleTinyDPS()
	assert(tdpsFrame, "AddOn Not Loaded")

	UI.API:Set("Frame", tdpsFrame)

	tdpsFrame:HookScript("OnShow", function()
		if InCombatLockdown() then return end
		if MOD.Docklet:IsEmbedded("TinyDPS") then
			MOD.Docklet:Show()
		end
	end)

	if tdpsStatusBar then
		tdpsStatusBar:SetBackdrop({bgFile = UI.Media.background.default, edgeFile = [[Interface\AddOns\CUSTOM_UI\media\textures\EMPTY]], tile = false, tileSize = 0, edgeSize = 1})
		tdpsStatusBar:SetStatusBarTexture(UI.Media.statusbar.default)
	end

	tdpsRefresh()
end

MOD:SaveAddonStyle("TinyDPS", StyleTinyDPS)
