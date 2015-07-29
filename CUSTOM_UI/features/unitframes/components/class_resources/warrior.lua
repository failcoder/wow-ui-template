--[[
##########################################################
S V U I   By: Munglunch
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local UI = _G['CUSTOM_UI']
local L = UI.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = UI.UnitFrames

if(not MOD) then return end 

local oUF_CUSTOM_UI = MOD.oUF
assert(oUF_CUSTOM_UI, "CUSTOM_UI UnitFrames: unable to locate oUF.")
if(UI.class ~= "WARRIOR") then return end 

local ORB_ICON = [[Interface\AddOns\CUSTOM_UI_UnitFrames\assets\Class\ORB]];
local ORB_BG = [[Interface\AddOns\CUSTOM_UI_UnitFrames\assets\Class\ORB-BG]];
UI.SpecialFX:Register("conqueror", [[Spells\Warlock_destructioncharge_impact_chest.m2]], 2, -2, -2, 2, 0.9, 0, 0.8)
--[[ 
########################################################## 
POSITIONING
##########################################################
]]--
local OnMove = function()
  UI.db.UnitFrames.player.classbar.detachFromFrame = true
end

local Reposition = function(self)
	local db = UI.db.UnitFrames.player
	local bar = self.Conqueror;
	local max = self.MaxClassPower;
	local size = db.classbar.height
	local width = size * max;

	bar.Holder:SetSize(width, size)
  if(not db.classbar.detachFromFrame) then
  	UI:ResetAnchors(L["Classbar"])
  end
  local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
  if holderUpdate then
      holderUpdate(bar.Holder)
  end

  bar:ClearAllPoints()
  bar:SetAllPoints(bar.Holder)
end

local EffectModel_OnShow = function(self)
	self:SetEffect("conqueror");
end

function MOD:CreateClassBar(playerFrame)
	local max = 6
	local bar = CreateFrame("Frame",nil,playerFrame)

	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)
	--UI.SpecialFX:SetFXFrame(bar, "conqueror")
	--bar.FX:SetFrameStrata("BACKGROUND")
	--bar.FX:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 1)

	local bgFrame = CreateFrame("Frame", nil, bar)
	bgFrame:InsetPoints(bar, 1, 4)
	UI.SpecialFX:SetFXFrame(bgFrame, "conqueror")

	local bgTexture = bgFrame:CreateTexture(nil, "BACKGROUND")
	bgTexture:SetAllPoints(bgFrame)
	bgTexture:SetTexture(0.2,0,0,0.5)

	local borderB = bgFrame:CreateTexture(nil,"OVERLAY")
  borderB:SetTexture(0,0,0)
  borderB:SetPoint("BOTTOMLEFT")
  borderB:SetPoint("BOTTOMRIGHT")
  borderB:SetHeight(2)

  local borderT = bgFrame:CreateTexture(nil,"OVERLAY")
  borderT:SetTexture(0,0,0)
  borderT:SetPoint("TOPLEFT")
  borderT:SetPoint("TOPRIGHT")
  borderT:SetHeight(2)

  local borderL = bgFrame:CreateTexture(nil,"OVERLAY")
  borderL:SetTexture(0,0,0)
  borderL:SetPoint("TOPLEFT")
  borderL:SetPoint("BOTTOMLEFT")
  borderL:SetWidth(2)

  local borderR = bgFrame:CreateTexture(nil,"OVERLAY")
  borderR:SetTexture(0,0,0)
  borderR:SetPoint("TOPRIGHT")
  borderR:SetPoint("BOTTOMRIGHT")
  borderR:SetWidth(2)

  bar.bg = bgTexture;

	local enrage = CreateFrame("StatusBar", nil, bgFrame)
	enrage.noupdate = true;
	enrage:InsetPoints(bgFrame)
	enrage:SetOrientation("HORIZONTAL")
	enrage:SetStatusBarTexture(UI.Media.statusbar.glow)
  enrage:SetStatusBarColor(1, 0, 0, 0.75)

  bgFrame.bar = enrage;
  --UI.SpecialFX:SetFXFrame(enrage, "conqueror", true)
	--enrage.FX:SetScript("OnShow", EffectModel_OnShow)
	bar.Enrage = bgFrame;


	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	UI:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max
	playerFrame.RefreshClassBar = Reposition

	playerFrame.Conqueror = bar
	return 'Conqueror'  
end 