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
local function StoreStyle()
	-- if UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.store ~= true then
	-- 	 return 
	-- end

	--UI.API:Set("Window", StoreFrame)
	UI.API:Set("Tooltip", _G.StoreTooltip)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_StoreUI", StoreStyle)