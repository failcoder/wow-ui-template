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
local MOD = UI:NewModule(...);
local Schema = MOD.Schema;

MOD.Media = {}
MOD.Media.dockIcon = [[Interface\AddOns\CUSTOM_UI_QuestTracker\assets\DOCK-ICON-QUESTS]];
MOD.Media.buttonArt = [[Interface\AddOns\CUSTOM_UI_QuestTracker\assets\QUEST-BUTTON-ART]];
MOD.Media.completeIcon = [[Interface\AddOns\CUSTOM_UI_QuestTracker\assets\QUEST-COMPLETE-ICON]];
MOD.Media.incompleteIcon = [[Interface\AddOns\CUSTOM_UI_QuestTracker\assets\QUEST-INCOMPLETE-ICON]];

UI.defaults[Schema] = {
	["rowHeight"] = 0,
	["itemBarDirection"] = 'VERTICAL',
	["itemButtonSize"] = 28,
	["itemButtonsPerRow"] = 5,
};

UI:AssignMedia("font", "questdialog", "CUSTOM_UI Default Font", 12, "OUTLINE");
UI:AssignMedia("font", "questheader", "CUSTOM_UI Caps Font", 16, "OUTLINE");
UI:AssignMedia("font", "questnumber", "CUSTOM_UI Number Font", 11, "OUTLINE");
UI:AssignMedia("globalfont", "questdialog", "CUSTOM_UI_Font_Quest");
UI:AssignMedia("globalfont", "questheader", "CUSTOM_UI_Font_Quest_Header");
UI:AssignMedia("globalfont", "questnumber", "CUSTOM_UI_Font_Quest_Number");


function MOD:LoadOptions()
	local questFonts = {
		["questdialog"] = {
			order = 1,
			name = "Quest Tracker Dialog",
			desc = "Default font used in the quest tracker"
		},
		["questheader"] = {
			order = 2,
			name = "Quest Tracker Titles",
			desc = "Font used in the quest tracker for listing headers."
		},
		["questnumber"] = {
			order = 3,
			name = "Quest Tracker Numbers",
			desc = "Font used in the quest tracker to display numeric values."
		},
	};

	UI:GenerateFontOptionGroup("QuestTracker", 6, "Fonts used in the CUSTOM_UI Quest Tracker.", questFonts)

	UI.Options.args[Schema] = {
		type = "group",
		name = Schema,
		args = {
			generalGroup = {
				order = 1,
				type = "group",
				name = "General",
				guiInline = true,
				get = function(a)return UI.db[Schema][a[#a]] end,
				set = function(a,b)
					MOD:ChangeDBVar(b,a[#a]);
					UI:StaticPopup_Show("RL_CLIENT")
				end,
				args = {
					rowHeight = {
						order = 1,
						type = 'range',
						name = L["Row Height"],
						desc = L["Setting this to 0 (zero) will force an automatic size"],
						min = 0,
						max = 50,
						step = 1,
						width = "full",
					},
				}
			},
			itemsGroup = {
				order = 2,
				type = "group",
				name = "Quest Items",
				guiInline = true,
				get = function(a)return UI.db[Schema][a[#a]] end,
				set = function(a,b)
					MOD:ChangeDBVar(b,a[#a]);
					MOD:UpdateLocals();
				end,
				args = {
					itemBarDirection = {
						order = 1,
						type = 'select',
						name = L["Bar Direction"],
						values = {
							['VERTICAL'] = L['Vertical'],
							['HORIZONTAL'] = L['Horizontal']
						},
					},
					itemButtonSize = {
						order = 2,
						type = 'range',
						name = L["Button Size"],
						min = 10,
						max = 100,
						step = 1,
						width = "full",
					},
					itemButtonsPerRow = {
						order = 3,
						type = 'range',
						name = L["Buttons Per Row"],
						desc = L["This will only take effect if you have moved the item bar away from the dock."],
						min = 1,
						max = 20,
						step = 1,
						width = "full",
					},
				}
			}
		}
	}
end
