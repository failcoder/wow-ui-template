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
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;

--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--TABLE
local table 		= _G.table;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe 		= _G.wipe;
--MATH
local math      	= _G.math;
local min 			= math.min;
local floor         = math.floor;
local ceil          = math.ceil;
local parsefloat 	= math.parsefloat;
--BLIZZARD API
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
--[[
##########################################################
ADDON
##########################################################
]]--
local UI = select(2, ...)
local L = UI.L

UI.Dropdown = _G["CUSTOM_UI_DropdownFrame"];

local DropdownButton_OnClick = function(self)
	self.func(self.target);
	ToggleFrame(UI.Dropdown);
end

local DropdownSlider_OnValueChanged = function(self, value)
	local result = parsefloat(value, 2)
	self.Text:SetText(result);
	self.func(self.target, result);
end

local DropdownButton_OnEnter = function(self)
	self.hoverTex:Show();
end

local DropdownButton_OnLeave = function(self)
	self.hoverTex:Hide();
end

local function GetScreenPosition(frame)
	local parent = frame:GetParent()
	local centerX, centerY = parent:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local result;
	if not centerX or not centerY then
		return "CENTER"
	end
	local heightTop = screenHeight * 0.75;
	local heightBottom = screenHeight * 0.25;
	local widthLeft = screenWidth * 0.25;
	local widthRight = screenWidth * 0.75;
	if(((centerX > widthLeft) and (centerX < widthRight)) and (centerY > heightTop)) then
		result = "TOP"
	elseif((centerX < widthLeft) and (centerY > heightTop)) then
		result = "TOPLEFT"
	elseif((centerX > widthRight) and (centerY > heightTop)) then
		result = "TOPRIGHT"
	elseif(((centerX > widthLeft) and (centerX < widthRight)) and centerY < heightBottom) then
		result = "BOTTOM"
	elseif((centerX < widthLeft) and (centerY < heightBottom)) then
		result = "BOTTOMLEFT"
	elseif((centerX > widthRight) and (centerY < heightBottom)) then
		result = "BOTTOMRIGHT"
	elseif((centerX < widthLeft) and (centerY > heightBottom) and (centerY < heightTop)) then
		result = "LEFT"
	elseif((centerX > widthRight) and (centerY < heightTop) and (centerY > heightBottom)) then
		result = "RIGHT"
	else
		result = "CENTER"
	end
	return result
end

