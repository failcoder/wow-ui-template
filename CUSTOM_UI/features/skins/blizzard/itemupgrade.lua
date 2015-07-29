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
ITEMUPGRADE UI MODR
##########################################################
]]--
local function ItemUpgradeStyle()
	if UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.itemUpgrade ~= true then
		 return 
	end 
	
	UI.API:Set("Window", ItemUpgradeFrame, true)

	UI.API:Set("CloseButton", ItemUpgradeFrameCloseButton)
	ItemUpgradeFrameUpgradeButton:RemoveTextures()
	ItemUpgradeFrameUpgradeButton:SetStyle("Button")
	ItemUpgradeFrame.ItemButton:RemoveTextures()
	ItemUpgradeFrame.ItemButton:SetStyle("ActionSlot")
	ItemUpgradeFrame.ItemButton.IconTexture:InsetPoints()
	hooksecurefunc('ItemUpgradeFrame_Update', function()
		if GetItemUpgradeItemInfo() then
			ItemUpgradeFrame.ItemButton.IconTexture:SetAlpha(1)
			ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
		else
			ItemUpgradeFrame.ItemButton.IconTexture:SetAlpha(0)
		end 
	end)
	ItemUpgradeFrameMoneyFrame:RemoveTextures()
	ItemUpgradeFrame.FinishedGlow:Die()
	ItemUpgradeFrame.ButtonFrame:DisableDrawLayer('BORDER')
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ItemUpgradeUI",ItemUpgradeStyle)