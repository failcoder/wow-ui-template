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
if(UI.class ~= "HUNTER") then return end 

UI.SpecialFX:Register("trap_fire", [[Spells\Fireshot_missile.m2]], -12, 12, 12, -12, 0.4, 0, 0.2)
UI.SpecialFX:Register("trap_ice", [[Spells\Frostshot_missile.m2]], -12, 12, 12, -12, 0.4, 0, 0.18)
UI.SpecialFX:Register("trap_frost", [[Spells\Blindingshot_missile.m2]], -12, 12, 12, -12, 0.4, -0.2, 0.3)
UI.SpecialFX:Register("trap_snake", [[Spells\Poisonshot_missile.m2]], -12, 12, 12, -12, 0.4, 0, -0.21)
local specEffects = { 
	[1] = "trap_fire", 
	[2] = "trap_ice", 
	[3] = "trap_frost"
};
local HAS_SNAKE_TRAP = false;
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
	local bar = self.HunterTraps;
	local max = self.MaxClassPower;
	local size = db.classbar.height + 10
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
		bar[i]:ClearAllPoints()
		bar[i]:SetHeight(size)
		bar[i]:SetWidth(size)
		if i==1 then 
			bar[i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		else 
			bar[i]:SetPoint("LEFT", bar[i - 1], "RIGHT", -1, 0) 
		end
	end 
end 
--[[ 
########################################################## 
MAGE CHARGES
##########################################################
]]--
local TrapUpdate = function(self, isReady)
	if(isReady) then
		if(not self.FX:IsShown()) then	
			self.FX:Show()
		end
		self.FX:UpdateEffect()
	else
		self.FX:Hide()
	end
end

local SnakeTrapUpdate = function(self, isReady, isSnake, bypass)
	if((isSnake ~= nil) and (isSnake ~= HAS_SNAKE_TRAP)) then
		if(isSnake == true) then
			specEffects[3] = "trap_snake"
		else
			specEffects[3] = "trap_frost"
		end
		HAS_SNAKE_TRAP = isSnake

		self.FX:SetEffect(specEffects[3])
	end

	if(not bypass) then
		if(isReady) then
			if(not self.FX:IsShown()) then	
				self.FX:Show()
			end
			self.FX:UpdateEffect()
		else
			self.FX:Hide()
		end
	end
end

function MOD:CreateClassBar(playerFrame)
	local max = 3
	local bar = CreateFrame("Frame",nil,playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)

	for i = 1, max do 
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i]:SetStatusBarTexture("Interface\\AddOns\\CUSTOM_UI_UnitFrames\\assets\\Class\\HUNTER-TRAP")
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		bar[i]:SetOrientation("VERTICAL")
		bar[i].noupdate = true;

		bar[i].bg = bar[i]:CreateTexture(nil, "BACKGROUND")
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture("Interface\\AddOns\\CUSTOM_UI_UnitFrames\\assets\\Class\\HUNTER-TRAP-BG");

		local effectName = specEffects[i]
		UI.SpecialFX:SetFXFrame(bar[i], effectName)
	end

	bar[1].Update = TrapUpdate
	bar[2].Update = TrapUpdate
	bar[3].Update = SnakeTrapUpdate

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	UI:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.HunterTraps = bar
	return 'HunterTraps' 
end 