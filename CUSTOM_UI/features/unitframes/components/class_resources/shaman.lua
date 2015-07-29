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
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local assert 	= _G.assert;
local math 		= _G.math;
--[[ MATH METHODS ]]--
local random = math.random;
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
if(UI.class ~= "SHAMAN") then return end
--[[
##########################################################
LOCALS
##########################################################
]]--
local totemMax = MAX_TOTEMS
local totemPriorities = SHAMAN_TOTEM_PRIORITIES or {1, 2, 3, 4};
local totemTextures = {
	[EARTH_TOTEM_SLOT] 	= [[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\SHAMAN-EARTH]],
	[FIRE_TOTEM_SLOT] 	= [[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\SHAMAN-FIRE]],
	[WATER_TOTEM_SLOT] 	= [[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\SHAMAN-WATER]],
	[AIR_TOTEM_SLOT] 		= [[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\SHAMAN-AIR]],
};

-- [[Spells\Flowingwater_high.m2]]
-- [[Spells\Cyclonewater_state.m2]]
-- [[Spells\Shaman_water_precast.m2]]
-- [[Spells\Monk_rushingjadewind_grey.m2]]
-- [[Spells\Missile_bomb.m2]]

UI.SpecialFX:Register("shaman_fire", [[Spells\Bloodlust_state_hand.m2]], -8, 16, 8, -16, 0.23, 0.05, -0.1)
UI.SpecialFX:Register("shaman_earth", [[Spells\Sand_precast_hand.m2]], -8, 16, 8, -16, 0.20, -0.04, -0.08)
UI.SpecialFX:Register("shaman_air", [[Spells\Monk_rushingjadewind_grey.m2]], -8, 16, 8, -16, 1.8, 0, 2)
UI.SpecialFX:Register("shaman_water", [[Spells\Flowingwater_high.m2]], -8, 16, 8, -16, 0.008, -0.02, -0.22)
local specEffects = {
	[EARTH_TOTEM_SLOT] 	= "shaman_earth",
	[FIRE_TOTEM_SLOT] 	= "shaman_fire",
	[WATER_TOTEM_SLOT] 	= "shaman_water",
	[AIR_TOTEM_SLOT] 		= "shaman_air",
};
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
	local bar = self.TotemBars
	local size = db.classbar.height
	local width = size * totemMax
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
	for i = 1, totemMax do
		bar[i].holder:ClearAllPoints()
		bar[i].holder:SetHeight(size)
		bar[i].holder:SetWidth(size)
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		if i==1 then
			bar[i].holder:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		else
			bar[i].holder:SetPoint("LEFT", bar[i - 1].holder, "RIGHT", -1, 0)
		end
	end
end
--[[
##########################################################
SHAMAN
##########################################################
]]--
local SFXUpdate = function(self, value)
	if(not value) then return end
	if(not self.FX:IsShown()) then
		if(value > 0.02) then
			self.FX:Show()
			self.FX:UpdateEffect()
		end
	elseif(value <= 0.02) then
		self.FX:Hide()
	end
end

function MOD:CreateClassBar(playerFrame)
	local bar = CreateFrame("Frame",nil,playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)
	for i=1, totemMax do
		local iconfile = totemTextures[totemPriorities[i]]
		local holder = CreateFrame("Frame", nil, bar)
		holder:SetFrameLevel(bar:GetFrameLevel() - 1)

		bar[i] = CreateFrame("StatusBar",nil,holder)
		bar[i]:SetAllPoints(holder)
		bar[i]:SetStatusBarTexture(iconfile)
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
		hooksecurefunc(bar[i], "SetValue", SFXUpdate)
		bar[i].noupdate=true;

		bar[i].backdrop = holder:CreateTexture(nil,"BACKGROUND")
		bar[i].backdrop:SetAllPoints(holder)
		bar[i].backdrop:SetTexture(iconfile)
		bar[i].backdrop:SetDesaturated(true)
		bar[i].backdrop:SetVertexColor(0.2,0.2,0.2,0.7)

		bar[i]:EnableMouse(true)

		bar[i].holder = holder

		UI.SpecialFX:SetFXFrame(bar[i], specEffects[totemPriorities[i]], true)
		bar[i].FX:SetFrameLevel(bar:GetFrameLevel())
	end

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	UI:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = totemMax;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.TotemBars = bar
	return 'TotemBars'
end
