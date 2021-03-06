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
ALDAMAGEMETER
##########################################################
]]--
local function StyleALDamageMeter()
  assert(_G['alDamagerMeterFrame'], "AddOn Not Loaded")
  
  alDamageMeterFrame.bg:Die()
  UI.API:Set("Frame", alDamageMeterFrame)
  alDamageMeterFrame:HookScript('OnShow', function()
    if InCombatLockdown() then return end 
    if MOD.Docklet:IsEmbedded("alDamageMeter") then
    	MOD.Docklet:Show()
    end
  end)
end
MOD:SaveAddonStyle("alDamageMeter", StyleALDamageMeter) 