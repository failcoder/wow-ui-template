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
ITEMSOCKETING MODR
##########################################################
]]--
local function ItemSocketStyle()
	if UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.socket ~= true then return end 
	ItemSocketingFrame:RemoveTextures()
	ItemSocketingFrame:SetStyle("Frame", "Window2")
	ItemSocketingFrameInset:Die()
	ItemSocketingScrollFrame:RemoveTextures()
	ItemSocketingScrollFrame:SetStyle("Frame", "Inset", true)
	UI.API:Set("ScrollBar", ItemSocketingScrollFrameScrollBar, 2)
	for j = 1, MAX_NUM_SOCKETS do 
		local i = _G[("ItemSocketingSocket%d"):format(j)];
		local C = _G[("ItemSocketingSocket%dBracketFrame"):format(j)];
		local D = _G[("ItemSocketingSocket%dBackground"):format(j)];
		local E = _G[("ItemSocketingSocket%dIconTexture"):format(j)];
		i:RemoveTextures()
		i:SetStyle("Button")
		i:SetStyle("!_Frame", "Button", true)
		C:Die()
		D:Die()
		E:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
		E:InsetPoints()
	end 
	hooksecurefunc("ItemSocketingFrame_Update", function()
		local max = GetNumSockets()
		for j=1, max do 
			local i = _G[("ItemSocketingSocket%d"):format(j)];
			local G = GetSocketTypes(j);
			local color = GEM_TYPE_INFO[G]
			i:SetBackdropColor(color.r, color.g, color.b, 0.15);
			i:SetBackdropBorderColor(color.r, color.g, color.b)
		end 
	end)
	ItemSocketingFramePortrait:Die()
	ItemSocketingSocketButton:ClearAllPoints()
	ItemSocketingSocketButton:SetPoint("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -5, 5)
	ItemSocketingSocketButton:SetStyle("Button")
	UI.API:Set("CloseButton", ItemSocketingFrameCloseButton)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ItemSocketingUI",ItemSocketStyle)