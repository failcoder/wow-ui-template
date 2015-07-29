--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local UI = _G['CUSTOM_UI'];
local L = UI.L;
local MOD = UI.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
REFORGING MODR
##########################################################
]]--
local function ReforgingStyle()
	if UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.reforge ~= true then return end 
	
	UI.API:Set("Window", ReforgingFrame, true)

	ReforgingFrame.ButtonFrame:RemoveTextures()
	ReforgingFrameReforgeButton:ClearAllPoints()
	ReforgingFrameReforgeButton:SetPoint("LEFT", ReforgingFrameRestoreButton, "RIGHT", 2, 0)
	ReforgingFrameReforgeButton:SetPoint("BOTTOMRIGHT", -3, 3)
	ReforgingFrame.RestoreMessage:SetTextColor(1, 1, 1)

	ReforgingFrameRestoreButton:RemoveTextures()
	ReforgingFrameReforgeButton:RemoveTextures()
	ReforgingFrameRestoreButton:SetStyle("Button")
	ReforgingFrameReforgeButton:SetStyle("Button")

	ReforgingFrame.ItemButton:RemoveTextures()
	ReforgingFrame.ItemButton:SetStyle("ActionSlot")
	ReforgingFrame.ItemButton.IconTexture:InsetPoints()
	hooksecurefunc("ReforgingFrame_Update", function(k)
		local w, x, u, y, z, A = GetReforgeItemInfo()
		if x then
			 ReforgingFrame.ItemButton.IconTexture:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
		else
			 ReforgingFrame.ItemButton.IconTexture:SetTexture("")
		end 
	end)
	UI.API:Set("CloseButton", ReforgingFrameCloseButton)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ReforgingUI",ReforgingStyle)