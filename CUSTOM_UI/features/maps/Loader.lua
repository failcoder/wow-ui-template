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
local textSelect = {
	['HIDE'] = L['Hide This'],
	['CUSTOM'] = L['Use Custom Style'],
	['SIMPLE'] = L['Use Simple Style']
};
local colorSelect = {
	['light'] = L['Light'],
	['dark'] = L['Dark'],
	['darkest'] = L['Darkest'],
	['class'] = L['Class']
};

MOD.Media = {}
MOD.Media.customBlips = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP-OBJECTICONS]];
MOD.Media.defaultBlips = [[Interface\AddOns\CUSTOM_UI_Maps\assets\DEFAULT-OBJECTICONS]];
MOD.Media.rectangleMask = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP_MASK_RECTANGLE]];
MOD.Media.squareMask = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP_MASK_SQUARE]];
MOD.Media.roundBorder = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP-ROUND]];
MOD.Media.playerArrow = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP_ARROW]];
MOD.Media.corpseArrow = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP_CORPSE_ARROW]];
MOD.Media.guideArrow = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP_GUIDE_ARROW]];
MOD.Media.mailIcon = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP-MAIL]];
MOD.Media.calendarIcon = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP-CALENDAR]];
MOD.Media.trackingIcon = [[Interface\AddOns\CUSTOM_UI_Maps\assets\MINIMAP-TRACKING]];

UI:AssignMedia("template", "Minimap", "CUSTOM_UI_StyleTemplate_Minimap");
UI:AssignMedia("font", "mapinfo", "CUSTOM_UI Narrator Font", 13, "OUTLINE");
UI:AssignMedia("font", "mapcoords", "CUSTOM_UI Number Font", 12, "OUTLINE");
UI:AssignMedia("globalfont", "mapinfo", "CUSTOM_UI_Font_MinimapInfo");
UI:AssignMedia("globalfont", "mapcoords", "CUSTOM_UI_Font_MinimapCoords");

UI.defaults[Schema] = {
	["incompatible"] = {
		["SexyMap"] = true,
		["SquareMap"] = true,
		["PocketPlot"] = true,
	},
	["customIcons"] = true,
	["tinyWorldMap"] = true,
	["calendarShortcut"] = true,
	["trackingShortcut"] = true,
	["size"] = 240,
	["mapShape"] = 'RECTANGLE',
	["miniPlayerXY"] = true,
	["worldPlayerXY"] = true,
	["worldMouseXY"] = true,
	["bordersize"] = 4,
	["bordercolor"] = "light",
	["locationText"] = "CUSTOM",
	["minimapbar"] = {
		["enable"] = true,
		["styleType"] = "HORIZONTAL",
		["layoutDirection"] = "NORMAL",
		["perRow"] = 8,
		["buttonSize"] = 28,
		["mouseover"] = false,
	},
};

