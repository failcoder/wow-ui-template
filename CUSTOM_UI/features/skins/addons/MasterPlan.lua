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
local HIGHLIGHT_TEXTURE = UI.Media.background.default
local DEFAULT_COLOR = {r = 0.25, g = 0.25, b = 0.25};
local FOCUS_RINGS = {}
--[[
##########################################################
STYLE
##########################################################
]]--
local StyleRewardIcon = function(self)
  local icon = self.Icon or self.icon
  if(icon) then
    local texture = icon:GetTexture()
    icon:SetTexture(texture)
    icon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
    icon:ClearAllPoints()
    icon:InsetPoints(self, 1, 1)
    icon:SetDesaturated(false)
  end
end

local MasterPlan_GarrPortraits = function(self)
  local parent = self:GetParent()
  parent:RemoveTextures()
  self:ClearAllPoints()
  self:SetPoint("TOPLEFT", parent, "TOPLEFT", -3, 0)
  self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 3, -6)
  self:SetTexture(RING_TEXTURE)
  self:SetVertexColor(1, 0.86, 0)
  if(parent:GetWidth() == 36) then
    tinsert(FOCUS_RINGS, parent)
  end
end

local GarrMission_FocusRings = function(self)
  for k,frame in pairs(FOCUS_RINGS) do
    frame:RemoveTextures()
  end
end

local GarrMission_Rewards = function(self)
  local frame = self:GetParent()
  if(frame and (not frame.Panel)) then
    local size = frame:GetHeight() - 6
    frame:RemoveTextures()
    frame:SetStyle("Frame", 'Icon', true, 2)
    hooksecurefunc(frame, "SetPoint", StyleRewardIcon)
  end
end

local GarrMission_Buttons = function(self)
  local frame = self:GetParent()
  if(frame) then
    UI.API:Set("ItemButton", frame)
  end
end

local GarrMission_Highlights = function(self)
  local parent = self:GetParent()
  if(not parent.AtlasHighlight) then
      local frame = parent:CreateTexture(nil, "HIGHLIGHT")
    frame:InsetPoints(parent,1,1)
    frame:SetTexture(HIGHLIGHT_TEXTURE)
    frame:SetGradientAlpha("VERTICAL",0.1,0.82,0.95,0.1,0.1,0.82,0.95,0.68)
    parent.AtlasHighlight = frame
  end
  self:SetTexture("")
end

local function StyleMasterPlan()
	assert(MasterPlan, "AddOn Not Loaded")

  UI:SetAtlasFunc("MasterPlan_GarrPortraits", MasterPlan_GarrPortraits)
  UI:SetAtlasFunc("GarrMission_Rewards", GarrMission_Rewards)
  UI:SetAtlasFunc("GarrMission_Buttons", GarrMission_Buttons)
  UI:SetAtlasFunc("GarrMission_Highlights", GarrMission_Highlights)

  UI:SetAtlasFilter("Garr_FollowerPortrait_Ring", "MasterPlan_GarrPortraits");
  UI:SetAtlasFilter("_GarrMission_MissionListTopHighlight", "GarrMission_Highlights")
  UI:SetAtlasFilter("!GarrMission_Bg-Edge", "GarrMission_Buttons")
  UI:SetAtlasFilter("GarrMission_RewardsShadow", "GarrMission_Rewards")

  UI:SetAtlasFilter("_GarrMission_TopBorder-Highlight");
  UI:SetAtlasFilter("GarrMission_ListGlow-Highlight");
  UI:SetAtlasFilter("GarrMission_TopBorderCorner-Highlight");
  UI:SetAtlasFilter("Garr_InfoBox-BackgroundTile");
  UI:SetAtlasFilter("_Garr_InfoBoxBorder-Top");
  UI:SetAtlasFilter("!Garr_InfoBoxBorder-Left");
  UI:SetAtlasFilter("!Garr_InfoBox-Left");
  UI:SetAtlasFilter("_Garr_InfoBox-Top");
  UI:SetAtlasFilter("Garr_InfoBoxBorder-Corner");
  UI:SetAtlasFilter("Garr_InfoBox-CornerShadow");
  UI:SetAtlasFilter("_GarrMission_Bg-BottomEdgeSmall");
  UI:SetAtlasFilter("_GarrMission_TopBorder");
  UI:SetAtlasFilter("GarrMission_TopBorderCorner");
  UI:SetAtlasFilter("Garr_MissionList-IconBG");

  -- UI:SetAtlasFunc("GarrMission_FocusRings", GarrMission_FocusRings)
  -- UI:SetAtlasFilter("GarrMission_MissionParchment", "GarrMission_FocusRings");

	UI.API:Set("Tab", GarrisonMissionFrameTab3)
	UI.API:Set("Tab", GarrisonMissionFrameTab4)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveAddonStyle("MasterPlan", StyleMasterPlan, false, true)
