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
HELPERS
##########################################################
]]--
local RING_TEXTURE = [[Interface\AddOns\CUSTOM_UI_Skins\artwork\FOLLOWER-RING]]
local LVL_TEXTURE = [[Interface\AddOns\CUSTOM_UI_Skins\artwork\FOLLOWER-LEVEL]]
local DEFAULT_COLOR = {r = 0.25, g = 0.25, b = 0.25};
--[[
##########################################################
STYLE
##########################################################
]]--
local GarrMission_PortraitsFromLevel = function(self)
	local parent = self:GetParent()
	if(parent.PortraitRing) then
  		parent.PortraitRing:SetTexture(RING_TEXTURE)
  	end
end
UI:SetAtlasFunc("GarrMission_PortraitsFromLevel", GarrMission_PortraitsFromLevel)

local GarrMission_MaterialFrame = function(self)
  local frame = self:GetParent()
  frame:RemoveTextures()
  frame:SetStyle("Frame", "Inset", true, 1, -5, -7)
  self:SetTexture("")
end
UI:SetAtlasFunc("GarrMission_MaterialFrame", GarrMission_MaterialFrame)

UI:SetAtlasFilter("GarrMission_PortraitRing_LevelBorder", "GarrMission_PortraitsFromLevel")
UI:SetAtlasFilter("GarrMission_PortraitRing_iLvlBorder", "GarrMission_PortraitsFromLevel")
UI:SetAtlasFilter("Garr_Mission_MaterialFrame", "GarrMission_MaterialFrame")
UI:SetAtlasFilter("Garr_FollowerToast-Uncommon");
UI:SetAtlasFilter("Garr_FollowerToast-Epic");
UI:SetAtlasFilter("Garr_FollowerToast-Rare");
UI:SetAtlasFilter("GarrLanding-MinimapIcon-Horde-Up");
UI:SetAtlasFilter("GarrLanding-MinimapIcon-Horde-Down");
UI:SetAtlasFilter("GarrLanding-MinimapIcon-Alliance-Up");
UI:SetAtlasFilter("GarrLanding-MinimapIcon-Alliance-Down");

UI:SetAtlasFilter("Garr_FollowerToast-Rare");