function UI.Dropdown:Open(target, list, titleText, colWidth)
	if(InCombatLockdown() or (not list)) then return end

	if(not self.option) then
		self.option = {};
	end

	local maxPerColumn = 25;
	local cols = 1;

	if(titleText) then
		self.Title:SetText(titleText)
	else
		self.Title:SetText("Menu")
	end

	for i=1, #self.option do
		self.option[i].button:Hide();
		self.option[i].divider:Hide();
		self.option[i].header:Hide();
		self.option[i].slider:Hide();
		self.option[i]:Hide();
	end

	local heightOffset = 50;
	local heightPadded = false;
	colWidth = colWidth or 135;

	for i=1, #list do
		if(not self.option[i]) then
			-- HOLDER
			self.option[i] = CreateFrame("Frame", nil, self);
			self.option[i]:SetHeight(16);
			self.option[i]:SetWidth(colWidth);

			-- DIVIDER
			self.option[i].divider = self.option[i]:CreateTexture(nil, 'BORDER');
			self.option[i].divider:SetAllPoints();
			self.option[i].divider:SetTexture([[Interface\AddOns\CUSTOM_UI\media\textures\DROPDOWN-DIVIDER]]);
			self.option[i].divider:Hide();

			self.option[i].header = self.option[i]:CreateFontString(nil, 'OVERLAY');
			self.option[i].header:SetAllPoints();
			self.option[i].header:SetFont(UI.Media.font.default, 10, "OUTLINE");
			self.option[i].header:SetTextColor(1, 0.8, 0)
			self.option[i].header:SetJustifyH("CENTER");
			self.option[i].header:SetJustifyV("MIDDLE");

			-- BUTTON
			self.option[i].button = CreateFrame("Button", nil, self.option[i]);
			self.option[i].button:SetAllPoints();

			self.option[i].button.hoverTex = self.option[i].button:CreateTexture(nil, 'OVERLAY');
			self.option[i].button.hoverTex:SetAllPoints();
			self.option[i].button.hoverTex:SetTexture([[Interface\AddOns\CUSTOM_UI\media\textures\TITLE-HIGHLIGHT]]);
			self.option[i].button.hoverTex:SetBlendMode("ADD");
			self.option[i].button.hoverTex:Hide();

			self.option[i].button.text = self.option[i].button:CreateFontString(nil, 'BORDER');
			self.option[i].button.text:SetAllPoints();
			self.option[i].button.text:SetFont(UI.Media.font.default, 12, "OUTLINE");
			self.option[i].button.text:SetJustifyH("LEFT");

			self.option[i].button:SetScript("OnEnter", DropdownButton_OnEnter);
			self.option[i].button:SetScript("OnLeave", DropdownButton_OnLeave);

			--CUSTOM_UI_DDSliderTemplate
			-- SLIDER
			self.option[i].slider = CreateFrame("Slider", nil, self.option[i], "CUSTOM_UI_TinySliderTemplate");
			self.option[i].slider:SetPoint("TOPLEFT", self.option[i], "TOPLEFT", 0, -3);
			self.option[i].slider:SetPoint("BOTTOMRIGHT", self.option[i], "BOTTOMRIGHT", 0, 3);
			self.option[i].slider.Text:SetJustifyH("CENTER");
			self.option[i].slider.Low:SetJustifyH("LEFT");
			self.option[i].slider.High:SetJustifyH("RIGHT");
		else
			self.option[i]:SetWidth(colWidth);
		end

		self.option[i]:Show();

		self.option[i].button:SetScript("OnClick", nil);
		self.option[i].slider:SetScript("OnValueChanged", nil);

		local yOffset = heightPadded and 12 or 0;
		if(list[i].range) then
			yOffset = 12;
			local minRange, maxRange = list[i].range[1], list[i].range[2];
			local saved = list[i].value or 0;
			local value = parsefloat(saved, 2)
			self.option[i].button:Hide();
			self.option[i].header:Hide();
			self.option[i].slider:Show();
			self.option[i].slider.target = target;
			self.option[i].slider:SetMinMaxValues(minRange, maxRange);
			self.option[i].slider:SetValue(value);
			self.option[i].slider.Low:SetText(minRange);
			self.option[i].slider.High:SetText(maxRange);
			self.option[i].slider.Text:SetText(value);
			self.option[i].slider.func = list[i].func;
			self.option[i].slider:SetScript("OnValueChanged", DropdownSlider_OnValueChanged);
			heightPadded = true;
		else
			if(list[i].title) then
				self.option[i].button:Hide();
				self.option[i].slider:Hide();
				self.option[i].header:Show();
				self.option[i].header:SetText(list[i].title);
				if(list[i].divider) then self.option[i].divider:Show(); end
			elseif(list[i].text) then
				local lineText = list[i].text;
				if(list[i].icon) then
					lineText = list[i].icon .. list[i].text
				end
				self.option[i].header:Hide();
				self.option[i].slider:Hide();
				self.option[i].button:Show();
				self.option[i].button.target = target;
				self.option[i].button.text:SetText(lineText);
				self.option[i].button.func = list[i].func;
				self.option[i].button:SetScript("OnClick", DropdownButton_OnClick);
			end
			heightPadded = false;
		end

		heightOffset = heightOffset + yOffset;

		if(i == 1) then
			self.option[i]:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -30)
		elseif((i - 1) % maxPerColumn == 0) then
			self.option[i]:SetPoint("TOPLEFT", self.option[i - maxPerColumn], "TOPRIGHT", 10, 0)
			cols = cols + 1
		else
			self.option[i]:SetPoint("TOPLEFT", self.option[i - 1], "BOTTOMLEFT", 0, -yOffset)
		end
	end

	local maxHeight = (min(maxPerColumn, #list) * 16) + heightOffset;
	local maxWidth = (colWidth * cols) + (10 * cols) + 10;
	local point = GetScreenPosition(target);

	self:ClearAllPoints();
	self:SetSize(maxWidth, maxHeight);

	if(point:find("BOTTOM")) then
		self:SetPoint("BOTTOMLEFT", target, "TOPLEFT", 10, 10);
	else
		self:SetPoint("TOPLEFT", target, "BOTTOMLEFT", 10, -10);
	end

	if(GameTooltip:IsShown()) then
		GameTooltip:Hide();
	end

	ToggleFrame(self);
end

local function InitializeDropdown()
	UI.Dropdown:SetParent(UI.Screen)
	UI.Dropdown:SetFrameStrata("FULLSCREEN_DIALOG")
	UI.Dropdown:SetFrameLevel(99)
	UI.Dropdown:SetStyle("Frame", "Default")
	UI.Dropdown.option = {};
	UI.Dropdown.close = CreateFrame("Button", nil, UI.Dropdown, "UIPanelCloseButton")
	UI.Dropdown.close:SetPoint("TOPRIGHT", UI.Dropdown, "TOPRIGHT")
	UI.Dropdown.close:SetScript("OnClick", function() ToggleFrame(UI.Dropdown) end)
	UI.API:Set("CloseButton", UI.Dropdown.close)
	UI.Dropdown.Title = UI.Dropdown:CreateFontString(nil, "OVERLAY")
	UI.Dropdown.Title:SetFont(UI.Media.font.zone, 16, "OUTLINE")
	UI.Dropdown.Title:SetPoint("TOPLEFT", UI.Dropdown, "TOPLEFT", 7, -7)
	UI.Dropdown.Title:SetText("Menu")
	UI.Dropdown.Title:SetTextColor(1, 0.5, 0)
	UI.Dropdown:SetClampedToScreen(true);
	UI.Dropdown:SetSize(155, 94)

	tinsert(UISpecialFrames, UI.Dropdown:GetName());
	UI.Dropdown:Hide();

	-- WorldFrame:HookScript("OnMouseDown", function()
	-- 	if(UI.Dropdown:IsShown()) then
	-- 		ToggleFrame(UI.Dropdown)
	-- 	end
	-- end)

	UI:ManageVisibility(UI.Dropdown)
end

UI.Events:On("LOAD_ALL_WIDGETS", InitializeDropdown);
