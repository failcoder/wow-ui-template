--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################

########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local error 	= _G.error;
local pcall 	= _G.pcall;
local assert 	= _G.assert;
local tostring 	= _G.tostring;
local tonumber 	= _G.tonumber;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
local find, format, len, split = string.find, string.format, string.len, string.split;
local match, sub, join = string.match, string.sub, string.join;
local gmatch, gsub = string.gmatch, string.gsub;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;  -- Basic
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local UI = select(2, ...)
local L = UI.L
local Reports = UI.Reports;
--[[ 
########################################################## 
REPORT TEMPLATE
##########################################################
]]--
local REPORT_NAME = "";
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = "|cff%s%s|r";
--UI.Media.color.green
--UI.Media.color.normal
--r, g, b = 0.8, 0.8, 0.8
--local c = UI.Media.color.green
--r, g, b = c[1], c[2], c[3]
local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\CUSTOM_UI\media\icons\CUSTOM_UI]]
});

Report.events = {"PLAYER_ENTERING_WORLD"};

Report.OnInit = function(self)
	if(not self.InnerData) then
		self.InnerData = {}
	end
	-- DO STUFF
end

Report.OnEvent = function(self, event, ...)
	-- DO STUFF
	self.text:SetFormattedText(TEXT_PATTERN, HEX_COLOR, REPORT_NAME)
end

Report.OnClick = function(self, button)
	-- DO STUFF
end

Report.OnEnter = function(self)
	Reports:SetDataTip(self)
	-- DO STUFF
	Reports:ShowDataTip()
end

Report.OnLeave = function(self, button)
	-- DO STUFF
end

Report.OnUpdate = function(self, button)
	-- DO STUFF
end