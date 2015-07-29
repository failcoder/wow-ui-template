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
local table 		= _G.table;
local tsort 		= table.sort;

local UI = _G["CUSTOM_UI"];
local L = UI.L;
local name, obj = ...;
local MOD = UI:NewModule(name, obj, "CUSTOM_UI_LootCache", "CUSTOM_UI_Private_LootCache");
local Schema = MOD.Schema;
local pointList = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
};

MOD.Media = {}
MOD.Media.cleanupIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-CLEANUP]];
MOD.Media.bagIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-BAGS]];
MOD.Media.depositIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-DEPOSIT]];
MOD.Media.purchaseIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-PURCHASE]];
MOD.Media.reagentIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-REAGENTS]];
MOD.Media.sortIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-SORT]];
MOD.Media.stackIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-STACK]];
MOD.Media.transferIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-TRANSFER]];
MOD.Media.vendorIcon = [[Interface\AddOns\CUSTOM_UI_Inventory\assets\BAGS-VENDOR]];

UI:AssignMedia("font", "bagdialog", "CUSTOM_UI Default Font", 11, "OUTLINE");
UI:AssignMedia("font", "bagnumber", "CUSTOM_UI Number Font", 11, "OUTLINE");
UI:AssignMedia("globalfont", "bagdialog", "CUSTOM_UI_Font_Bag");
UI:AssignMedia("globalfont", "bagnumber", "CUSTOM_UI_Font_Bag_Number");

UI.defaults[Schema] = {
	["incompatible"] = {
		["AdiBags"] = true,
		["ArkInventory"] = true,
		["Bagnon"] = true,
	},
	["sortInverted"] = false,
	["bags"] = {
		["xOffset"] = -40,
		["yOffset"] = 40,
		["point"] = "BOTTOMRIGHT",
	},
	["bank"] = {
		["xOffset"] = 40,
		["yOffset"] = 40,
		["point"] = "BOTTOMLEFT",
	},
	["bagSize"] = 34,
	["bankSize"] = 34,
	["alignToChat"] = false,
	["bagWidth"] = 525,
	["bankWidth"] = 525,
	["currencyFormat"] = "ICON",
	["ignoreItems"] = "",
	["bagTools"] = true,
	["iLevels"] = true,
	["bagBar"] = {
		["enable"] = false,
		["showBy"] = "VERTICAL",
		["sortDirection"] = "ASCENDING",
		["size"] = 30,
		["spacing"] = 4,
		["showBackdrop"] = false,
		["mouseover"] = false,
	},
};