function MOD:LoadOptions()
	local mapFonts = {
		["mapinfo"] = {
			order = 1,
			name = "Map Labels",
			desc = "Font used for info labels."
		},
		["mapcoords"] = {
			order = 2,
			name = "Map Coords",
			desc = "Font used for coordinates."
		},
	};

	UI:GenerateFontOptionGroup("Maps", 10, "Fonts used for the minimap.", mapFonts)

	UI.Options.args[Schema] = {
		name = Schema,
		type = 'group',
		childGroups = "tree",
		get = function(a)return UI.db[Schema][a[#a]]end,
		set = function(a,b)MOD:ChangeDBVar(b,a[#a]);MOD:ReLoad()end,
		args = {
			intro={
				order = 1,
				type = 'description',
				name = L["Options for the Minimap"],
				width = 'full'
			},
			common = {
				order = 2,
				type = "group",
				name = MINIMAP_LABEL,
				desc = L['General display settings'],
				guiInline = true,
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["Size"],
						desc = L['Adjust the size of the minimap.'],
						min = 100,
						max = 1000,
						width = "full",
						step = 1
					},
					bordersize = {
						order = 2,
						type = "range",
						name = "Border Size",
						desc = "Adjust the size of the minimap's outer border",
						min = 0,
						max = 20,
						step = 1,
						width = "full"
					},
					bordercolor = {
						order = 3,
						type = 'select',
						name = "Border Color",
						desc = "Adjust the color of the minimap's outer border",
						values = colorSelect,
					},
					mapShape = {
						order = 4,
						type = "select",
						name = "Minimap Shape",
						desc = "Select the shape of your minimap.",
						values = {
							['RECTANGLE'] = 'Rectangular (Default)',
							['SQUARE'] = 'Square',
							['ROUND'] = 'Round',
						},
					},
					customIcons = {
						order = 5,
						type = "toggle",
						name = "Custom Blip Icons",
						desc = "Toggle the use of special map blips.",
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]); UI:StaticPopup_Show("RL_CLIENT") end
					},
					calendarShortcut = {
						order = 6,
						type = "toggle",
						name = "Calendar Button",
						desc = "Toggle the use of the calendar shortcut.",
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]); UI:StaticPopup_Show("RL_CLIENT") end
					},
					trackingShortcut = {
						order = 7,
						type = "toggle",
						name = "Tracking Button",
						desc = "Toggle the use of the tracking shortcut.",
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]); UI:StaticPopup_Show("RL_CLIENT") end
					}
				}
			},
			spacer1 = {
				order = 4,
				type = "group",
				name = "",
				guiInline = true,
				args = {}
			},
			common2 = {
				order = 5,
				type = "group",
				name = "Labels and Info",
				desc = L['Configure various worldmap and minimap texts'],
				guiInline = true,
				args = {
					locationText = {
						order = 1,
						type = "select",
						name = L["Location Text"],
						values = textSelect,
						set = function(a,b)MOD:ChangeDBVar(b,a[#a])MOD:ReLoad()end
					},
					miniPlayerXY = {
						order = 2,
						type = "toggle",
						name = L["Minimap X/Y Coordinates"],
						set = function(a,b)MOD:ChangeDBVar(b,a[#a])MOD:ReLoad()end
					},
					worldPlayerXY = {
						order = 3,
						type = "toggle",
						name = L["WorldMap Player X/Y Coordinates"],
						set = function(a,b)MOD:ChangeDBVar(b,a[#a])MOD:ReLoad()end
					},
					worldMouseXY = {
						order = 4,
						type = "toggle",
						name = L["WorldMap Mouse X/Y Coordinates"],
						set = function(a,b)MOD:ChangeDBVar(b,a[#a])MOD:ReLoad()end
					}
				}
			},
			spacer2 = {
				order = 6,
				type = "group",
				name = "",
				guiInline = true,
				args = {}
			},
			mmButtons = {
				order = 7,
				type = "group",
				name = "Minimap Buttons",
				get = function(j)return UI.db[Schema].minimapbar[j[#j]]end,
				guiInline = true,
				args = {
					enable = {
						order = 1,
						type = 'toggle',
						name = L['Buttons Styled'],
						desc = L['Style the minimap buttons.'],
						set = function(a,b)MOD:ChangeDBVar(b,a[#a],"minimapbar")UI:StaticPopup_Show("RL_CLIENT")end,
					},
					mouseover = {
						order = 2,
						name = L["Mouse Over"],
						desc = L["Hidden unless you mouse over the frame."],
						type = "toggle",
						set = function(a,b) MOD:ChangeDBVar(b,a[#a],"minimapbar") MOD:UpdateMinimapButtonSettings(true) end,
					},
					styleType = {
						order = 3,
						type = 'select',
						name = L['Button Bar Layout'],
						desc = L['Change settings for how the minimap buttons are styled.'],
						set = function(a,b) MOD:ChangeDBVar(b,a[#a],"minimapbar") MOD:UpdateMinimapButtonSettings(true) end,
						disabled = function()return not UI.db[Schema].minimapbar.enable end,
						values = {
							['NOANCHOR'] = L['No Anchor Bar'],
							['HORIZONTAL'] = L['Horizontal Anchor Bar'],
							['VERTICAL'] = L['Vertical Anchor Bar']
						}
					},
					buttonSize = {
						order = 4,
						type = 'range',
						name = L['Buttons Size'],
						desc = L['The size of the minimap buttons.'],
						min = 16,
						max = 40,
						step = 1,
						width = "full",
						set = function(a,b)MOD:ChangeDBVar(b,a[#a],"minimapbar")MOD:UpdateMinimapButtonSettings(true) end,
						disabled = function()return not UI.db[Schema].minimapbar.enable or UI.db[Schema].minimapbar.styleType == 'NOANCHOR'end
					},
					perRow = {
						order = 5,
						type = 'range',
						name = L['Buttons Per Row'],
						min = 1,
						max = 40,
						step = 1,
						width = "full",
						set = function(a,b)MOD:ChangeDBVar(b,a[#a],"minimapbar")MOD:UpdateMinimapButtonSettings(true) end,
						disabled = function()return not UI.db[Schema].minimapbar.enable or UI.db[Schema].minimapbar.styleType == 'NOANCHOR'end
					},
				}
			},
			spacer3 = {
				order = 8,
				type = "group",
				name = "",
				guiInline = true,
				args = {}
			},
			worldMap = {
				order = 9,
				type = "group",
				name = "WorldMap",
				guiInline = true,
				args = {
					tinyWorldMap = {
						order = 1,
						type = "toggle",
						name = L["Tiny Map"],
						desc = L["Don't scale the large world map to block out sides of the screen."],
						set = function(a,b)MOD:ChangeDBVar(b,a[#a])MOD:ReLoad()end
					},
				}
			},
		}
	}
end
