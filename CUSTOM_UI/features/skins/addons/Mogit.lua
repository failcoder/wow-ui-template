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
MOGIT
##########################################################
]]--
local function StyleMogItPreview()
	for i = 1, 99 do
		local MogItGearSlots = {
			"HeadSlot",
			"ShoulderSlot",
			"BackSlot",
			"ChestSlot",
			"ShirtSlot",
			"TabardSlot",
			"WristSlot",
			"HandsSlot",
			"WaistSlot",
			"LegsSlot",
			"FeetSlot",
			"MainHandSlot",
			"SecondaryHandSlot",
		}
		for _, object in pairs(MogItGearSlots) do
			if _G["MogItPreview"..i..object] then
				UI.API:Set("ItemButton", _G["MogItPreview"..i..object])
				_G["MogItPreview"..i..object]:SetPushedTexture(nil)
				_G["MogItPreview"..i..object]:SetHighlightTexture(nil)
			end
		end
		if _G["MogItPreview"..i] then UI.API:Set("Frame", _G["MogItPreview"..i]) end
		if _G["MogItPreview"..i.."CloseButton"] then UI.API:Set("CloseButton", _G["MogItPreview"..i.."CloseButton"]) end
		if _G["MogItPreview"..i.."Inset"] then _G["MogItPreview"..i.."Inset"]:RemoveTextures(true) end
		if _G["MogItPreview"..i.."Activate"] then _G["MogItPreview"..i.."Activate"]:SetStyle("Button") end
	end
end

local function StyleMogIt()
	assert(MogItFrame, "AddOn Not Loaded")
	
	UI.API:Set("Frame", MogItFrame)
	MogItFrameInset:RemoveTextures(true)
	UI.API:Set("Frame", MogItFilters)
	MogItFiltersInset:RemoveTextures(true)

	hooksecurefunc(MogIt, "CreatePreview", StyleMogItPreview)
	UI.API:Set("Tooltip", MogItTooltip)
	UI.API:Set("CloseButton", MogItFrameCloseButton)
	UI.API:Set("CloseButton", MogItFiltersCloseButton)
	MogItFrameFiltersDefaults:RemoveTextures(true)
	MogItFrameFiltersDefaults:SetStyle("Button")
	UI.API:Set("ScrollBar", MogItScroll)
	UI.API:Set("ScrollBar", MogItFiltersScrollScrollBar)
end
MOD:SaveAddonStyle("MogIt", StyleMogIt)