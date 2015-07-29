--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
--[[ ADDON ]]--
local UI = _G['CUSTOM_UI'];
local L = UI.L;
local MOD = UI.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
STYLE (IN DEVELOPMENT)
##########################################################
]]--
local function StyleDetails()
	assert(_detalhes, "AddOn Not Loaded")

	local _detalhes = _G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale("Details")

	local details_frame = _detalhes.baseframe;
	if(details_frame) then
		details_frame:RemoveTextures();
		details_frame:SetStyle("Frame", "Transparent");
	end
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveAddonStyle("Details", StyleDetails)