function MOD:LoadOptions()
	local bagFonts = {
		["bagdialog"] = {
			order = 1,
			name = "Bag Slot Dialog",
			desc = "Default font used in bag and bank slots"
		},
	    ["bagnumber"] = {
			order = 2,
			name = "Bag Slot Numbers",
			desc = "Font used in bag and bank slots to display numeric values."
		},
	};

	UI:GenerateFontOptionGroup("Bags", 7, "Fonts used in bag slots.", bagFonts)

	UI.Options.args[Schema] = {
		type = 'group',
		name = Schema,
		childGroups = "tab",
		get = function(a)return UI.db[Schema][a[#a]]end,
		set = function(a,b)MOD:ChangeDBVar(b,a[#a]) end,
		args = {
			intro = {
				order = 1,
				type = "description",
				name = L["BAGS_DESC"]
			},
			bagGroups={
				order = 2,
				type = 'group',
				name = L['Bag Options'],
				guiInline = true,
				args = {
					common = {
						order = 1,
						type = "group",
						guiInline = true,
						name = L["General"],
						args = {
							bagSize = {
								order = 1,
								type = "range",
								name = L["Button Size (Bag)"],
								desc = L["The size of the individual buttons on the bag frame."],
								min = 15,
								max = 45,
								step = 1,
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BagFrame") end,
								disabled = function()return UI.db[Schema].alignToChat end
							},
							bankSize = {
								order = 2,
								type = "range",
								name = L["Button Size (Bank)"],
								desc = L["The size of the individual buttons on the bank frame."],
								min = 15,
								max = 45,
								step = 1,
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BankFrame") end,
								disabled = function()return UI.db[Schema].alignToChat end
							},
							bagWidth = {
								order = 3,
								type = "range",
								name = L["Panel Width (Bags)"],
								desc = L["Adjust the width of the bag frame."],
								min = 150,
								max = 700,
								step = 1,
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BagFrame") end,
								disabled = function()return UI.db[Schema].alignToChat end
							},
							bankWidth = {
								order = 4,
								type = "range",
								name = L["Panel Width (Bank)"],
								desc = L["Adjust the width of the bank frame."],
								min = 150,
								max = 700,
								step = 1,
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BankFrame") end,
								disabled = function() return UI.db[Schema].alignToChat end
							},
							currencyFormat = {
								order = 5,
								type = "select",
								name = L["Currency Format"],
								desc = L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"],
								values = {
									["ICON"] = L["Icons Only"],
									["ICON_TEXT"] = L["Icons and Text"]
								},
								set = function(a,b)MOD:ChangeDBVar(b,a[#a]) MOD:RefreshTokens() end
							},
							sortInverted = {
								order = 6,
								type = "toggle",
								name = L["Sort Inverted"],
								desc = L["Direction the bag sorting will use to allocate the items."]
							},
							bagTools = {
								order = 7,
								type = "toggle",
								name = L["Profession Tools"],
								desc = L["Enable/Disable Prospecting, Disenchanting and Milling buttons on the bag frame."],
								set = function(a,b)MOD:ChangeDBVar(b,a[#a])UI:StaticPopup_Show("RL_CLIENT")end
							},
							ignoreItems = {
								order = 8,
								name = L["Ignore Items"],
								desc = L["List of items to ignore when sorting. If you wish to add multiple items you must seperate the word with a comma."],
								type = "input",
								width = "full",
								multiline = true,
								set = function(a,b) UI.db[Schema][a[#a]] = b end
							}
						}
					},
					position = {
						order = 2,
						type = "group",
						guiInline = true,
						name = L["Bag/Bank Positioning"],
						args = {
							alignToChat = {
								order = 1,
								type = "toggle",
								name = L["Align To Docks"],
								desc = L["Align the width of the bag frame to fit inside dock windows."],
								set = function(a,b)MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames() end
							},
							bags = {
								order = 2,
								type = "group",
								name = L["Bag Position"],
								guiInline = true,
								get = function(key) return UI.db[Schema].bags[key[#key]] end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bags"); MOD:ModifyBags() end,
								args = {
									point = {
										order = 1,
										name = L["Anchor Point"],
										type = "select",
										values = pointList,
									},
									xOffset = {
										order = 2,
										type = "range",
										name = L["X Offset"],
										min = -600,
										max = 600,
										step = 1,
									},
									yOffset = {
										order = 3,
										type = "range",
										name = L["Y Offset"],
										min = -600,
										max = 600,
										step = 1,
									},
								}
							},
							bank = {
								order = 3,
								type = "group",
								name = L["Bank Position"],
								guiInline = true,
								get = function(key) return UI.db[Schema].bank[key[#key]] end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bank"); MOD:ModifyBags() end,
								args = {
									point = {
										order = 1,
										name = L["Anchor Point"],
										type = "select",
										values = pointList,
									},
									xOffset = {
										order = 2,
										type = "range",
										name = L["X Offset"],
										min = -600,
										max = 600,
										step = 1,
									},
									yOffset = {
										order = 3,
										type = "range",
										name = L["Y Offset"],
										min = -600,
										max = 600,
										step = 1,
									},
								}
							},
						}
					},
					bagBar = {
						order = 4,
						type = "group",
						name = L["Bag-Bar"],
						guiInline = true,
						get = function(key) return UI.db[Schema].bagBar[key[#key]] end,
						set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bagBar"); MOD:ModifyBagBar() end,
						args={
							enable = {
								order = 1,
								type = "toggle",
								name = L["Bags Bar Enabled"],
								desc = L["Enable/Disable the Bag-Bar."],
								get = function() return UI.db[Schema].bagBar.enable end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bagBar"); UI:StaticPopup_Show("RL_CLIENT")end
							},
							mouseover = {
								order = 2,
								name = L["Mouse Over"],
								desc = L["Hidden unless you mouse over the frame."],
								type = "toggle"
							},
							showBackdrop = {
								order = 3,
								name = L["Backdrop"],
								desc = L["Show/Hide bag bar backdrop"],
								type = "toggle"
							},
							spacer = {
								order = 4,
								name = "",
								type = "description",
								width = "full",
							},
							size = {
								order = 5,
								type = "range",
								name = L["Button Size"],
								desc = L["Set the size of your bag buttons."],
								min = 24,
								max = 60,
								step = 1
							},
							spacing = {
								order = 6,
								type = "range",
								name = L["Button Spacing"],
								desc = L["The spacing between buttons."],
								min = 1,
								max = 10,
								step = 1
							},
							sortDirection = {
								order = 7,
								type = "select",
								name = L["Sort Direction"],
								desc = L["The direction that the bag frames will grow from the anchor."],
								values = {
									["ASCENDING"] = L["Ascending"],
									["DESCENDING"] = L["Descending"]
								}
							},
							showBy = {
								order = 8,
								type = "select",
								name = L["Bar Direction"],
								desc = L["The direction that the bag frames be (Horizontal or Vertical)."],
								values = {
									["VERTICAL"] = L["Vertical"],
									["HORIZONTAL"] = L["Horizontal"]
								}
							}
						}
					},
				}
			}
		}
	};
end
