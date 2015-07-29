--[[
##########################################################
S V U I   By: Munglunch
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
local tinsert 	 =  _G.tinsert;
local table 	 =  _G.table;
local wipe       =  _G.wipe;
--[[ TABLE METHODS ]]--
local tsort = table.sort;
local IsAddOnLoaded         = _G.IsAddOnLoaded;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local UI = _G['CUSTOM_UI']
local L = UI.L;
local _, CUSTOM_UIOptions = ...;
local UI_Registry = Librarian("Registry");
local AceGUI = LibStub("AceGUI-3.0", true);
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-1.0");
local AceGUIWidgetLSMlists = AceGUIWidgetLSMlists;
local GameTooltip = GameTooltip;
local GetNumEquipmentSets = GetNumEquipmentSets;
local GetEquipmentSetInfo = GetEquipmentSetInfo;
local sortingFunction = function(arg1, arg2) return arg1 < arg2 end
local GUIWidth = UI.LowRez and 890 or 1090;
local playerRealm = GetRealmName()
local playerName = UnitName("player")
local profileKey = ("%s - %s"):format(playerName, playerRealm)
local DockableAddons = {
	["alDamageMeter"] = L["alDamageMeter"],
	["Skada"] = L["Skada"],
	["Recount"] = L["Recount"],
	["TinyDPS"] = L["TinyDPS"],
	["Omen"] = L["Omen"],
	--["Details"] = L["Details"]
};

local NONE = _G.NONE;
local GetSpellInfo = _G.GetSpellInfo;
local collectgarbage = _G.collectgarbage;

local allFilterTable, userFilterTable, tempFilterTable = {},{},{};
local CURRENT_FILTER_TYPE = NONE;

AceConfig:RegisterOptionsTable(UI.NameID, UI.Options);
AceConfigDialog:SetDefaultSize(UI.NameID, GUIWidth, 651);

CUSTOM_UIOptions.FilterOptionGroups = {};
CUSTOM_UIOptions.FilterOptionSpells = {};

local function GetLiveDockletsA()
	local test = UI.private.Docks.Embed2;
	local t = {["None"] = L["None"]};
	for n,l in pairs(DockableAddons) do
		if(n:find("Skada") and _G.Skada) then
			for index,window in pairs(_G.Skada:GetWindows()) do
			    local name = window.db.name
			    local key = "SkadaBarWindow"..name
			    if(not test or test ~= key) then
			    	t["SkadaBarWindow"..name] = (key == "Skada") and "Skada - Main" or "Skada - "..name;
			    end
			end
		elseif((not test) or (not test:find(n))) then
			if IsAddOnLoaded(n) or IsAddOnLoaded(l) then t[n] = l end
		end
	end
	return t;
end

local function GetLiveDockletsB()
	local test = UI.private.Docks.Embed1;
	local t = {["None"] = L["None"]};
	for n,l in pairs(DockableAddons) do
		if(n:find("Skada") and _G.Skada) then
			for index,window in pairs(_G.Skada:GetWindows()) do
			    local name = window.db.name
			    local key = "SkadaBarWindow"..name
			    if(not test or test ~= key) then
			    	t["SkadaBarWindow"..name] = (key == "Skada") and "Skada - Main" or "Skada - "..name;
			    end
			end
		elseif((not test) or (not test:find(n))) then
			if IsAddOnLoaded(n) or IsAddOnLoaded(l) then t[n] = l end
		end
	end
	return t;
end
--[[
##########################################################
INIT OPTIONS
##########################################################
]]--
local function RefreshProfileOptions()
	local hasProfile = true;
	local currentProfile = UI_Registry:CurrentProfile()
	if(not currentProfile) then
		hasProfile = false
		currentProfile = profileKey
	end
	UI.Options.args.profiles.desc = " |cff66FF33" .. L["current"] .. currentProfile .. "|r";
	local optionGroup = UI.Options.args.profiles.args

	optionGroup.spacer1 = {
		order = 1,
		type = "description",
		name = "|cff66FF33" .. L["current"] .. currentProfile .. "|r",
		width = "full",
	}
	optionGroup.spacer2 = {
		order = 2,
		type = "description",
		name = "",
		width = "full",
	}
	optionGroup.dualSpec = {
		order = 3,
		type = "toggle",
		name = "Dual-Spec Switching",
		get = function() return UI_Registry:CheckDualProfile() end,
		set = function(key, value) UI_Registry:ToggleDualProfile(value) end
	}
	optionGroup.mpEnable = {
		order = 4,
		type = "toggle",
		name = "Enable Master Profile",
		desc = L["Toggle the use of a master profile for easy one-click installation on your other characters."],
		get = function()
			local mp = UI_Registry:CheckMasterProfile()
			if(type(mp) == 'string') then
				return true
			else
				return false
			end
		end,
		set = function(key, value)
			if(not value) then
				UI_Registry:SetMasterProfile()
			else
				UI_Registry:SetMasterProfile(currentProfile)
			end
			UI:SavedPopup()
			RefreshProfileOptions()
		end,
	}
	optionGroup.masterProfile = {
		order = 5,
		type = "select",
		name = "Select Master Profile",
		desc = L["Flag the current profile as a master for easy one-click installation on your other characters."],
		get = function() return UI_Registry:CheckMasterProfile() end,
		set = function(key, value) UI_Registry:SetMasterProfile(value) UI:SavedPopup() RefreshProfileOptions() end,
		values = UI_Registry:GetProfiles(),
		disabled = function()
			local t = UI_Registry:CheckMasterProfile()
			return (not t)
		end,
	}
	optionGroup.importdesc = {
		order = 6,
		type = "description",
		name = function()
			if(UI_Registry:CheckDualProfile()) then
				return "\n" .. L["Can not Save, Copy or Change while dual spec swapping is enabled"]
			else
				return "\n" .. L["import_desc"]
			end
		end,
		width = "full"
	}
	optionGroup.spacer3 = {
		order = 7,
		type = "description",
		name = "",
		width = "full",
	}
	optionGroup.export = {
		name = L["export"],
		desc = L["export_sub"],
		type = "input",
		order = 8,
		get = false,
		set = function(key, value) UI_Registry:CloneDatabase(value) UI:SavedPopup() RefreshProfileOptions() end,
		disabled = function()
			local t = UI_Registry:CheckProfiles()
			return ((not t) or UI_Registry:CheckDualProfile())
		end,
	}
	optionGroup.copy = {
		name = L["Copy"],
		desc = L["Copy from another profile. Further changes from other characters using this profile will not affect this one."],
		type = "select",
		order = 9,
		get = function() return currentProfile end,
		set = function(key, value) UI:CopyProfile(value) UI:SavedPopup() RefreshProfileOptions() end,
		disabled = function()
			local t = UI_Registry:CheckProfiles()
			return ((not t) or UI_Registry:CheckDualProfile())
		end,
		values = UI_Registry:GetProfiles(),
	}
	optionGroup.import = {
		name = L["Share"],
		desc = L["Share an already existing profile. Changes made by any characters using this profile will be shared."],
		type = "select",
		order = 10,
		get = function() return currentProfile end,
		set = function(key, value) UI:LinkProfile(value) UI:SavedPopup() RefreshProfileOptions() end,
		disabled = function()
			local t = UI_Registry:CheckProfiles()
			return ((not t) or UI_Registry:CheckDualProfile())
		end,
		values = UI_Registry:GetProfiles(),
		width = 'fill',
	}
	optionGroup.spacer4 = {
		order = 11,
		type = "description",
		name = "",
		width = "full",
	}
	optionGroup.spacer5 = {
		order = 12,
		type = "description",
		name = L["delete_desc"],
		width = "full",
	}
	optionGroup.delete = {
		order = 13,
		type = "select",
		width = "full",
		name = L["delete"],
		desc = L["delete_sub"],
		get = function() return " SELECT ONE" end,
		set = function(key, value) UI_Registry:Remove(value) end,
		values = UI_Registry:GetProfiles(),
		disabled = function() local t = UI_Registry:CheckProfiles() return (not t) end,
		confirm = true,
		confirmText = L["delete_confirm"],
	}
	optionGroup.spacer6 = {
		order = 14,
		type = "description",
		name = "",
		width = "full",
	}
	optionGroup.spacer7 = {
		order = 15,
		type = "description",
		name = L["reset_desc"],
		width = "full",
	}
	optionGroup.reset = {
		order = 16,
		type = "execute",
		name = function() return L["reset"] .. " " .. " |cffFFFF00" .. currentProfile .. "|r" end,
		desc = L["reset_sub"],
		func = function() UI:StaticPopup_Show("RESET_PROFILE_PROMPT") end,
		width = 'full'
	}
end

function CUSTOM_UIOptions:SetToFontConfig(font)
	font = font or "Default";
	AceConfigDialog:SelectGroup(UI.NameID, "Fonts", "fontGroup", font);
end

local function GetUserFilterList()
	wipe(userFilterTable);
	userFilterTable[""] = NONE;
	for filter in pairs(UI.db.Filters.Custom) do
		userFilterTable[filter] = filter
	end
	return userFilterTable
end

local function GetAllFilterList()
	wipe(allFilterTable);
	allFilterTable[""] = NONE;
	for filter in pairs(UI.db.Filters) do
		if(filter == 'Raid') then
			allFilterTable[filter] = "Consolidated"
		elseif(filter ~= 'Custom') then
			allFilterTable[filter] = filter
		end
	end
	for filter in pairs(UI.db.Filters.Custom) do
		allFilterTable[filter] = filter
	end
	return allFilterTable
end

function CUSTOM_UIOptions:SetFilterOptions(filterType, selectedSpell)
	local FILTER
	CURRENT_FILTER_TYPE = filterType
	if(UI.db.Filters.Custom[filterType]) then
		FILTER = UI.db.Filters.Custom[filterType]
	else
		FILTER = UI.db.Filters[filterType]
	end
	if((not filterType) or (filterType == "") or (not FILTER)) then
		UI.Options.args.Filters.args.filterGroup = nil;
		UI.Options.args.Filters.args.spellGroup = nil;
		return
	end
	if(not self.FilterOptionGroups[filterType]) then
		self.FilterOptionGroups[filterType] = self.FilterOptionGroups['_NEW'](filterType);
	end
	UI.Options.args.Filters.args.filterGroup = self.FilterOptionGroups[filterType](selectedSpell)
	if(not self.FilterOptionSpells[filterType]) then
		self.FilterOptionSpells[filterType] = self.FilterOptionSpells['_NEW'](filterType);
	end
	UI.Options.args.Filters.args.spellGroup = self.FilterOptionSpells[filterType](selectedSpell);
	UI.Events:Trigger("AURA_FILTER_OPTIONS_CHANGED");
	collectgarbage("collect")
end


function CUSTOM_UIOptions:SetToFilterConfig(newFilter)
	local filter = newFilter or "BuffWatch";
	self:SetFilterOptions(filter);
	_G.LibStub("AceConfigDialog-1.0"):SelectGroup(UI.NameID, "Filters");
end

local generalFonts = {
	["default"] = {
		order = 1,
		name = "Default",
		desc = "Standard font for the majority of uses."
	},
	["dialog"] = {
		order = 2,
		name = "Dialog",
		desc = "Font used in places that story text appears. (ie.. quest text)"
	},
	["combat"] = {
		order = 3,
		name = "Combat",
		desc = "Scrolling combat text font."
	},
	["alert"] = {
		order = 4,
		name = "Alerts",
		desc = "Font used for on-screen message alerts."
	},
	["zone"] = {
		order = 5,
		name = "Zone Text",
		desc = "Font used for zone names. Shown when changing zones."
	},
	["title"] = {
		order = 6,
		name = "Titles",
		desc = "Font used to display various titles."
	},
	["header"] = {
		order = 7,
		name = "Frame Headers",
		desc = "Font used to large names at the top of some frames."
	},
	["caps"] = {
		order = 8,
		name = "Caps",
		desc = "Font typically used for things like tabs and fitted headers."
	},
};
local numberFonts = {
	["number"] = {
		order = 1,
		name = "Numbers (Regular)",
		desc = "Font used to display most numeric values."
	},
	["number_big"] = {
		order = 2,
		name = "Numbers (Large)",
		desc = "Font used to display larger numeric values."
	},
	["aura"]   = {
		order = 3,
		name = "Auras",
		desc = "Aura counts and timers use this font."
	},
};
local lootFonts = {
	["lootdialog"] = {
		order = 1,
		name = "Loot Frame Dialog",
		desc = "Default font used in the loot frame"
	},
    ["lootnumber"] = {
		order = 2,
		name = "Loot Frame Numbers",
		desc = "Font used in the loot frame to display numeric values."
	},
	["rolldialog"] = {
		order = 3,
		name = "Roll Frame Dialog",
		desc = "Default font used in the loot-roll frame"
	},
    ["rollnumber"] = {
		order = 4,
		name = "Roll Frame Numbers",
		desc = "Font used in the loot-roll frame to display numeric values."
	},
};
local miscFonts = {
	["data"] = {
		order = 1,
		name = "Docked Stats",
		desc = "Font used by the bottom and top data docks."
	},
	["narrator"] = {
		order = 2,
		name = "Narratives",
		desc = "Font used for things like the 'Meanwhile' tag."
	},
	["pixel"] = {
		order = 3,
		name = "Pixel",
		desc = "Tiniest fonts."
	},
};

UI.Options.args.primary = {
	type = "group",
	order = 1,
	name = L["Main"],
	get = function(j) return UI.db[j[#j]] end,
	set = function(j, value) UI.db[j[#j]] = value end,
	args = {
		introGroup1 = {
			order = 1,
			name = "",
			type = "description",
			width = "full",
			image = function() return UI.SplashImage, 256, 128 end,
		},
		introGroup2 = {
			order = 2,
			name = L["Here are a few basic quick-change options to possibly save you some time."],
			type = "description",
			width = "full",
			fontSize = "large",
		},
		quickGroup1 = {
			order = 3,
			name = "",
			type = "group",
			width = "full",
			guiInline = true,
			args = {
				Install = {
					order = 1,
					width = "full",
					type = "execute",
					name = L["Install"],
					desc = L["Run the installation process."],
					func = function() UI.Setup:LoadInstaller() UI:ToggleConfig() end
				},
				Themes = {
					order = 2,
					width = "full",
					type = "execute",
					name = L["Themes"],
					desc = L["Select an available theme."],
					func = function() UI.Setup:SelectTheme() UI:ToggleConfig() end
				},
				Backdrops = {
					order = 3,
					width = "full",
					type = "execute",
					name = L["Backdrops"],
					desc = L["Change all backdrop art randomly."],
					func = function() UI.Setup:RandomBackdrops() end
				},
				ToggleAnchors = {
					order = 4,
					width = "full",
					type = "execute",
					name = L["Move Frames"],
					desc = L["Unlock various elements of the UI to be repositioned."],
					func = function() UI:MoveAnchors() end
				},
				ResetMoveables = {
					order = 5,
					width = "full",
					type = "execute",
					name = L["Reset CUSTOM_UI Anchors"],
					desc = L["Reset all movable frames to their original positions."],
					func = function() UI:StaticPopup_Show("RESETLAYOUT_CHECK") end
				},
				ResetDraggables = {
					order = 6,
					width = "full",
					type = "execute",
					name = L["Reset Blizzard Anchors"],
					desc = L["Reset all draggable Blizzard frames to their original positions."],
					func = function() UI:StaticPopup_Show("RESETBLIZZARD_CHECK") end
				},
			},
		},
	}
}

UI.Options.args.Core = {
	type = "group",
	order = 2,
	name = L['General Options'],
	childGroups = "tab",
	get = function(key) return UI.db[key[#key]] end,
	set = function(key, value) UI.db[key[#key]] = value end,
	args = {}
}

UI.Options.args.Core.args.mostCommon = {
	type = "group",
	order = 1,
	name = "Most Common",
	guiInline = true,
	args = {
		LoginMessage = {
			order = 1,
			type = 'toggle',
			name = L['Login Messages'],
			get = function(j)return UI.db.general.loginmessage end,
			set = function(j,value)UI.db.general.loginmessage = value end
		},
		LoginCredits = {
			order = 2,
			type = 'toggle',
			name = L['Login Credits'],
			get = function(j)return UI.db.general.logincredits end,
			set = function(j,value)UI.db.general.logincredits = value end
		},
		useDraggable = {
			order = 3,
			type = "toggle",
			name = L["Enable Draggable"],
			desc = L["Allow many default Blizzard frames to be draggable"],
			get = function(j)return UI.db.general.useDraggable end,
			set = function(j,value)UI.db.general.useDraggable = value; UI:StaticPopup_Show("RL_CLIENT") end
		},
		saveDraggable = {
			order = 4,
			type = "toggle",
			name = L["Save Draggable"],
			desc = L["Save the positions of draggable frames when they are moved. NOTE: THIS WILL OVERRIDE BLIZZARD FRAME SNAPPING!"],
			get = function(j)return UI.db.general.saveDraggable end,
			set = function(j,value)UI.db.general.saveDraggable = value; UI:StaticPopup_Show("RL_CLIENT") end
		},
		cooldownText = {
			order = 5,
			type = "toggle",
			name = L['Cooldown Text'],
			desc = L["Display cooldown text on anything with the cooldown spiral."],
			get = function(j)return UI.db.general.cooldown end,
			set = function(j,value)UI.db.general.cooldown = value; UI:StaticPopup_Show("RL_CLIENT")end
		},
		texture = {
			order = 6,
			type = "group",
			name = L["Textures"],
			guiInline = true,
			get = function(key)
				return UI.Media.shared.background[key[#key]].file
			end,
			set = function(key, value)
				UI.Media.shared.background[key[#key]].file = value
				UI:RefreshEverything(true)
			end,
			args = {
				default = {
					type = "select",
					dialogControl = 'LSM30_Background',
					order = 1,
					name = L["Primary Texture"],
					desc = L["Used on almost every frame of this UI."],
					values = AceGUIWidgetLSMlists.background
				},
				pattern = {
					type = "select",
					dialogControl = 'LSM30_Background',
					order = 2,
					name = L["Secondary Texture"],
					desc = L["Used on most patterned frames."],
					values = AceGUIWidgetLSMlists.background
				},
				model = {
					type = "select",
					dialogControl = 'LSM30_Background',
					order = 3,
					name = L["ModelFrame Texture"],
					desc = L["Used behind 3D model frames. (ie..Dressing Room, Character, Pet, and Mount displays)"],
					values = AceGUIWidgetLSMlists.background
				},
				premium = {
					type = "select",
					dialogControl = 'LSM30_Background',
					order = 4,
					name = L["Unique Texture"],
					desc = L["Used in special areas. (ie..Glyphs BG)"],
					values = AceGUIWidgetLSMlists.background
				},
			}
		},
		colors = {
			order = 7,
			type = "group",
			name = L["Colors"],
			guiInline = true,
			args = {
				customClassColor = {
					type = "toggle",
					order = 1,
					name = L["Use Custom Class Colors"],
					desc = L["Use the enhanced class colors provided by CUSTOM_UI"],
					get = function(key) return UI.db.general.customClassColor end,
					set = function(key, value) UI.db.general.customClassColor = value; UI:StaticPopup_Show("RL_CLIENT") end,
				},
				default = {
					type = "color",
					order = 2,
					name = L["Primary Color"],
					desc = L["Main color used by most UI elements. (ex: Backdrop Color)"],
					hasAlpha = true,
					get = function(key)
						local color = UI.Media.color.default
						return color[1],color[2],color[3],color[4]
					end,
					set = function(key, rValue, gValue, bValue, aValue)
						UI.Media.color.default = {rValue, gValue, bValue, aValue}
						UI:UpdateSharedMedia()
					end,
				},
				secondary = {
					type = "color",
					order = 3,
					name = L["Secondary Color"],
					desc = L["Color used as contrast in multi-colored frames."],
					hasAlpha = true,
					get = function(key)
						local color = UI.Media.color.secondary
						return color[1],color[2],color[3],color[4]
					end,
					set = function(key, rValue, gValue, bValue, aValue)
						UI.Media.color.secondary = {rValue, gValue, bValue, aValue}
						UI:UpdateSharedMedia()
					end,
				},
				special = {
					type = "color",
					order = 4,
					name = L["Accent Color"],
					desc = L["Color used in various frame accents.  (ex: Dressing Room Backdrop Color)"],
					hasAlpha = true,
					get = function(key)
						local color = UI.Media.color.special
						return color[1],color[2],color[3],color[4]
					end,
					set = function(key, rValue, gValue, bValue, aValue)
						UI.Media.color.special = {rValue, gValue, bValue, aValue}
						UI.Media.color.specialdark = {(rValue * 0.75), (gValue * 0.75), (bValue * 0.75), aValue}
						UI:UpdateSharedMedia()
					end,
				},
				resetbutton = {
					type = "execute",
					order = 5,
					name = L["Restore Defaults"],
					func = function()
						UI.Media.color.default = {0.15, 0.15, 0.15, 1};
						UI.Media.color.secondary = {0.2, 0.2, 0.2, 1};
						UI.Media.color.special = {0.37, 0.32, 0.29, 1};
						UI:UpdateSharedMedia()
					end
				}
			}
		},
		loot = {
			order = 8,
			type = "toggle",
			name = L['Loot Frame'],
			desc = L['Enable/Disable the loot frame.'],
			get = function()return UI.db.general.loot end,
			set = function(j,value)UI.db.general.loot = value;UI:StaticPopup_Show("RL_CLIENT")end
		},
		lootRoll = {
			order = 9,
			type = "toggle",
			name = L['Loot Roll'],
			desc = L['Enable/Disable the loot roll frame.'],
			get = function()return UI.db.general.lootRoll end,
			set = function(j,value)UI.db.general.lootRoll = value;UI:StaticPopup_Show("RL_CLIENT")end
		},
		lootRollWidth = {
			order = 10,
			type = 'range',
			width = "full",
			name = L["Roll Frame Width"],
			min = 100,
			max = 328,
			step = 1,
			get = function()return UI.db.general.lootRollWidth end,
			set = function(a,b) UI.db.general.lootRollWidth = b; end,
		},
		lootRollHeight = {
			order = 11,
			type = 'range',
			width = "full",
			name = L["Roll Frame Height"],
			min = 14,
			max = 58,
			step = 1,
			get = function()return UI.db.general.lootRollHeight end,
			set = function(a,b) UI.db.general.lootRollHeight = b; end,
		},
	}
};

UI.Options.args.Core.args.Extras = {
	type = "group",
	order = 2,
	name = "Extras",
	guiInline = true,
	get = function(a)return UI.db["Extras"][a[#a]]end,
	set = function(a,b)UI:ChangeDBVar(b,a[#a]); end,
	args = {
		common = {
			order = 1,
			type = "group",
			name = L["General"],
			guiInline = true,
			args = {
				threatbar = {
					order = 1,
					type = 'toggle',
					name = L["Threat Thermometer"],
					desc = L["Enable/disable the custom CUSTOM_UI threat meter"],
					get = function(j)return UI.db["Extras"].threatbar end,
					set = function(j,value)UI.db["Extras"].threatbar = value; UI:StaticPopup_Show("RL_CLIENT") end
				},
				woot = {
					order = 2,
					type = 'toggle',
					name = L["Say Thanks"],
					desc = L["Thank someone when they cast specific spells on you. Typically resurrections"],
					get = function(j)return UI.db["Extras"].woot end,
					set = function(j,value)UI.db["Extras"].woot = value;UI:ToggleReactions()end
				},
				pvpinterrupt = {
					order = 3,
					type = 'toggle',
					name = L["Report PVP Actions"],
					desc = L["Announce your interrupts, as well as when you have been sapped!"],
					get = function(j)return UI.db["Extras"].pvpinterrupt end,
					set = function(j,value)UI.db["Extras"].pvpinterrupt = value;UI:ToggleReactions()end
				},
				lookwhaticando = {
					order = 4,
					type = 'toggle',
					name = L["Report Spells"],
					desc = L["Announce various helpful spells cast by players in your party/raid"],
					get = function(j)return UI.db["Extras"].lookwhaticando end,
					set = function(j,value)UI.db["Extras"].lookwhaticando = value;UI:ToggleReactions()end
				},
				sharingiscaring = {
					order = 5,
					type = 'toggle',
					name = L["Report Shareables"],
					desc = L["Announce when someone in your party/raid has laid a feast or repair bot"],
					get = function(j)return UI.db["Extras"].sharingiscaring end,
					set = function(j,value)UI.db["Extras"].sharingiscaring = value;UI:ToggleReactions()end
				},
				reactionChat = {
					order = 6,
					type = 'toggle',
					name = L["Report in Chat"],
					desc = L["Announcements will be sent to group chat channels"],
					get = function(j)return UI.db["Extras"].reactionChat end,
					set = function(j,value)UI.db["Extras"].reactionChat = value;UI:ToggleReactions()end
				},
				reactionEmote = {
					order = 7,
					type = 'toggle',
					name = L["Auto Emotes"],
					desc = L["Some announcements are accompanied by player emotes."],
					get = function(j)return UI.db["Extras"].reactionEmote end,
					set = function(j,value)UI.db["Extras"].reactionEmote = value;UI:ToggleReactions()end
				},
			}
		},
		automations = {
			order = 2,
			type = "group",
			name = L["Automations"],
			guiInline = true,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["Adjust the behavior of the many automations."]
				},
				automationGroup1 = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["Task Minions"],
					desc = L['Minions that can make certain tasks easier by handling them automatically.'],
					args = {
						mailOpener = {
							order = 1,
							type = 'toggle',
							name = L["Enable Mail Helper"],
							get = function(j) return UI.db["Extras"].mailOpener end,
							set = function(j,value) UI.db["Extras"].mailOpener = value; UI:ToggleMailMinions() end
						},
						autoAcceptInvite = {
							order = 2,
							name = L['Accept Invites'],
							desc = L['Automatically accept invites from guild/friends.'],
							type = 'toggle',
							get = function(j) return UI.db["Extras"].autoAcceptInvite end,
							set = function(j,value) UI.db["Extras"].autoAcceptInvite = value end
						},
						vendorGrays = {
							order = 3,
							name = L['Vendor Grays'],
							desc = L['Automatically vendor gray items when visiting a vendor.'],
							type = 'toggle',
							get = function(j) return UI.db["Extras"].vendorGrays end,
							set = function(j,value) UI.db["Extras"].vendorGrays = value end
						},
						pvpautorelease = {
							order = 4,
							type = "toggle",
							name = L['PvP Autorelease'],
							desc = L['Automatically release body when killed inside a battleground.'],
							get = function(j) return UI.db["Extras"].pvpautorelease end,
							set = function(j,value) UI.db["Extras"].pvpautorelease = value; UI:StaticPopup_Show("RL_CLIENT") end
						},
						autorepchange = {
							order = 5,
							type = "toggle",
							name = L['Track Reputation'],
							desc = L['Automatically change your watched faction on the reputation bar to the faction you got reputation points for.'],
							get = function(j)return UI.db["Extras"].autorepchange end,
							set = function(j,value)UI.db["Extras"].autorepchange = value end
						},
						skipcinematics = {
							order = 6,
							type = "toggle",
							name = L['Skip Cinematics'],
							desc = L['Automatically skip any cinematic sequences.'],
							get = function(j)return UI.db["Extras"].skipcinematics end,
							set = function(j,value) UI.db["Extras"].skipcinematics = value; UI:StaticPopup_Show("RL_CLIENT") end
						},
						autoRepair = {
							order = 7,
							name = L['Auto Repair'],
							desc = L['Automatically repair using the following method when visiting a merchant.'],
							type = 'select',
							values = {
								['NONE'] = NONE,
								['GUILD'] = GUILD,
								['PLAYER'] = PLAYER
							},
							get = function(j)return UI.db["Extras"].autoRepair end,
							set = function(j,value)UI.db["Extras"].autoRepair = value end
						},
					}
				},
				automationGroup2 = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Looting Minions"],
					desc = L['Minions that can make looting easier by rolling automatically.'],
					get = function(key) return UI.db.Extras[key[#key]] end,
					set = function(key,value) UI.db.Extras[key[#key]] = value; UI.Events:Trigger("LOOTING_UPVALUES_UPDATED"); end,
					disabled = function() return not UI.db.general.lootRoll end,
					args = {
						autoRoll = {
							order = 1,
							name = L['Auto Greed'],
							desc = L['Automatically select greed on loot rolls.'],
							type = 'toggle',
						},
						autoRollDisenchant = {
							order = 2,
							name = L['Auto Disenchant'],
							desc = L['"Auto Greed" will select disenchant (when available).'],
							type = 'toggle',
						},
						autoRollMaxLevel = {
							order = 3,
							name = L['Only Max Level'],
							desc = L['When set, "Auto Greed" will only operate if you are at max player level.'],
							type = 'toggle',
						},
						autoRollSoulbound = {
							order = 4,
							name = L['Allow Soulbound'],
							desc = L['When set, "Auto Greed" will include items that are BoP.'],
							type = 'toggle',
						},
						autoRollQuality = {
							order = 5,
							name = L['Max Quality'],
							desc = L['Set the highest item quality that "Auto Greed" will activate on.'],
							type = 'select',
							values = {
								['2'] = ITEM_QUALITY2_DESC,
								['3'] = ITEM_QUALITY3_DESC,
								['4'] = ITEM_QUALITY4_DESC
							},
						},
					}
				},
				automationGroup3 = {
					order = 4,
					type = "group",
					guiInline = true,
					name = L["Quest Minions"],
					desc = L['Minions that can make questing easier by automatically accepting/completing quests.'],
					args = {
						autoquestaccept = {
							order = 1,
							type = "toggle",
							name = L['Accept Quests'],
							desc = L['Automatically accepts quests as they are presented to you.'],
							get = function(j)return UI.db["Extras"].autoquestaccept end,
							set = function(j,value) UI.db["Extras"].autoquestaccept = value end
						},
						autoquestcomplete = {
							order = 2,
							type = "toggle",
							name = L['Complete Quests'],
							desc = L['Automatically complete quests when possible.'],
							get = function(j)return UI.db["Extras"].autoquestcomplete end,
							set = function(j,value)UI.db["Extras"].autoquestcomplete = value end
						},
						autoquestreward = {
							order = 3,
							type = "toggle",
							name = L['Select Quest Reward'],
							desc = L['Automatically select the quest reward with the highest vendor sell value.'],
							get = function(j)return UI.db["Extras"].autoquestreward end,
							set = function(j,value)UI.db["Extras"].autoquestreward = value end
						},
						autodailyquests = {
							order = 4,
							type = "toggle",
							name = L['Only Automate Dailies'],
							desc = L['Force the auto accept functions to only respond to daily quests. NOTE: This does not apply to daily heroics for some reason.'],
							get = function(j)return UI.db["Extras"].autodailyquests end,
							set = function(j,value)UI.db["Extras"].autodailyquests = value end
						},
						autopvpquests = {
							order = 5,
							type = "toggle",
							name = L['Accept PVP Quests'],
							get = function(j)return UI.db["Extras"].autopvpquests end,
							set = function(j,value)UI.db["Extras"].autopvpquests = value end
						},
					}
				},
			}
		},
		FunStuff = {
			type = "group",
			order = 12,
			name = L["Fun Stuff"],
			guiInline = true,
			args = {
				drunk = {
					order = 1,
					type = 'toggle',
					name = L["Drunk Mode"],
					get = function(j)return UI.db.FunStuff.drunk end,
					set = function(j,value) UI.db.FunStuff.drunk = value; UI.Drunk:Toggle() end,
				},
				NPC = {
					order = 2,
					type = 'toggle',
					width = "full",
					name = L["Gossip/Quest/Merchant Models"],
					get = function(j)return UI.db.FunStuff.NPC end,
					set = function(j,value) UI.db.FunStuff.NPC = value; end,
				},
				comix = {
					order = 3,
					type = 'select',
					name = L["Comic Popups"],
					desc = '"All Popups" will include non-comic styles (ie.. TOASTY!)',
					get = function(j)return UI.db.FunStuff.comix end,
					set = function(j,value) UI.db.FunStuff.comix = value; UI.Comix:Toggle() end,
					values = {
						['NONE'] = NONE,
						['1'] = 'All Popups',
						['2'] = 'Comic Style Only',
					}
				},
				afk = {
					order = 4,
					type = 'select',
					name = L["AFK Screen"],
					get = function(j)return UI.db.FunStuff.afk end,
					set = function(j,value) UI.db.FunStuff.afk = value; UI.AFK:Toggle() end,
					values = {
						['NONE'] = NONE,
						['1'] = 'Fully Enabled',
						['2'] = 'Enabled (No Spinning)',
					}
				},
				gamemenu = {
					order = 5,
					type = 'select',
					name = L["Game Menu"],
					get = function(j)return UI.db.FunStuff.gamemenu end,
					set = function(j,value) UI.db.FunStuff.gamemenu = value; UI:StaticPopup_Show("RL_CLIENT") end,
					values = {
						['NONE'] = NONE,
						['1'] = 'You + Henchman',
						['2'] = 'You x2',
					}
				},
			}
		},
	}
};

local function GetGearSetList()
	local t = {["none"] = L["No Change"]}
	for i = 1, GetNumEquipmentSets() do
		local name = GetEquipmentSetInfo(i)
		if name then
			t[name] = name
		end
	end
	tsort(t, sortingFunction)
	return t
end

UI.Options.args.Core.args.Gear = {
	order = 3,
	type = 'group',
	name = "Gear",
	guiInline = true,
	get = function(key) return UI.db.Gear[key[#key]]end,
	set = function(key, value) UI.db.Gear[key[#key]] = value; UI:UpdateGearInfo() end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = function()
				if(GetNumEquipmentSets()==0) then
					return ("%s\n|cffFF0000Must create an equipment set to use some of these features|r"):format(L["EQUIPMENT_DESC"])
				else
					return L["EQUIPMENT_DESC"]
				end
			end
		},
		specialization = {
			order = 2,
			type = "group",
			name = L["Specialization"],
			guiInline = true,
			disabled = function() return GetNumEquipmentSets() == 0 end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
					desc = L["Enable/Disable auto swapping gear sets when switching specializations."],
					get = function(key) return UI.db.Gear.specialization.enable end,
					set = function(key, value) UI.db.Gear.specialization.enable = value; UI:UpdateGearInfo() end
				},
				primary = {
					type = "select",
					order = 2,
					name = L["Primary Gear Set"],
					desc = L["Choose the equipment set to use for your primary specialization."],
					disabled = function() return not UI.db.Gear.specialization.enable end,
					values = GetGearSetList(),
					get = function(e) return UI.db.Gear.specialization.primary end,
					set = function(e,value) UI.db.Gear.specialization.primary = value; UI:UpdateGearInfo() end
				},
				secondary = {
					type = "select",
					order = 3,
					name = L["Secondary Gear Set"],
					desc = L["Choose the equipment set to use for your secondary specialization."],
					disabled = function() return not UI.db.Gear.specialization.enable end,
					values = GetGearSetList(),
					get = function(e) return UI.db.Gear.specialization.secondary end,
					set = function(e,value) UI.db.Gear.specialization.secondary = value; UI:UpdateGearInfo() end
				}
			}
		},
		battleground = {
			order = 3,
			type = "group",
			name = L["Battleground"],
			guiInline = true,
			disabled = function()return GetNumEquipmentSets() == 0 end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
					desc = L["Enable/Disable auto swapping gear sets in battlegrounds."],
					get = function(e) return UI.db.Gear.battleground.enable end,
					set = function(e,value) UI.db.Gear.battleground.enable = value; UI:UpdateGearInfo() end
				},
				equipmentset = {
					type = "select",
					order = 2,
					name = L["Battleground Gear Set"],
					desc = L["Choose the equipment set to use when you enter a battleground or arena."],
					disabled = function() return not UI.db.Gear.battleground.enable end,
					values = GetGearSetList(),
					get = function(e) return UI.db.Gear.battleground.equipmentset end,
					set = function(e,value) UI.db.Gear.battleground.equipmentset = value; UI:UpdateGearInfo() end
				}
			}
		},
		intro2 = {
			type = "description",
			name = L["DURABILITY_DESC"],
			order = 4
		},
		durability = {
			type = "group",
			name = DURABILITY,
			guiInline = true,
			order = 5,
			get = function(e)return UI.db.Gear.durability[e[#e]]end,
			set = function(e,value)UI.db.Gear.durability[e[#e]] = value; UI:UpdateGearInfo() end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
					desc = L["Enable/Disable the display of durability information on the character screen."]
				},
				onlydamaged = {
					type = "toggle",
					order = 2,
					name = L["Damaged Only"],
					desc = L["Only show durability information for items that are damaged."],
					disabled = function()return not UI.db.Gear.durability.enable end
				}
			}
		},
		intro3 = {
			type = "description",
			name = L["ITEMLEVEL_DESC"],
			order = 6
		},
		itemlevels = {
			type = "group",
			name = STAT_AVERAGE_ITEM_LEVEL,
			guiInline = true,
			order = 7,
			args = {
				characterItemLevel = {
					type = "toggle",
					order = 1,
					name = L["Character Screen iLevels"],
					desc = L["Enable/Disable the display of item levels on the character screen."],
					get = function(e)return UI.db.Gear.labels.characterItemLevel end,
					set = function(e,value)UI.db.Gear.labels.characterItemLevel = value; UI:UpdateGearInfo() end,
				},
				inventoryItemLevel = {
					type = "toggle",
					order = 2,
					name = L["Inventory iLevels"],
					desc = L["Enable/Disable the display of item levels in your bags (or bank)."],
					get = function(e)return UI.db.Gear.labels.inventoryItemLevel end,
					set = function(e,value)UI.db.Gear.labels.inventoryItemLevel = value; UI:UpdateGearInfo() end,
				}
			}
		},
		setNames = {
			type = "group",
			name = L["Set Labels"],
			guiInline = true,
			order = 8,
			args = {
				inventoryGearSet = {
					type = "toggle",
					order = 1,
					name = L["Equipment Set Overlay"],
					desc = L["Show the associated equipment sets for the items in your bags (or bank)."],
					get = function(e)return UI.db.Gear.labels.inventoryGearSet end,
					set = function(e,value)UI.db.Gear.labels.inventoryGearSet = value; UI:UpdateGearInfo() end,
				}
			}
		}
	}
};

UI.Options.args.Core.args.errors = {
	order = 4,
	type = "group",
	name = L["Error Handling"],
	guiInline = true,
	args = {
		filterErrors = {
			order = 1,
			name = L["Filter Errors"],
			desc = L["Choose specific errors from the list below to hide/ignore"],
			type = "toggle",
			get = function(key)return UI.db.general.filterErrors end,
			set = function(key,value)UI.db.general.filterErrors = value; UI:UpdateErrorFilters() end
		},
		hideErrorFrame = {
			order = 2,
			name = L["Combat Hide All"],
			desc = L["Hides all errors regardless of filtering while in combat."],
			type = "toggle",
			disabled = function() return not UI.db.general.filterErrors end,
			get = function(key) return UI.db.general.hideErrorFrame end,
			set = function(key,value)UI.db.general.hideErrorFrame = value; UI:UpdateErrorFilters() end
		},
		filterGroup = {
			order = 3,
			type = "group",
			guiInline = true,
			name = L["Filters"],
			disabled = function() return not UI.db.general.filterErrors end,
			args = {}
		},
	}
};

UI.Options.args.Screen = {
	type = 'group',
	name = 'Screen',
	order = 3,
	get = function(a)return UI.db.screen[a[#a]] end,
	set = function(a,b) UI.db.screen[a[#a]] = b; end,
	args = {
		commonGroup = {
			order = 1,
			type = 'group',
			name = L['Basic Options'],
			guiInline = true,
			args = {
				autoScale = {
					order = 1,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",
					get = function(j)return UI.db.screen.autoScale end,
					set = function(j,value)
						UI.db.screen.autoScale = value;
						if(value) then
							UI.db.screen.scaleAdjust = 0.64;
						end
						UI:StaticPopup_Show("RL_CLIENT")
					end
				},
				multiMonitor = {
					order = 2,
					name = L["Multi Monitor"],
					desc = L["Adjust UI dimensions to accomodate for multiple monitor setups"],
					type = "toggle",
					get = function(j)return UI.db.screen.multiMonitor end,
					set = function(j,value) UI.db.screen.multiMonitor = value; UI:StaticPopup_Show("RL_CLIENT") end
				},
			}
		},
		advancedGroup = {
			order = 2,
			type = 'group',
			name = L['Advanced Options'],
			guiInline = true,
			args = {
				advanced = {
					order = 1,
					name = L["Enable"],
					desc = L["These settings are for advanced users only!"],
					type = "toggle",
					get = function(j)return UI.db.screen.advanced end,
					set = function(j,value) UI.db.screen.advanced = value; UI:StaticPopup_Show("RL_CLIENT"); end
				},
				forcedWidth = {
					order = 2,
					name = L["Forced Width"],
					desc = function() return L["Setting your resolution height here will bypass all evaluated measurements. Current: "] .. UI.db.screen.forcedWidth; end,
					type = "input",
					disabled = function() return not UI.db.screen.advanced end,
					get = function(key) return UI.db.screen.forcedWidth end,
					set = function(key, value)
						local w = tonumber(value);
						if(not w) then
							UI:AddonMessage(L["Value must be a number"])
						elseif(w < 800) then
							UI:AddonMessage(L["Less than 800 is not allowed"])
						else
							UI.db.screen.forcedWidth = w;
							UI:StaticPopup_Show("RL_CLIENT");
						end
					end
				},
				forcedHeight = {
					order = 3,
					name = L["Forced Height"],
					desc = function() return L["Setting your resolution height here will bypass all evaluated measurements. Current: "] .. UI.db.screen.forcedHeight; end,
					type = "input",
					disabled = function() return not UI.db.screen.advanced end,
					get = function(key) return UI.db.screen.forcedHeight end,
					set = function(key, value)
						local h = tonumber(value);
						if(not h) then
							UI:AddonMessage(L["Value must be a number"])
						elseif(h < 600) then
							UI:AddonMessage(L["Less than 600 is not allowed"])
						else
							UI.db.screen.forcedHeight = h;
							UI:StaticPopup_Show("RL_CLIENT");
						end
					end
				},
				scaleAdjust = {
					order = 4,
					name = L["Base Scale"],
					desc = L["You can use this to adjust the base value applied to scale calculations."],
					type = "range",
					width = 'full',
					min = 0.25,
					max = 1,
					step = 0.01,
					disabled = function() return not UI.db.screen.advanced end,
					get = function(j)return UI.db.screen.scaleAdjust end,
					set = function(j,value)
						UI.db.screen.scaleAdjust = value;
						if(value ~= 0.64) then
							UI.db.screen.autoScale = false;
						end
						UI:StaticPopup_Show("RL_CLIENT")
					end
				},
			}
		},
	}
}
UI.Options.args.Fonts = {
	order = 4,
	type = "group",
	name = L['Fonts'],
	childGroups = "tab",
	args = {
		fontGroup = {
			order = 1,
			type = 'group',
			name = L['Font Options'],
			childGroups = "tree",
			args = {}
		}
	}
}
UI.Options.args.Dock = {
	type = "group",
	order = 5,
	name = UI.Dock.TitleID,
	args = {
	  	intro = {
			order = 1,
			type = "description",
			name = "Configure the various frame docks around the screen"
		},
		generalGroup = {
			order = 2,
			type = "group",
			name = "General",
			guiInline = true,
			get = function(key)return UI.db.Dock[key[#key]];end,
			set = function(key,value)
				UI.Dock:ChangeDBVar(value,key[#key]);
				UI.Dock:Refresh()
			end,
			args = {
				bottomPanel = {
					order = 1,
					type = 'toggle',
					name = L['Bottom Panel'],
					desc = L['Display a border across the bottom of the screen.'],
					get = function(j) return UI.db.Dock.bottomPanel end,
					set = function(key,value) UI.Dock:ChangeDBVar(value,key[#key]); end
				},
				topPanel = {
					order = 2,
					type = 'toggle',
					name = L['Top Panel'],
					desc = L['Display a border across the top of the screen.'],
					get = function(j) return UI.db.Dock.topPanel end,
					set = function(key,value) UI.Dock:ChangeDBVar(value,key[#key]); end
				},
				backdrop = {
					order = 3,
					type = 'toggle',
					name = L['Use Backdrops'],
					desc = L['Display a backdrop behind dock windows.'],
					get = function(j)return UI.db.Dock.backdrop end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value, key[#key]);
						UI.Dock:UpdateDockBackdrops()
					end
				},
				buttonSize = {
					order = 4,
					type = "range",
					name = L["Dock Button Size"],
					desc = L["PANEL_DESC"],
					min = 20,
					max = 80,
					step = 1,
					width = "full",
					get = function()return UI.db.Dock.buttonSize;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
					end,
				},
			},
		},
		LeftBottomGroup = {
			order = 3,
			type = "group",
			name = L["Bottom Left Dock"],
			guiInline = true,
			args = {
				dockLeftHeight = {
					order = 1,
					type = "range",
					name = L["Height"],
					desc = L["PANEL_DESC"],
					min = 150,
					max = 600,
					step = 1,
					get = function()return UI.db.Dock.dockLeftHeight;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
						if(UI.Chat) then
							UI.Chat:UpdateLocals()
							UI.Chat:RefreshChatFrames(true)
						end
					end,
				},
				dockLeftWidth = {
					order = 2,
					type = "range",
					name = L["Width"],
					desc = L["PANEL_DESC"],
					min = 150,
					max = 700,
					step = 1,
					get = function()return UI.db.Dock.dockLeftWidth;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
						if(UI.Chat) then
							UI.Chat:UpdateLocals()
							UI.Chat:RefreshChatFrames(true)
						end
					end,
				},
			}
		},
		RightBottomGroup = {
			order = 4,
			type = "group",
			name = L["Bottom Right Dock"],
			guiInline = true,
			args = {
				dockRightHeight = {
					order = 1,
					type = "range",
					name = L["Height"],
					desc = L["PANEL_DESC"],
					min = 150,
					max = 600,
					step = 1,
					get = function()return UI.db.Dock.dockRightHeight;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
						if(UI.Chat) then
							UI.Chat:UpdateLocals()
							UI.Chat:RefreshChatFrames(true)
						end
					end,
				},
				dockRightWidth = {
					order = 2,
					type = "range",
					name = L["Width"],
					desc = L["PANEL_DESC"],
					min = 150,
					max = 700,
					step = 1,
					get = function()return UI.db.Dock.dockRightWidth;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
						if(UI.Chat) then
							UI.Chat:UpdateLocals()
							UI.Chat:RefreshChatFrames(true)
						end
					end,
				},
			}
		},
		LeftTopGroup = {
			order = 5,
			type = "group",
			name = L["Top Left Dock"],
			guiInline = true,
			args = {
				dockTopLeftHeight = {
					order = 1,
					type = "range",
					name = L["Height"],
					desc = L["PANEL_DESC"],
					min = 150,
					max = 600,
					step = 1,
					get = function()return UI.db.Dock.dockTopLeftHeight;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
						if(UI.Chat) then
							UI.Chat:UpdateLocals()
							UI.Chat:RefreshChatFrames(true)
						end
					end,
				},
				dockTopLeftWidth = {
					order = 2,
					type = "range",
					name = L["Width"],
					desc = L["PANEL_DESC"],
					min = 150,
					max = 700,
					step = 1,
					get = function()return UI.db.Dock.dockTopLeftWidth;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
						if(UI.Chat) then
							UI.Chat:UpdateLocals()
							UI.Chat:RefreshChatFrames(true)
						end
					end,
				},
			}
		},
		RightTopGroup = {
			order = 6,
			type = "group",
			name = L["Top Right Dock"],
			guiInline = true,
			args = {
				dockTopRightHeight = {
					order = 1,
					type = "range",
					name = L["Height"],
					desc = L["PANEL_DESC"],
					min = 150,
					max = 600,
					step = 1,
					get = function()return UI.db.Dock.dockTopRightHeight;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
						if(UI.Chat) then
							UI.Chat:UpdateLocals()
							UI.Chat:RefreshChatFrames(true)
						end
					end,
				},
				dockTopRightWidth = {
					order = 2,
					type = "range",
					name = L["Width"],
					desc = L["PANEL_DESC"],
					min = 150,
					max = 700,
					step = 1,
					get = function()return UI.db.Dock.dockTopRightWidth;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
						if(UI.Chat) then
							UI.Chat:UpdateLocals()
							UI.Chat:RefreshChatFrames(true)
						end
					end,
				},
			}
		},
		dataGroup = {
			order = 7,
			type = "group",
			name = "Reports (Data Texts)",
			guiInline = true,
			get = function(key)return UI.db.Reports[key[#key]];end,
			set = function(key,value)
				UI.Reports:ChangeDBVar(value,key[#key]);
			end,
			args = {
				time24 = {
					order = 1,
					type = "toggle",
					name = L["24-Hour Time"],
					desc = L["Toggle 24-hour mode for the time datatext."],
				},
				localtime = {
					order = 2,
					type = "toggle",
					name = L["Local Time"],
					desc = L["If not set to true then the server time will be displayed instead."]
				},
				battleground = {
					order = 3,
					type = "toggle",
					name = L["Battleground Texts"],
					desc = L["When inside a battleground display personal scoreboard information on the main datatext bars."]
				},
				backdrop = {
					order = 4,
					name = "Data Backgrounds",
					desc = L["Display background textures on docked data texts"],
					type = "toggle",
					set = function(key, value) UI.Reports:ChangeDBVar(value, key[#key]); UI.Reports:UpdateAllReports() end,
				},
				shortGold = {
					order = 5,
					type = "toggle",
					name = L["Shortened Gold Text"],
				},
				spacer1 = {
					order = 6,
					name = "",
					type = "description",
					width = "full",
				},
				dockCenterWidth = {
					order = 7,
					type = 'range',
					name = L['Stat Panel Width'],
					desc = L["PANEL_DESC"],
					min = 400,
					max = 1800,
					step = 1,
					width = "full",
					get = function()return UI.db.Dock.dockCenterWidth; end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
					end,
				},
				spacer2 = {
					order = 8,
					name = "",
					type = "description",
					width = "full",
				},
				buttonSize = {
					order = 9,
					type = "range",
					name = L["Dock Button Size"],
					desc = L["PANEL_DESC"],
					min = 20,
					max = 80,
					step = 1,
					width = "full",
					get = function()return UI.db.Dock.buttonSize;end,
					set = function(key,value)
						UI.Dock:ChangeDBVar(value,key[#key]);
						UI.Dock:Refresh()
					end,
				},
			}
		},
		toolsGroup = {
			order = 8,
			type = "group",
			name = L["Dock Tools"],
			guiInline = true,
			get = function(key) return UI.db.Dock.dockTools[key[#key]] end,
			set = function(key,value) UI.Dock:ChangeDBVar(value, key[#key], "dockTools"); UI:StaticPopup_Show("RL_CLIENT"); end,
			args = {
				garrison = {
					order = 1,
					type = 'toggle',
					name = L['Garrison Utility'],
					desc = L['Left click for landing, right click to use Garrison hearth.'],
				},
				leader = {
					order = 2,
					type = 'toggle',
					name = L['Raid Leader'],
					desc = L['Quick launch menu of raid leader tools.'],
				},
				primary = {
					order = 3,
					type = 'toggle',
					name = L['Primary Profession'],
					desc = L['Quick launch of your primary profession window'],
				},
				secondary = {
					order = 4,
					type = 'toggle',
					name = L['Secondary Profession'],
					desc = L['Quick launch of your secondary profession window'],
				},
				firstAid = {
					order = 5,
					type = 'toggle',
					name = L['First Aid'],
					desc = L['Quick launch of your first aid window'],
				},
				cooking = {
					order = 6,
					type = 'toggle',
					name = L['Cooking'],
					desc = L['Quick launch of your cooking window'],
				},
				archaeology = {
					order = 7,
					type = 'toggle',
					name = L['Archaeology'],
					desc = L['Quick launch of your archaeology window'],
				},
				hearth = {
					order = 8,
					type = 'toggle',
					name = L['Hearth Tool'],
					desc = L['Left click to use your hearthstone, right click for various class-based options.'],
				},
				specswap = {
					order = 9,
					type = 'toggle',
					name = L['Spec Swap'],
					desc = L['Click to simply swap specs (out of combat).'],
				},
				breakstuff = {
					order = 10,
					type = 'toggle',
					name = L['Break Stuff'],
					desc = L['This tool, when available and enabled, will allow you to single click items in your bags for certain abilities. [Milling, Prospecting, Disenchanting, Lockpicking or use a Skeleton Key]'],
				},
				power = {
					order = 11,
					type = 'toggle',
					name = L['Power Button'],
					desc = L['This tool gives you one-click access to logging out, reloading the UI and exiting the game]'],
				},
			}
		},
		reportGroup1 = {
			order = 9,
			type = "group",
			name = L["Bottom Stats: Left"],
			guiInline = true,
			args = {}
		},
		reportGroup2 = {
			order = 10,
			type = "group",
			name = L["Bottom Stats: Right"],
			guiInline = true,
			args = {}
		},
		reportGroup3 = {
			order = 11,
			type = "group",
			name = L["Top Stats: Left"],
			guiInline = true,
			args = {}
		},
		reportGroup4 = {
			order = 12,
			type = "group",
			name = L["Top Stats: Right"],
			guiInline = true,
			args = {}
		},
		AddonDocklets = {
			order = 13,
			type = "group",
			name = L["Docked Addons"],
			guiInline = true,
			args = {
				DockletMain = {
					type = "select",
					order = 1,
					name = "Primary Docklet",
					desc = "Select an addon to occupy the primary docklet window",
					values = function() return GetLiveDockletsA() end,
					get = function() return UI.private.Docks.Embed1 end,
					set = function(a,value) UI.private.Docks.Embed1 = value; if(UI.Skins) then UI.Skins:RegisterAddonDocklets() end end,
				},
				DockletSplit = {
					type = "select",
					order = 2,
					name = "Secondary Docklet",
					desc = "Select another addon",
					--disabled = function() return (UI.private.Docks.Embed1 == "None") end,
					values = function() return GetLiveDockletsB() end,
					get = function() return UI.private.Docks.Embed2 end,
					set = function(a,value) UI.private.Docks.Embed2 = value; if(UI.Skins) then UI.Skins:RegisterAddonDocklets() end end,
				}
			}
		},
	}
}
UI.Options.args.Filters = {
	type = "group",
	name = L["Aura Filters"],
	order = 9996,
	args = {}
}

local listIndex = 1;
local filterGroup = UI.Options.args.Core.args.errors.args.filterGroup.args;
for errorName, state in pairs(UI.db.general.errorFilters) do
	filterGroup[errorName] = {
		order = listIndex,
		type = 'toggle',
		name = errorName,
		width = 'full',
		get = function(key) return UI.db.general.errorFilters[errorName]; end,
		set = function(key,value) UI.db.general.errorFilters[errorName] = value; UI:UpdateErrorFilters() end
	}
	listIndex = listIndex + 1
end

local statValues = {[""] = "None"};
for name, _ in pairs(UI.Reports.Plugins) do
	statValues[name] = name;
end

for panelIndex, panelPositions in pairs(UI.db.REPORT_SLOTS) do
	local panelName = 'reportGroup' .. panelIndex;
	local optionTable = UI.Options.args.Dock.args;
	if(optionTable[panelName] and type(panelPositions) == "table") then
		for i = 1, #panelPositions do
			local slotName = 'Slot' .. i;
			optionTable[panelName].args[slotName] = {
				order = i,
				type = 'select',
				name = 'Slot '..i,
				values = statValues,
				get = function(key) return UI.db.REPORT_SLOTS[panelIndex][i] end,
				set = function(key, value) UI.db.REPORT_SLOTS[panelIndex][i] = value; UI.Reports:UpdateAllReports() end
			}
		end
	end
end

UI:GenerateFontOptionGroup("General", 1, "The most commonly used fonts. Changing these will require reloading the UI.", generalFonts)
UI:GenerateFontOptionGroup("Numeric", 2, "These fonts are used for many number values.", numberFonts)
UI:GenerateFontOptionGroup("Loot", 3, "Fonts used in loot frames.", lootFonts)
UI:GenerateFontOptionGroup("Misc", 4, "Fonts used in various places including the docks.", miscFonts)

UI_Registry:LoadModuleOptions()
RefreshProfileOptions()

CUSTOM_UIOptions.FilterOptionGroups['_NEW'] = function(filterType)
	return function()
		local RESULT, FILTER
		if(UI.db.Filters.Custom[filterType]) then
			FILTER = UI.db.Filters.Custom[filterType]
		else
			FILTER = UI.db.Filters[filterType]
		end
		if(FILTER) then
			RESULT = {
				type = "group",
				name = filterType,
				guiInline = true,
				order = 4,
				args = {
					alertAction = {
						order = 1,
						name = "",
						type = "description",
						get = function(key) return "" end,
					},
					addSpell = {
						order = 2,
						name = L["Add Spell"],
						desc = L["Add a spell to the filter. You can add by name, or ID (number). If the spell is in your spellbook or on an actionbar then you can drag and drop it here."],
						type = "input",
						get = function(key) RESULT.args.alertAction.name = ""; return "" end,
						set = function(key, value)
							local spellID = tonumber(value);
							if(not spellID) then
								spellID = select(7, GetSpellInfo(value))
							end
							RESULT.args.alertAction.name = "";
							if((not spellID) or (not GetSpellInfo(spellID))) then
								UI:AddonMessage(L["Spell Not Found"])
								RESULT.args.alertAction.name = '|cffFF0000'..L["Spell Not Found"]..'|r';
							elseif(not FILTER[value]) then
								FILTER[value] = {['enable'] = true, ['id'] = spellID, ['priority'] = 0}
								CUSTOM_UIOptions:SetFilterOptions(filterType)
								UI.Events:Trigger("AURA_FILTER_OPTIONS_CHANGED");
							end
						end
					},
					removeSpell = {
						order = 3,
						name = L["Remove Spell"],
						desc = L["Remove a spell from the filter."],
						type = "select",
						disabled = function()
							local EMPTY = true;
							for g in pairs(FILTER) do
								EMPTY = false;
							end
							return EMPTY
						end,
						values = function()
							wipe(tempFilterTable)
							for id, filterData in pairs(FILTER) do
								if(type(id) == 'string' and filterData.id) then
									local auraName = GetSpellInfo(filterData.id)
									if(auraName) then
										tempFilterTable[id] = auraName
									end
								end
							end
							return tempFilterTable
						end,
						get = function(key) return "" end,
						set = function(key, value)
							if(FILTER[value]) then
								if(FILTER[value].isDefault) then
									FILTER[value].enable = false;
									UI:AddonMessage(L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."])
								else
									FILTER[value] = nil
								end
							end
							CUSTOM_UIOptions:SetFilterOptions(filterType)
							UI.Events:Trigger("AURA_FILTER_OPTIONS_CHANGED");
						end
					},
				}
			};
		end;
		return RESULT;
	end;
end;

CUSTOM_UIOptions.FilterOptionSpells['_NEW'] = function(filterType)
	return function()
		local RESULT, FILTER
		if(UI.db.Filters.Custom[filterType]) then
			FILTER = UI.db.Filters.Custom[filterType]
		else
			FILTER = UI.db.Filters[filterType]
		end
		if(FILTER) then
			RESULT = {
				type = "group",
				name = filterType .. " - " .. L["Spells"],
				order = 5,
				guiInline = true,
				args = {}
			};
			local hasSpells = false;
			for id, filterData in pairs(FILTER) do
				local auraName = GetSpellInfo(filterData.id)
				if(auraName) then
					RESULT.args[auraName] = {
						name = auraName,
						type = "toggle",
						get = function()
							return FILTER[id].enable
						end,
						set = function(key, value)
							FILTER[id].enable = value;
							UI.Events:Trigger("AURA_FILTER_OPTIONS_CHANGED");
							CUSTOM_UIOptions:SetFilterOptions(filterType)
						end
					};
					hasSpells = true
				end
			end
			if(not hasSpells) then
				RESULT.args.alertAction = {
					order = 1,
					name = '|cffFF0000'..L["No Spells"]..'|r',
					type = "description",
					get = function(key) return "" end,
				};
			end
		end
		return RESULT;
	end;
end;

UI.Options.args.Filters.args.createFilter = {
	order = 1,
	name = L["Create Filter"],
	desc = L["Create a custom filter."],
	type = "input",
	get = function(key) return "" end,
	set = function(key, value)
		if(not value or (value and value == '')) then
			UI:AddonMessage(L["Not a usable filter name"])
		elseif(UI.db.Filters.Custom[value]) then
			UI:AddonMessage(L["Filter already exists"])
		else
			UI.db.Filters.Custom[value] = {};
			CUSTOM_UIOptions:SetFilterOptions(value);
		end
	end
};

UI.Options.args.Filters.args.deleteFilter = {
	type = "select",
	order = 2,
	name = L["Delete Filter"],
	desc = L["Delete a custom filter."],
	get = function(key) return "" end,
	set = function(key, value)
		UI.db.Filters.Custom[value] = nil;
		UI.Options.args.Filters.args.filterGroup = nil
	end,
	values = GetUserFilterList()
};

UI.Options.args.Filters.args.selectFilter = {
	order = 3,
	type = "select",
	name = L["Select Filter"],
	get = function(key) return CURRENT_FILTER_TYPE end,
	set = function(key, value) CUSTOM_UIOptions:SetFilterOptions(value) end,
	values = GetAllFilterList()
};

UI.OptionsLoaded = true;
