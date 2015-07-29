--[[
##########################################################
S V U I   By: Munglunch
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'WARLOCK') then return end;

local UI = select(2, ...)

--[[ WARLOCK FILTERS ]]--

UI.defaults.Filters["BuffWatch"] = {};