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
TAXIFRAME MODR
##########################################################
]]--
local function SocialStyle()
	MOD.Debugging = true;
	if UI.db.Skins.blizzard.enable ~= true then
		 return 
	end
	--print("Skinning Social")
	UI.API:Set("Window", SocialPostFrame)
	--UI.API:Set("Tooltip", _G.StoreTooltip)
	--print("Skinning Completed")
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_SocialUI", SocialStyle)