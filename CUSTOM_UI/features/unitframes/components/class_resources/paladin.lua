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
if(UI.class ~= "PALADIN") then return end 

--UI.SpecialFX:Register("holypower", [[Spells\Holy_missile_low.m2]], -12, 12, 12, -12, 1.5, 0, 0)
UI.SpecialFX:Register("holypower", [[Spells\Holylight_impact_head.m2]], -12, 12, 12, -12, 0.8, 0, -0.4)
--UI.SpecialFX:Register("holypower", [[Spells\Paladin_healinghands_state_01.m2]], -12, 12, 12, -12, 1.2, 0, 0)
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--

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
	local bar = self.HolyPower;
	local max = self.MaxClassPower;
	local size = db.classbar.height + 4;
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
	for i = 1, max do
		bar[i].holder:ClearAllPoints()
		bar[i].holder:SetHeight(size)
		bar[i].holder:SetWidth(size)
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		if i==1 then 
			bar[i].holder:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		else 
			bar[i].holder:SetPoint("LEFT", bar[i - 1].holder, "RIGHT", -4, 0) 
		end
	end 
end 

local Update = function(self, event, unit, powerType)
	if self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER') then return end 
	local bar = self.HolyPower;
	local baseCount = UnitPower('player',SPELL_POWER_HOLY_POWER)
	local maxCount = UnitPowerMax('player',SPELL_POWER_HOLY_POWER)
	for i=1,maxCount do 
		if i <= baseCount then 
			bar[i]:SetAlpha(1)
			if(not bar[i].holder.FX:IsShown()) then
				bar[i].holder.FX:Show()
				bar[i].holder.FX:UpdateEffect()
			end
		else 
			bar[i]:SetAlpha(0)
			bar[i].holder.FX:Hide()
		end 
		if i > maxCount then 
			bar[i]:Hide()
		else 
			bar[i]:Show()
		end 
	end
	self.MaxClassPower = maxCount
end
--[[ 
########################################################## 
PALADIN
##########################################################
]]--
local ShowLink = function(self) self.holder:Show() end
local HideLink = function(self) self.holder:Hide() end

function MOD:CreateClassBar(playerFrame)
	local max = 5
	local bar = CreateFrame("Frame", nil, playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)

	for i = 1, max do
		local underlay = CreateFrame("Frame", nil, bar);
		UI.SpecialFX:SetFXFrame(underlay, "holypower", true)
		underlay.FX:SetFrameStrata("BACKGROUND")
		underlay.FX:SetFrameLevel(0)

		bar[i] = CreateFrame("StatusBar", nil, underlay)
		bar[i]:SetAllPoints(underlay)
		bar[i]:SetStatusBarTexture("Interface\\AddOns\\CUSTOM_UI_UnitFrames\\assets\\Class\\PALADIN-HAMMER-FG")
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		bar[i]:SetStatusBarColor(0.9,0.9,0.8)

		bar[i].bg = underlay:CreateTexture(nil,"BORDER")
		bar[i].bg:SetAllPoints(underlay)
		bar[i].bg:SetTexture("Interface\\AddOns\\CUSTOM_UI_UnitFrames\\assets\\Class\\PALADIN-HAMMER-BG")
		bar[i].bg:SetVertexColor(0,0,0)

		bar[i].holder = underlay
		--bar[i]:SetScript("OnShow", ShowLink)
		--bar[i]:SetScript("OnHide", HideLink)
	end 
	bar.Override = Update;
	
	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	UI:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.HolyPower = bar
	return 'HolyPower'  
end 