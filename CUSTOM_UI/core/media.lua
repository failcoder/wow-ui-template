--[[
##########################################################
S V U I   By: Munglunch
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local select  = _G.select;
local unpack  = _G.unpack;
local pairs   = _G.pairs;
local ipairs  = _G.ipairs;
local type    = _G.type;
local print   = _G.print;
local string  = _G.string;
local math    = _G.math;
local table   = _G.table;
local GetTime = _G.GetTime;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local floor, modf = math.floor, math.modf;
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;
--[[
##########################################################
LOCALIZED GLOBALS
##########################################################
]]--
local NAMEPLATE_FONT      = _G.NAMEPLATE_FONT
local CHAT_FONT_HEIGHTS   = _G.CHAT_FONT_HEIGHTS
local STANDARD_TEXT_FONT  = _G.STANDARD_TEXT_FONT
local UNIT_NAME_FONT      = _G.UNIT_NAME_FONT
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS   = _G.RAID_CLASS_COLORS
local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT  = _G.UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local UI = select(2, ...)
local UI_Registry = Librarian("Registry")
local L = UI.L
local classToken = select(2,UnitClass("player"))
--[[
##########################################################
DEFINE SHARED MEDIA
##########################################################
]]--
local LSM = _G.LibStub("LibSharedMedia-3.0")

LSM:Register("background", "CUSTOM_UI Default BG", [[Interface\AddOns\CUSTOM_UI\media\backgrounds\DEFAULT]])
LSM:Register("background", "CUSTOM_UI Transparent BG", [[Interface\AddOns\CUSTOM_UI\media\backgrounds\TRANSPARENT]])
LSM:Register("background", "CUSTOM_UI Button BG", [[Interface\AddOns\CUSTOM_UI\media\backgrounds\BUTTON]])
LSM:Register("border", "CUSTOM_UI Border", [[Interface\AddOns\CUSTOM_UI\media\borders\DEFAULT]])
LSM:Register("border", "CUSTOM_UI Border 2", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("border", "CUSTOM_UI Inset Shadow", [[Interface\AddOns\CUSTOM_UI\media\borders\INSET]])
LSM:Register("border", "CUSTOM_UI Shadow Border", [[Interface\AddOns\CUSTOM_UI\media\borders\SHADOW]])
LSM:Register("statusbar", "CUSTOM_UI BasicBar", [[Interface\AddOns\CUSTOM_UI\media\statusbars\DEFAULT]])
LSM:Register("sound", "Whisper Alert", [[Interface\AddOns\CUSTOM_UI\media\sounds\whisper.mp3]])
LSM:Register("font", "CUSTOM_UI Default Font", [[Interface\AddOns\CUSTOM_UI\media\fonts\Default.ttf]],LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
--[[
##########################################################
CREATE AND POPULATE MEDIA DATA
##########################################################
]]--
do
	UI.Mediadefaults = {
		["extended"] = {},
		["shared"] = {
			["font"] = {
				["default"]     = {file = "CUSTOM_UI Default Font",  size = 12,  outline = "OUTLINE"},
				["dialog"]      = {file = "CUSTOM_UI Default Font",  size = 12,  outline = "OUTLINE"},
				["title"]       = {file = "CUSTOM_UI Default Font",  size = 16,  outline = "OUTLINE"},
				["number"]      = {file = "CUSTOM_UI Default Font",   size = 11,  outline = "OUTLINE"},
				["number_big"]  = {file = "CUSTOM_UI Default Font",   size = 18,  outline = "OUTLINE"},
				["header"]      = {file = "CUSTOM_UI Default Font",   size = 18,  outline = "OUTLINE"},
				["combat"]      = {file = "CUSTOM_UI Default Font",   size = 64,  outline = "OUTLINE"},
				["alert"]       = {file = "CUSTOM_UI Default Font",    size = 20,  outline = "OUTLINE"},
				["flash"]      	= {file = "CUSTOM_UI Default Font",    size = 18,  outline = "OUTLINE"},
				["zone"]      	= {file = "CUSTOM_UI Default Font",     size = 16,  outline = "OUTLINE"},
				["caps"]      	= {file = "CUSTOM_UI Default Font",     size = 12,  outline = "OUTLINE"},
				["aura"]      	= {file = "CUSTOM_UI Default Font",   size = 10,  outline = "OUTLINE"},
				["data"]      	= {file = "CUSTOM_UI Default Font",   size = 11,  outline = "OUTLINE"},
				["narrator"]    = {file = "CUSTOM_UI Default Font", size = 12,  outline = "OUTLINE"},
				["lootdialog"]  = {file = "CUSTOM_UI Default Font",  size = 14,  outline = "OUTLINE"},
				["lootnumber"]  = {file = "CUSTOM_UI Default Font",   size = 11,  outline = "OUTLINE"},
				["rolldialog"]  = {file = "CUSTOM_UI Default Font",  size = 14,  outline = "OUTLINE"},
				["rollnumber"]  = {file = "CUSTOM_UI Default Font",   size = 11,  outline = "OUTLINE"},
				["tipdialog"]   = {file = "CUSTOM_UI Default Font",  size = 12,  outline = "NONE"},
				["tipheader"]   = {file = "CUSTOM_UI Default Font",  size = 14,  outline = "NONE"},
				["pixel"]       = {file = "CUSTOM_UI Default Font",    size = 8, outline = "MONOCHROMEOUTLINE"},
			},
			["statusbar"] = {
				["default"]   	= {file = "CUSTOM_UI BasicBar",  	offset = 0},
			},
			["background"] = {
				["default"]     = {file = "CUSTOM_UI Default BG",  		size = 0, tiled = false},
				["transparent"] = {file = "CUSTOM_UI Transparent BG",	size = 0, tiled = false},
				["button"]      = {file = "CUSTOM_UI Button BG",  		size = 0, tiled = false},
			},
			["border"] = {
				["default"] 	= {file = "CUSTOM_UI Border", 		  	size = 1},
				["transparent"] = {file = "CUSTOM_UI Border", 			size = 1},
				["button"]      = {file = "CUSTOM_UI Border", 			size = 1},
				["shadow"]      = {file = "CUSTOM_UI Shadow Border",   	size = 3},
				["inset"]       = {file = "CUSTOM_UI Inset Shadow",   	size = 6},
			},
		},
		["font"] = {
			["default"]   	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Default.ttf]],
			["dialog"]    	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Default.ttf]],
			["number"]    	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Numbers.ttf]],
			["combat"]    	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Combat.ttf]],
			["zone"]      	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Zone.ttf]],
			["alert"]     	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Alert.ttf]],
			["caps"]      	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Caps.ttf]],
			["narrator"]  	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Narrative.ttf]],
			["flash"]     	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Flash.ttf]],
			["pixel"]     	= [[Interface\AddOns\CUSTOM_UI\media\fonts\Pixel.ttf]],
		},
		["statusbar"] = {
			["default"]   	= [[Interface\AddOns\CUSTOM_UI\media\statusbars\DEFAULT]],
		},
		["background"] = {
			["default"] 	= [[Interface\AddOns\CUSTOM_UI\media\backgrounds\DEFAULT]],
			["transparent"] = [[Interface\AddOns\CUSTOM_UI\media\backgrounds\TRANSPARENT]],
			["button"]      = [[Interface\AddOns\CUSTOM_UI\media\backgrounds\BUTTON]],
		},
		["border"] = {
			["default"] 	= [[Interface\AddOns\CUSTOM_UI\media\borders\DEFAULT]],
			["button"]      = [[Interface\AddOns\CUSTOM_UI\media\borders\DEFAULT]],
			["shadow"]      = [[Interface\AddOns\CUSTOM_UI\media\borders\SHADOW]],
			["inset"]       = [[Interface\AddOns\CUSTOM_UI\media\borders\INSET]],
		},
		["color"] = {
			["default"]     = {0.15, 0.15, 0.15, 1},
			["secondary"]   = {0.2, 0.2, 0.2, 1},
			["button"]      = {0.2, 0.2, 0.2, 1},
			["special"]     = {0.37, 0.32, 0.29, 1},
			["specialdark"] = {.23, .22, .21, 1},
			["unique"]      = {0.32, 0.258, 0.21, 1},
			["paper"]     	= {0.37, 0.32, 0.29, 1},
			["dusty"]   		= {.28, .27, .26, 1},
			["class"]       = {r1, g1, b1, 1},
			["bizzaro"]     = {ir1, ig1, ib1, 1},
			["medium"]      = {0.47, 0.47, 0.47},
			["dark"]        = {0.1, 0.1, 0.1, 1},
			["darkest"]     = {0, 0, 0, 1},
			["light"]       = {0.95, 0.95, 0.95, 1},
			["light2"]      = {0.65, 0.65, 0.65, 1},
			["lightgrey"]   = {0.32, 0.35, 0.38, 1},
			["highlight"]   = {0.28, 0.75, 1, 1},
			["checked"]     = {0.25, 0.9, 0.08, 1},
			["green"]       = {0.25, 0.9, 0.08, 1},
			["blue"]        = {0.08, 0.25, 0.82, 1},
			["tan"]         = {0.4, 0.32, 0.23, 1},
			["red"]         = {0.9, 0.08, 0.08, 1},
			["yellow"]      = {1, 1, 0, 1},
			["gold"]        = {1, 0.68, 0.1, 1},
			["transparent"] = {0, 0, 0, 0.5},
			["hinted"]      = {0, 0, 0, 0.35},
			["invisible"]   = {0, 0, 0, 0},
			["white"]       = {1, 1, 1, 1},
		},
		["bordercolor"] = {
			["default"]     = {0, 0, 0, 1},
			["class"]       = {r1, g1, b1, 1},
			["checkbox"]    = {0.1, 0.1, 0.1, 1},
		},
		["gradient"]  = {
			["default"]   	= {"VERTICAL", 0.08, 0.08, 0.08, 0.22, 0.22, 0.22},
			["secondary"]  	= {"VERTICAL", 0.08, 0.08, 0.08, 0.22, 0.22, 0.22},
			["special"]   	= {"VERTICAL", 0.33, 0.25, 0.13, 0.47, 0.39, 0.27},
			["specialdark"] = {"VERTICAL", 0.23, 0.15, 0.03, 0.33, 0.25, 0.13},
			["paper"]   	= {"VERTICAL", 0.33, 0.25, 0.13, 0.47, 0.39, 0.27},
			["dusty"] 		= {"VERTICAL", 0.12, 0.11, 0.1, 0.22, 0.21, 0.2},
			["class"]     	= {"VERTICAL", r2, g2, b2, r1, g1, b1},
			["bizzaro"]   	= {"VERTICAL", ir2, ig2, ib2, ir1, ig1, ib1},
			["medium"]    	= {"VERTICAL", 0.22, 0.22, 0.22, 0.47, 0.47, 0.47},
			["dark"]      	= {"VERTICAL", 0.02, 0.02, 0.02, 0.22, 0.22, 0.22},
			["darkest"]   	= {"VERTICAL", 0.15, 0.15, 0.15, 0, 0, 0},
			["darkest2"]  	= {"VERTICAL", 0, 0, 0, 0.12, 0.12, 0.12},
			["light"]     	= {"VERTICAL", 0.65, 0.65, 0.65, 0.95, 0.95, 0.95},
			["light2"]    	= {"VERTICAL", 0.95, 0.95, 0.95, 0.65, 0.65, 0.65},
			["highlight"] 	= {"VERTICAL", 0.3, 0.8, 1, 0.1, 0.9, 1},
			["checked"]   	= {"VERTICAL", 0.08, 0.9, 0.25, 0.25, 0.9, 0.08},
			["green"]     	= {"VERTICAL", 0.08, 0.9, 0.25, 0.25, 0.9, 0.08},
			["red"]       	= {"VERTICAL", 0.5, 0, 0, 0.9, 0.08, 0.08},
			["yellow"]    	= {"VERTICAL", 1, 0.3, 0, 1, 1, 0},
			["tan"]       	= {"VERTICAL", 0.15, 0.08, 0, 0.37, 0.22, 0.1},
			["inverse"]   	= {"VERTICAL", 0.25, 0.25, 0.25, 0.12, 0.12, 0.12},
			["icon"]      	= {"VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1},
			["white"]     	= {"VERTICAL", 0.75, 0.75, 0.75, 1, 1, 1},
		},
		["backdrop"] = {
			["default"] = {
				bgFile = [[Interface\AddOns\CUSTOM_UI\media\backgrounds\DEFAULT]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\borders\DEFAULT]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["button"] = {
				bgFile = [[Interface\AddOns\CUSTOM_UI\media\backgrounds\BUTTON]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\borders\DEFAULT]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["buttonred"] = {
				bgFile = [[Interface\AddOns\CUSTOM_UI\media\backgrounds\BUTTON]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\borders\DEFAULT]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["aura"] = {
				bgFile = [[Interface\BUTTONS\WHITE8X8]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\borders\SHADOW]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 1,
			        right = 1,
			        top = 1,
			        bottom = 1,
			    },
			},
			["glow"] = {
				bgFile = [[Interface\BUTTONS\WHITE8X8]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\borders\SHADOW]],
			    edgeSize = 3,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["tooltip"] = {
				bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\EMPTY]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["outline"] = {
				bgFile = [[Interface\AddOns\CUSTOM_UI\media\EMPTY]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\borders\DEFAULT]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["shadowoutline"] = {
				bgFile = [[Interface\AddOns\CUSTOM_UI\media\EMPTY]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\borders\SHADOW]],
			    edgeSize = 3,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["darkened"] = {
				bgFile = [[Interface\AddOns\CUSTOM_UI\media\backgrounds\DARK]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\CUSTOM_UI\media\borders\SHADOW]],
			    edgeSize = 3,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
		}
	};
end
--[[
##########################################################
SOME CORE VARS
##########################################################
]]--
UI.DialogFontDefault = "CUSTOM_UI Dialog Font";
if(GetLocale() ~= "enUS") then
	UI.DialogFontDefault = "CUSTOM_UI Default Font";
end
UI.BaseTexture 	= [[Interface\AddOns\CUSTOM_UI\media\backgrounds\DEFAULT]];
UI.NoTexture 	  = [[Interface\AddOns\CUSTOM_UI\media\EMPTY]];
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function UI:ColorGradient(perc, ...)
	if perc >= 1 then
		return select(select('#', ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end
	local num = select('#', ...) / 3
	local segment, relperc = modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

function UI:HexColor(arg1,arg2,arg3)
	local r,g,b;
	if arg1 and type(arg1) == "string" then
		local t
		if(self.Media) then
			t = self.Media.color[arg1]
			if((not t) and (self.Media.extended and self.Media.extended.unitframes)) then
				t = self.Media.extended.unitframes[arg1]
			end
		end
		if t then
			r,g,b = t[1],t[2],t[3]
		else
			r,g,b = 0,0,0
		end
	else
		r = type(arg1) == "number" and arg1 or 0;
		g = type(arg2) == "number" and arg2 or 0;
		b = type(arg3) == "number" and arg3 or 0;
	end
	r = (r < 0 or r > 1) and 0 or (r * 255)
	g = (g < 0 or g > 1) and 0 or (g * 255)
	b = (b < 0 or b > 1) and 0 or (b * 255)
	local hexString = ("%02x%02x%02x"):format(r,g,b)
	return hexString
end
--[[
##########################################################
ALTERING GLOBAL FONTS
##########################################################
]]--
local function UpdateChatFontSizes()
	_G.CHAT_FONT_HEIGHTS[1] = 8
	_G.CHAT_FONT_HEIGHTS[2] = 9
	_G.CHAT_FONT_HEIGHTS[3] = 10
	_G.CHAT_FONT_HEIGHTS[4] = 11
	_G.CHAT_FONT_HEIGHTS[5] = 12
	_G.CHAT_FONT_HEIGHTS[6] = 13
	_G.CHAT_FONT_HEIGHTS[7] = 14
	_G.CHAT_FONT_HEIGHTS[8] = 15
	_G.CHAT_FONT_HEIGHTS[9] = 16
	_G.CHAT_FONT_HEIGHTS[10] = 17
	_G.CHAT_FONT_HEIGHTS[11] = 18
	_G.CHAT_FONT_HEIGHTS[12] = 19
	_G.CHAT_FONT_HEIGHTS[13] = 20
end

hooksecurefunc("FCF_ResetChatWindows", UpdateChatFontSizes)

local function ChangeGlobalFonts()
	local fontsize = UI.Media.shared.font.default.size;
	STANDARD_TEXT_FONT = LSM:Fetch("font", UI.Media.shared.font.default.file);
	UNIT_NAME_FONT = LSM:Fetch("font", UI.Media.shared.font.caps.file);
	NAMEPLATE_FONT = STANDARD_TEXT_FONT
	UpdateChatFontSizes()
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = fontsize
end
--[[
##########################################################
FONT TEMPLATING METHODS
##########################################################
]]--
local ManagedFonts = {};

function UI:FontManager(obj, template, arg, sizeMod, styleOverride, colorR, colorG, colorB)
	if not obj then return end
	template = template or "default";
	local info = UI.Media.shared.font[template] or UI.Media.shared.font.default;
	if(not info) then return end

	local isSystemFont = false;
	if(arg and (arg == 'SYSTEM')) then
		isSystemFont = true;
	end

	local file = UI.Media.font[template] or UI.Media.font.default;
	local size = info.size;
	local outline = info.outline;

	if(styleOverride) then
		obj.___fontOutline = styleOverride;
		outline = styleOverride;
	end

	obj.___fontSizeMod = sizeMod or 0;
	obj:SetFont(file, (size + obj.___fontSizeMod), outline)

	if(arg == 'SHADOW') then
		obj:SetShadowColor(0, 0, 0, 0.75)
		obj:SetShadowOffset(2, -2)
	elseif(not isSystemFont) then
		if((not info.outline) or info.outline ~= "NONE") then
			obj:SetShadowColor(0, 0, 0, 0)
		elseif(info.outline and info.outline == "NONE") then
			obj:SetShadowColor(0, 0, 0, 0.75)
		else
			obj:SetShadowColor(0, 0, 0, 0.2)
		end
		if(not obj.noShadowOffset) then
			obj:SetShadowOffset(1, -1)
		else
			obj:SetShadowOffset(0, 0)
		end
		obj:SetJustifyH(arg or "CENTER")
		obj:SetJustifyV("MIDDLE")
	end

	if(colorR and colorG and colorB) then
		obj:SetTextColor(colorR, colorG, colorB);
	end

	if(not ManagedFonts[template]) then
		ManagedFonts[template] = {}
	end

	ManagedFonts[template][obj] = true
end

local function _shadowFont(globalName, template, sizeMod, styleOverride, cR, cG, cB)
	if(not template) then return end
	if(not _G[globalName]) then return end
	styleOverride = styleOverride or "NONE"
	UI:FontManager(_G[globalName], template, "SHADOW", sizeMod, styleOverride, cR, cG, cB);
end

local function _alterFont(globalName, template, sizeMod, styleOverride, cR, cG, cB)
	if(not template) then return end
	if(not _G[globalName]) then return end
	styleOverride = styleOverride or "NONE"
	UI:FontManager(_G[globalName], template, "SYSTEM", sizeMod, styleOverride, cR, cG, cB);
end

local function ChangeSystemFonts()
	_shadowFont("GameFontNormal", "default", 0, "NONE")
	_alterFont("GameFontWhite", "default", 0, 'OUTLINE', 1, 1, 1)
	_alterFont("GameFontWhiteSmall", "default", 0, 'NONE', 1, 1, 1)
	_alterFont("GameFontBlack", "default", 0, 'NONE', 0, 0, 0)
	_alterFont("GameFontBlackSmall", "default", -1, 'NONE', 0, 0, 0)
	_alterFont("GameFontNormalMed2", "default", 2)
	--_alterFont("GameFontNormalMed1", "default", 0)
	_alterFont("GameFontNormalLarge", "default")
	_alterFont("GameFontNormalLargeOutline", "default")
	_alterFont("GameFontHighlightSmall", "default")
	_alterFont("GameFontHighlight", "default", 1)
	_alterFont("GameFontHighlightLeft", "default", 1)
	_alterFont("GameFontHighlightRight", "default", 1)
	_alterFont("GameFontHighlightLarge2", "default", 2)
	_alterFont("SystemFont_Med1", "default")
	_alterFont("SystemFont_Med3", "default")
	_alterFont("SystemFont_Outline_Small", "default", 0, "OUTLINE")
	_alterFont("FriendsFont_Normal", "default")
	_alterFont("FriendsFont_Small", "default")
	_alterFont("FriendsFont_Large", "default", 3)
	_alterFont("FriendsFont_UserText", "default", -1)
	_alterFont("SystemFont_Small", "default", -1)
	_alterFont("GameFontNormalSmall", "default", -1)
	_alterFont("NumberFont_Shadow_Med", "default", -1, "OUTLINE")
	_alterFont("NumberFont_Shadow_Small", "default", -1, "OUTLINE")
	_alterFont("SystemFont_Tiny", "default", -1)
	_alterFont("SystemFont_Shadow_Med1", "default")
	_alterFont("SystemFont_Shadow_Med1_Outline", "default")
	_alterFont("SystemFont_Shadow_Med2", "default")
	_alterFont("SystemFont_Shadow_Med3", "default")
	_alterFont("SystemFont_Large", "default")
	_alterFont("SystemFont_Huge1", "default", 4)
	_alterFont("SystemFont_Huge1_Outline", "default", 4)
	_alterFont("SystemFont_Shadow_Small", "default")
	_alterFont("SystemFont_Shadow_Large", "default", 3)
	_alterFont("QuestFont", "dialog");
	_alterFont("QuestFont_Enormous", "zone", 15, "OUTLINE");
	_alterFont("SpellFont_Small", "dialog", 0, "OUTLINE", 1, 1, 1);
	_alterFont("SystemFont_Shadow_Outline_Large", "title", 0, "OUTLINE");
	_alterFont("SystemFont_Shadow_Outline_Huge2", "title", 8, "OUTLINE");
	_alterFont("GameFont_Gigantic", "alert", 0, "OUTLINE", 32)
	_alterFont("SystemFont_Shadow_Huge1", "alert", 0, "OUTLINE")
	_alterFont("SystemFont_OutlineThick_Huge4", "zone", 6, "OUTLINE");
	_alterFont("SystemFont_OutlineThick_WTF", "zone", 9, "OUTLINE");
	_alterFont("SystemFont_OutlineThick_WTF2", "zone", 15, "OUTLINE");
	_alterFont("QuestFont_Large", "zone", -3);
	_alterFont("QuestFont_Huge", "zone", -2);
	_alterFont("QuestFont_Super_Huge", "zone");
	_alterFont("QuestFont_Shadow_Huge", "zone");
	_alterFont("SystemFont_OutlineThick_Huge2", "zone", 2, "OUTLINE");
	_alterFont("Game18Font", "number", 1)
	_alterFont("Game24Font", "number", 3)
	_alterFont("Game27Font", "number", 5)
	_alterFont("Game30Font", "number_big")
	_alterFont("Game32Font", "number_big", 1)
	_alterFont("NumberFont_OutlineThick_Mono_Small", "number", 0, "OUTLINE")
	_alterFont("NumberFont_Outline_Huge", "number_big", 0, "OUTLINE")
	_shadowFont("NumberFont_Outline_Large", "number", 2, "OUTLINE")
	_alterFont("NumberFont_Outline_Med", "number", 1, "OUTLINE")
	_alterFont("NumberFontNormal", "number", 0, "OUTLINE")
	_alterFont("NumberFont_GameNormal", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRight", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRightRed", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRightYellow", "number", 0, "OUTLINE")
	_alterFont("GameTooltipHeader", "tipheader")
	_alterFont("Tooltip_Med", "tipdialog")
	_alterFont("Tooltip_Small", "tipdialog", -1)
	_alterFont("SystemFont_Shadow_Huge3", "combat", 0, "OUTLINE")
	_alterFont("CombatTextFont", "combat", 64, "OUTLINE")
end

local function _defineFont(globalName, template)
	if(not template) then return end
	if(not _G[globalName]) then return end
	UI:FontManager(_G[globalName], template);
end

local function UpdateFontTemplate(template)
	template = template or "default";
	local info = UI.Media.shared.font[template];
	if(not info) then return end
	local file = LSM:Fetch("font", info.file);
	local size = info.size;
	local line = info.outline;
	local list = ManagedFonts[template];
	if(not list) then return end
	for object in pairs(list) do
		if object then
			if(object.___fontOutline) then
				object:SetFont(file, (size + object.___fontSizeMod), object.___fontOutline);
			else
				object:SetFont(file, (size + object.___fontSizeMod), line);
			end
		else
			ManagedFonts[template][object] = nil;
		end
	end
end

local function UpdateAllFontTemplates()
	for template, _ in pairs(ManagedFonts) do
		UpdateFontTemplate(template)
	end
	ChangeGlobalFonts();
end

local function UpdateFontGroup(...)
	for i = 1, select('#', ...) do
		local template = select(i, ...)
		if not template then break end
		UpdateFontTemplate(template)
	end
end

UI.Events:On("ALL_FONTS_UPDATED", UpdateAllFontTemplates, true);
UI.Events:On("FONT_GROUP_UPDATED", UpdateFontGroup, true);

function UI:GenerateFontOptionGroup(groupName, groupCount, groupOverview, groupList)
    self.Options.args.Fonts.args.fontGroup.args[groupName] = {
        order = groupCount,
        type = "group",
        name = groupName,
        args = {
            overview = {
                order = 1,
                name = groupOverview,
                type = "description",
                width = "full",
            },
            spacer0 = {
                order = 2,
                name = "",
                type = "description",
                width = "full",
            },
        },
    };

    local orderCount = 3;
    for template, info in pairs(groupList) do
        self.Options.args.Fonts.args.fontGroup.args[groupName].args[template] = {
            order = orderCount + info.order,
            type = "group",
            guiInline = true,
            name = info.name,
            get = function(key)
                return self.Media.shared.font[template][key[#key]]
            end,
            set = function(key,value)
                self.Media.shared.font[template][key[#key]] = value;
                if(groupCount == 1) then
                    self:StaticPopup_Show("RL_CLIENT")
                else
                    self.Events:Trigger("FONT_GROUP_UPDATED", template);
                end
            end,
            args = {
                description = {
                    order = 1,
                    name = info.desc,
                    type = "description",
                    width = "full",
                },
                spacer1 = {
                    order = 2,
                    name = "",
                    type = "description",
                    width = "full",
                },
                spacer2 = {
                    order = 3,
                    name = "",
                    type = "description",
                    width = "full",
                },
                file = {
                    type = "select",
                    dialogControl = 'LSM30_Font',
                    order = 4,
                    name = self.L["Font File"],
                    desc = self.L["Set the font file to use with this font-type."],
                    values = _G.AceGUIWidgetLSMlists.font,
                },
                outline = {
                    order = 5,
                    name = self.L["Font Outline"],
                    desc = self.L["Set the outlining to use with this font-type."],
                    type = "select",
                    values = {
                        ["NONE"] = self.L["None"],
                        ["OUTLINE"] = "OUTLINE",
                        ["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
                        ["THICKOUTLINE"] = "THICKOUTLINE"
                    },
                },
                size = {
                    order = 6,
                    name = self.L["Font Size"],
                    desc = self.L["Set the font size to use with this font-type."],
                    type = "range",
                    min = 6,
                    max = 64,
                    step = 1,
                },
            }
        }
    end
end
--[[
##########################################################
MEDIA CORE
##########################################################
]]--
local function tablesplice(mergeTable, targetTable)
    if type(targetTable) ~= "table" then targetTable = {} end
    if type(mergeTable) == 'table' then
	    for key,val in pairs(mergeTable) do
	        if type(val) == "table" then
	            targetTable[key] = tablesplice(val, targetTable[key])
	        else
	            targetTable[key] = val
	        end
	    end
    end
    return targetTable
end

UI.Media = tablesplice(UI.Mediadefaults, {});

local GLOBAL_CUSTOM_UI_FONTS = {
	["CUSTOM_UI_Font_Default"] = "default",
	["CUSTOM_UI_Font_Aura"] = "aura",
	["CUSTOM_UI_Font_Number"] = "number",
	["CUSTOM_UI_Font_Number_Huge"] = "number_big",
	["CUSTOM_UI_Font_Header"] = "header",
	["CUSTOM_UI_Font_Data"] = "data",
	["CUSTOM_UI_Font_Caps"] = "caps",
	["CUSTOM_UI_Font_Narrator"] = "narrator",
	["CUSTOM_UI_Font_Pixel"] = "pixel",
	["CUSTOM_UI_Font_Roll"] = "rolldialog",
	["CUSTOM_UI_Font_Roll_Number"] = "rollnumber",
	["CUSTOM_UI_Font_Loot"] = "lootdialog",
	["CUSTOM_UI_Font_Loot_Number"] = "lootnumber",
};

function UI:AssignMedia(mediaType, id, ...)
	if((not mediaType) or (not id)) then return end

	if(mediaType == "globalfont") then
		local globalName = ...;
		if(globalName) then
			GLOBAL_CUSTOM_UI_FONTS[globalName] = id;
		end
		return
	end

	if(mediaType == "template") then
		local globalName = ...;
		if(globalName) then
			self.API.Templates[id] = globalName;
		end
		return
	end

	local settings = self.Mediadefaults.shared[mediaType];
	if(settings) then
		if(mediaType == "font") then
			local file, size, outline = ...
			if(settings[id]) then
				if(file) then settings[id].file = file end
				if(size) then settings[id].size = size end
				if(outline) then settings[id].outline = outline end
			else
				file = file or "CUSTOM_UI Default Font";
				size = size or 12;
				outline = outline or "OUTLINE";
				settings[id] = {file = file, size = size, outline = outline}
			end
		elseif(mediaType == "statusbar") then
			local file, offset = ...
			if(settings[id]) then
				if(file) then settings[id].file = file end
				if(offset) then settings[id].offset = offset end
			else
				file = file or "CUSTOM_UI BasicBar";
				offset = offset or 0;
				settings[id] = {file = file, offset = offset}
			end
		elseif(mediaType == "background") then
			local file, size, tiled = ...
			if(settings[id]) then
				if(file) then settings[id].file = file end
				if(size) then settings[id].size = size end
				if(tiled) then settings[id].tiled = tiled end
			else
				file = file or "CUSTOM_UI Default BG";
				size = size or 0;
				tiled = tiled or false;
				settings[id] = {file = file, size = size, tiled = tiled}
			end
		elseif(mediaType == "border") then
			local file, size = ...
			if(settings[id]) then
				if(file) then settings[id].file = file end
				if(size) then settings[id].size = size end
			else
				file = file or "CUSTOM_UI Border";
				size = size or 1;
				settings[id] = {file = file, size = size}
			end
		end
	else
		settings = self.Mediadefaults[mediaType];
		if(settings) then
			if(settings[id]) then
				if(type(settings[id]) == "table") then
					for i = 1, select('#', ...) do
						local v = select(i, ...)
						if(not v) then break end
						if(type(v) == "table") then
							settings[id] = tablesplice(v, settings[id]);
						else
							settings[id][i] = v;
						end
					end
				else
					local newMedia = ...;
					if(newMedia) then
						settings[id] = newMedia;
					end
				end
			else
				local valueCount = select('#', ...)
				if(valueCount > 1) then
					settings[id] = {};
					for i = 1, select('#', ...) do
						local v = select(i, ...)
						if(not v) then break end
						if(type(v) == "table") then
							settings[id] = tablesplice(v, settings[id]);
						else
							settings[id][i] = v;
						end
					end
				else
					local newMedia = ...;
					if(newMedia) then
						settings[id] = newMedia;
					end
				end
			end
		end
	end
end

function UI:UpdateSharedMedia()
	local settings = self.Media.shared
	for mediaType, mediaData in pairs(settings) do
		if(self.Media[mediaType]) then
			for name,userSettings in pairs(mediaData) do
				if(userSettings.file) then
					self.Media[mediaType][name] = LSM:Fetch(mediaType, userSettings.file)
				end
			end
		end
	end

	for name, bd in pairs(self.Media.backdrop) do
		if(self.Media.background[name] and self.Media.border[name]) then
			local bordersetup = self.Media.shared.border[name];
			local bgsetup = self.Media.shared.background[name];
			bd.bgFile = self.Media.background[name];
		  bd.tile = bgsetup.tiled;
		  bd.tileSize = bgsetup.size;
			bd.edgeFile = self.Media.border[name];
			bd.edgeSize = bordersetup.size;
			local offset = bordersetup.size * 0.2;
			bd.insets = {
				left = offset,
				right = offset,
				top = offset,
				bottom = offset,
			}
		end
	end

	local default = self.Media.color.default
	self.Media.gradient.default = {"VERTICAL", default[1]*.25, default[2]*.25, default[3]*.25, default[1], default[2], default[3]}

	local secondary = self.Media.color.secondary
	self.Media.gradient.secondary = {"VERTICAL", secondary[1]*.25, secondary[2]*.25, secondary[3]*.25, secondary[1], secondary[2], secondary[3]}

	local cColor1 = CUSTOM_CLASS_COLORS[classToken]
	local cColor2 = RAID_CLASS_COLORS[classToken]
    if(not self.db.general.customClassColor or not CUSTOM_CLASS_COLORS[classToken]) then
        cColor1 = RAID_CLASS_COLORS[classToken]
    end
	local r1,g1,b1 = cColor1.r,cColor1.g,cColor1.b
	local r2,g2,b2 = cColor2.r*.25, cColor2.g*.25, cColor2.b*.25
	local ir1,ig1,ib1 = (1 - r1), (1 - g1), (1 - b1)
	local ir2,ig2,ib2 = (1 - cColor2.r)*.25, (1 - cColor2.g)*.25, (1 - cColor2.b)*.25
	self.Media.color.class = {r1, g1, b1, 1}
	self.Media.color.bizzaro = {ir1, ig1, ib1, 1}
	self.Media.bordercolor.class = {r1, g1, b1, 1}
	self.Media.gradient.class = {"VERTICAL", r2, g2, b2, r1, g1, b1}
	self.Media.gradient.bizzaro = {"VERTICAL", ir2, ig2, ib2, ir1, ig1, ib1}

	local special = self.Media.color.special
	self.Media.gradient.special = {"VERTICAL", special[1], special[2], special[3], r1, g1, b1}
	self.Media.color.special = {r1*.5, g1*.5, b1*.5, 1}
	-- self.Media.gradient.special = {"VERTICAL", special[1]*.25, special[2]*.25, special[3]*.25, special[1], special[2], special[3]}
	-- self.Media.gradient.special = {"VERTICAL",special[1], special[2], special[3], default[1], default[2], default[3]}

	self.Events:Trigger("SHARED_MEDIA_UPDATED");
	if(not InCombatLockdown()) then
		collectgarbage("collect");
	end
end

function UI:RefreshAllMedia()
	self:UpdateSharedMedia();

	ChangeGlobalFonts();
	ChangeSystemFonts();

	for globalName, id in pairs(GLOBAL_CUSTOM_UI_FONTS) do
		local obj = _G[globalName];
		if(obj) then
			self:FontManager(obj, id);
		end
	end

	self.Events:Trigger("ALL_FONTS_UPDATED");
	self.MediaInitialized = true;
end
