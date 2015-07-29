--[[
##########################################################
S V U I   By: Munglunch
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;

local UI = _G["CUSTOM_UI"];
local L = UI.L
local name, obj = ...
local MOD = UI:NewModule(name, obj, nil, "CUSTOM_UI_Private_ChatCache");
local Schema = MOD.Schema;

UI:AssignMedia("font", "chatdialog", "CUSTOM_UI Default Font", 12, "OUTLINE");
UI:AssignMedia("font", "chattab", "CUSTOM_UI Caps Font", 12, "OUTLINE");
UI:AssignMedia("globalfont", "chatdialog", "CUSTOM_UI_Font_Chat");
UI:AssignMedia("globalfont", "chattab", "CUSTOM_UI_Font_ChatTab");

MOD.Media = {}
MOD.Media.dockIcon = [[Interface\AddOns\CUSTOM_UI_Chat\assets\DOCK-ICON-CHAT]];
MOD.Media.scrollIcon = [[Interface\AddOns\CUSTOM_UI_Chat\assets\CHAT-SCROLL]];
MOD.Media.whisperIcon = [[Interface\AddOns\CUSTOM_UI_Chat\assets\CHAT-WHISPER]];

UI.defaults[Schema] = {
	["docked"] = "BottomLeft",
	["tabHeight"] = 20,
	["tabWidth"] = 75,
	["tabStyled"] = true,
	["font"] = "CUSTOM_UI Default Font",
	["fontOutline"] = "OUTLINE",
	["tabFont"] = "CUSTOM_UI Tab Font",
	["tabFontSize"] = 11,
	["tabFontOutline"] = "OUTLINE",
	["url"] = true,
	["hyperlinkHover"] = true,
	["throttleInterval"] = 45,
	["fade"] = false,
	["sticky"] = true,
	["smileys"] = true,
	["shortChannels"] = true,
	["hideRealms"] = false,
	["secretWordTone"] = "None",
	["psst"] = "Whisper Alert",
	["noWipe"] = false,
	["timeStampFormat"] = "NONE",
	["secretWords"] = "%MYNAME%, CUSTOM_UI",
	["basicTools"] = true,
	["bubbles"] = true,
};

function MOD:LoadOptions()
	local chatFonts = {
		["chatdialog"] = {
			order = 1,
			name = "Chat",
			desc = "Font used for chat text."
		},
		["chattab"] = {
			order = 2,
			name = "Chat Tabs",
			desc = "Font used for chat tab labels."
		},
	};

	UI:GenerateFontOptionGroup("Chat", 5, "Fonts used for the chat frame.", chatFonts)

	UI.Options.args[Schema] = {
		type = "group",
		name = Schema,
		get = function(a)return UI.db[Schema][a[#a]]end,
		set = function(a,b)MOD:ChangeDBVar(b,a[#a]); end,
		args = {
			intro = {
				order = 1,
				type = "description",
				name = L["CHAT_DESC"],
				width = 'full'
			},
			common = {
				order = 2,
				type = "group",
				name = L["General"],
				guiInline = true,
				args = {
					sticky = {
						order = 1,
						type = "toggle",
						name = L["Sticky Chat"],
						desc = L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."]
					},
					url = {
						order = 2,
						type = "toggle",
						name = L["URL Links"],
						desc = L["Attempt to create URL links inside the chat."],
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
					hyperlinkHover = {
						order = 3,
						type = "toggle",
						name = L["Hyperlink Hover"],
						desc = L["Display the hyperlink tooltip while hovering over a hyperlink."],
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]); MOD:ToggleHyperlinks(b); end
					},
					smileys = {
						order = 4,
						type = "toggle",
						name = L["Emotion Icons"],
						desc = L["Display emotion icons in chat."]
					},
					tabStyled = {
						order = 5,
						type = "toggle",
						name = L["Custom Tab Style"],
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]);UI:StaticPopup_Show("RL_CLIENT") end,
					},
					shortChannels = {
						order = 6,
						type = "toggle",
						name = L["Abbreviation"],
						desc = "Shortened channel names",
					},
					hideRealms = {
						order = 7,
						type = "toggle",
						name = L['Player Realms'],
						desc = L['Show/hide the players realm next to their name.'],
					},
					bubbles = {
						order = 8,
						type = "toggle",
						name = L['Chat Bubbles'],
						desc = L['Style the blizzard chat bubbles.'],
						get = function(a)return UI.db[Schema][a[#a]] end,
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]);UI:StaticPopup_Show("RL_CLIENT")end
					},
					spacer1 = {
						order = 9,
						type = "description",
						name = ""
					},
					timeStampFormat = {
						order = 10,
						type = "select",
						name = TIMESTAMPS_LABEL,
						desc = OPTION_TOOLTIP_TIMESTAMPS,
						values = {
							["NONE"] = NONE,
							["%I:%M "] = "03:27",
							["%I:%M:%S "] = "03:27:32",
							["%I:%M %p "] = "03:27 PM",
							["%I:%M:%S %p "] = "03:27:32 PM",
							["%H:%M "] = "15:27",
							["%H:%M:%S "] = "15:27:32"
						}
					},
					psst = {
						order = 11,
						type = "select",
						dialogControl = "LSM30_Sound",
						name = L["Whisper Alert"],
						disabled = function()return not UI.db[Schema].psst end,
						values = AceGUIWidgetLSMlists.sound,
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
					spacer2 = {
						order = 12,
						type = "description",
						name = ""
					},
					throttleInterval = {
						order = 13,
						type = "range",
						name = L["Spam Interval"],
						desc = L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."],
						min = 0,
						max = 120,
						step = 1,
						width = "full",
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
				}
			},
		}
	}
end
