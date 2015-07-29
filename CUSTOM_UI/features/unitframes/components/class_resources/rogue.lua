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
if(UI.class ~= "ROGUE") then return end
--[[
##########################################################
LOCALS
##########################################################
]]--
local TRACKER_FONT = [[Interface\AddOns\CUSTOM_UI\media\fonts\Combo.ttf]];
local EMPTY_TEXTURE = [[Interface\AddOns\CUSTOM_UI\media\textures\EMPTY]];
local BLOOD_TEXTURE = [[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\COMBO-ANIMATION]];
local ICON_BG = [[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\ROGUE-SMOKE]];
local ICON_ANTI = [[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\ROGUE-ANTICIPATION]];
local ICON_FILE = [[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\ROGUE]];
local ICON_COORDS = {
	{0,0.5,0,0.5},
	{0.5,1,0,0.5},
	{0,0.5,0.5,1},
	{0.5,1,0.5,1},
};
local cpointColor = {
	{0.69,0.31,0.31},
	{0.69,0.31,0.31},
	{0.65,0.63,0.35},
	{0.65,0.63,0.35},
	{0.33,0.59,0.33}
};
--[[
##########################################################
POSITIONING
##########################################################
]]--
local OnMove = function()
	UI.db.UnitFrames.player.classbar.detachFromFrame = true
end

local ShowPoint = function(self)
	self.FX:SetEffect("default")
end 

local HidePoint = function(self)
	local coords = ICON_COORDS[random(2,4)];
	self.Icon:SetTexCoord(coords[1],coords[2],coords[3],coords[4])
end

local Reposition = function(self)
	local db = UI.db.UnitFrames.player
	local bar = self.HyperCombo;
	if not db then return end
	local height = db.classbar.height
	local width = height * 3;
	local textwidth = height * 1.25;

	bar.Holder:SetSize(width, height)

	if(not db.classbar.detachFromFrame) then
		UI:ResetAnchors(L["Classbar"])
	end

	local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
	if holderUpdate then
	  holderUpdate(bar.Holder)
	end

	bar:ClearAllPoints()
	bar:SetAllPoints(bar.Holder)

	local points = bar.Combo;
	local max = MAX_COMBO_POINTS;
	local size = height + 4
	points:ClearAllPoints()
	points:SetAllPoints(bar)
	if(db.classbar.altComboPoints) then
		for i = 1, max do
			points[i].FX:SetAlpha(0)
			points[i]:ClearAllPoints()
			points[i]:SetSize(size, size)
			points[i].Icon:SetTexture(ICON_FILE)
			points[i].Icon:ClearAllPoints()
			points[i].Icon:SetAllPoints(points[i])
			if(points[i].Blood) then
				points[i].Blood:SetTexture(BLOOD_TEXTURE)
				points[i].Blood:ClearAllPoints()
				points[i].Blood:SetAllPoints(points[i])
			end
			if i==1 then
				points[i]:SetPoint("LEFT", points)
			else
				points[i]:SetPoint("LEFT", points[i - 1], "RIGHT", -8, 0)
			end
		end
		bar.PointShow = nil;
		bar.PointHide = HidePoint;
	else
		for i = 1, max do
			points[i].FX:SetAlpha(1)
			points[i]:ClearAllPoints()
			points[i]:SetSize(size, size)
			points[i].Icon:SetTexture(EMPTY_TEXTURE)
			if(points[i].Blood) then
				points[i].Blood:SetTexture(EMPTY_TEXTURE)
			end
			if i==1 then
				points[i]:SetPoint("LEFT", points)
			else
				points[i]:SetPoint("LEFT", points[i - 1], "RIGHT", -8, 0)
			end
		end
		bar.PointShow = ShowPoint;
		bar.PointHide = nil;
	end

	if(bar.Guile) then
		bar.Guile:SetFont(TRACKER_FONT, height, 'OUTLINE')
	end
end
--[[
##########################################################
ROGUE COMBO TRACKER
##########################################################
]]--
function MOD:CreateClassBar(playerFrame)
	local max = 5
	local size = 30
	local coords

	local bar = CreateFrame("Frame", nil, playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)

	bar.Combo = CreateFrame("Frame",nil,bar)
	for i = 1, max do
		local coords = ICON_COORDS[random(2,4)]
		local cpoint = CreateFrame('Frame', nil, bar.Combo)
		cpoint:SetSize(size,size)

		UI.SpecialFX:SetFXFrame(cpoint, "default")

		local icon = cpoint:CreateTexture(nil,"OVERLAY",nil,1)
		icon:SetAllPoints(cpoint)
		icon:SetTexture(ICON_FILE)
		icon:SetBlendMode("BLEND")
		icon:SetTexCoord(coords[1],coords[2],coords[3],coords[4])
		cpoint.Icon = icon

		local blood = cpoint:CreateTexture(nil,"OVERLAY",nil,2)
		blood:SetSize(size,size)
		blood:SetPoint("BOTTOMRIGHT",cpoint,12,-12)
		blood:SetTexture([[Interface\Addons\CUSTOM_UI_UnitFrames\assets\Class\COMBO-ANIMATION]])
		blood:SetBlendMode("ADD")
		
		UI.Animate:Sprite4(blood,0.08,2,true)
		cpoint.Blood = blood

		local anti = CreateFrame('Frame',nil,bar.Combo)
		anti:WrapPoints(cpoint, 8, 8)
		anti:SetFrameLevel(bar.Combo:GetFrameLevel() - 2)

		anti.icon = anti:CreateTexture(nil,"BACKGROUND",nil,-1)
		anti.icon:SetPoint("TOPLEFT", anti, "TOPLEFT", -8, 0)
		anti.icon:SetPoint("BOTTOMRIGHT", anti, "BOTTOMRIGHT", 6, -2)
		anti.icon:SetTexture(ICON_ANTI)
		anti:Hide()
		cpoint.Anticipation = anti

		bar.Combo[i] = cpoint
	end

	bar.PointShow = ShowPoint;
	bar.PointHide = HidePoint;

	local guile = bar:CreateFontString(nil, 'OVERLAY', nil, 7)
	guile:SetPoint("RIGHT", bar, "LEFT", 0, -3)
	guile:SetFont(TRACKER_FONT, 30, 'OUTLINE')
	guile:SetTextColor(1,1,1)

	bar.Guile = guile;

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	UI:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = 5;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.HyperCombo = bar
	return 'HyperCombo'
end
