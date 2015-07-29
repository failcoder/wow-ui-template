--[[
##########################################################
S V U I   By: Munglunch
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'HUNTER') then return end;

local UI = select(2, ...)

--[[ HUNTER FILTERS ]]--

UI.defaults.Filters["BuffWatch"] = {};