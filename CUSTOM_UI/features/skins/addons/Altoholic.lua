--[[
##########################################################
S V U I   By: Munglunch
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local UI = _G['CUSTOM_UI'];
local L = UI.L;
local MOD = UI.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
ALTOHOLIC
##########################################################
]]--
local function ColorAltoBorder(self)
	if self.border then
		local Backdrop = self.backdrop or self.Backdrop
		if not Backdrop then return end
		local r, g, b = self.border:GetVertexColor()
		Backdrop:SetBackdropBorderColor(r, g, b, 1)
	end
end

local function ApplyTextureStyle(self)
	if not self then return end
	self:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
	local parent = self:GetParent()
	if(parent) then
		self:InsetPoints(parent, 1, 1)
	end
end

local AltoholicFrameStyled = false;

local function StyleAltoholic(event, addon)
	assert(AltoholicFrame, "AddOn Not Loaded")

	if not AltoholicFrameStyled then
		UI.API:Set("Tooltip", AltoTooltip)

		AltoholicFramePortrait:Die()

		UI.API:Set("Frame", AltoholicFrame, "Window2")
		UI.API:Set("Frame", AltoMsgBox)
		UI.API:Set("Button", AltoMsgBoxYesButton)
		UI.API:Set("Button", AltoMsgBoxNoButton)
		UI.API:Set("CloseButton", AltoholicFrameCloseButton)
		UI.API:Set("EditBox", AltoholicFrame_SearchEditBox, 175, 15)
		UI.API:Set("Button", AltoholicFrame_ResetButton)
		UI.API:Set("Button", AltoholicFrame_SearchButton)

		AltoholicFrameTab1:SetPoint("TOPLEFT", AltoholicFrame, "BOTTOMLEFT", -5, 2)
		AltoholicFrame_ResetButton:SetPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 25, -77)
		AltoholicFrame_SearchEditBox:SetPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 37, -56)
		AltoholicFrame_ResetButton:SetSize(85, 24)
		AltoholicFrame_SearchButton:SetSize(85, 24)
		AltoholicFrameStyled = true
	end

	if IsAddOnLoaded("Altoholic_Summary") then
		UI.API:Set("Frame", AltoholicFrameSummary)
		UI.API:Set("Frame", AltoholicFrameBagUsage)
		UI.API:Set("Frame", AltoholicFrameSkills)
		UI.API:Set("Frame", AltoholicFrameActivity)
		UI.API:Set("ScrollBar", AltoholicFrameSummaryScrollFrameScrollBar)
		UI.API:Set("ScrollBar", AltoholicFrameBagUsageScrollFrameScrollBar)
		UI.API:Set("ScrollBar", AltoholicFrameSkillsScrollFrameScrollBar)
		UI.API:Set("ScrollBar", AltoholicFrameActivityScrollFrameScrollBar)
		UI.API:Set("DropDown", AltoholicTabSummary_SelectLocation, 200)

		if(AltoholicFrameSummaryScrollFrame) then
			AltoholicFrameSummaryScrollFrame:RemoveTextures(true)
		end

		if(AltoholicFrameBagUsageScrollFrame) then
			AltoholicFrameBagUsageScrollFrame:RemoveTextures(true)
		end

		if(AltoholicFrameSkillsScrollFrame) then
			AltoholicFrameSkillsScrollFrame:RemoveTextures(true)
		end

		if(AltoholicFrameActivityScrollFrame) then
			AltoholicFrameActivityScrollFrame:RemoveTextures(true)
		end

		UI.API:Set("Button", AltoholicTabSummary_RequestSharing)
		ApplyTextureStyle(AltoholicTabSummary_RequestSharingIconTexture)
		UI.API:Set("Button", AltoholicTabSummary_Options)
		ApplyTextureStyle(AltoholicTabSummary_OptionsIconTexture)
		UI.API:Set("Button", AltoholicTabSummary_OptionsDataStore)
		ApplyTextureStyle(AltoholicTabSummary_OptionsDataStoreIconTexture)

		for i = 1, 5 do
			UI.API:Set("Button", _G["AltoholicTabSummaryMenuItem"..i], true)
		end
		for i = 1, 8 do
			UI.API:Set("Button", _G["AltoholicTabSummary_Sort"..i], true)
		end
		for i = 1, 7 do
			UI.API:Set("Tab", _G["AltoholicFrameTab"..i], true)
		end
	end

	if IsAddOnLoaded("Altoholic_Characters") then
		UI.API:Set("Frame", AltoholicFrameContainers)
		UI.API:Set("Frame", AltoholicFrameRecipes)
		UI.API:Set("Frame", AltoholicFrameQuests)
		UI.API:Set("Frame", AltoholicFrameGlyphs)
		UI.API:Set("Frame", AltoholicFrameMail)
		UI.API:Set("Frame", AltoholicFrameSpellbook)
		UI.API:Set("Frame", AltoholicFramePets)
		UI.API:Set("Frame", AltoholicFrameAuctions)
		UI.API:Set("ScrollBar", AltoholicFrameContainersScrollFrameScrollBar)
		UI.API:Set("ScrollBar", AltoholicFrameQuestsScrollFrameScrollBar)
		UI.API:Set("ScrollBar", AltoholicFrameRecipesScrollFrameScrollBar)
		UI.API:Set("DropDown", AltoholicFrameTalents_SelectMember)
		UI.API:Set("DropDown", AltoholicTabCharacters_SelectRealm)
		UI.API:Set("PageButton", AltoholicFrameSpellbookPrevPage)
		UI.API:Set("PageButton", AltoholicFrameSpellbookNextPage)
		UI.API:Set("PageButton", AltoholicFramePetsNormalPrevPage)
		UI.API:Set("PageButton", AltoholicFramePetsNormalNextPage)
		UI.API:Set("Button", AltoholicTabCharacters_Sort1)
		UI.API:Set("Button", AltoholicTabCharacters_Sort2)
		UI.API:Set("Button", AltoholicTabCharacters_Sort3)
		AltoholicFrameContainersScrollFrame:RemoveTextures(true)
		AltoholicFrameQuestsScrollFrame:RemoveTextures(true)
		AltoholicFrameRecipesScrollFrame:RemoveTextures(true)

		local Buttons = {
			'AltoholicTabCharacters_Characters',
			'AltoholicTabCharacters_CharactersIcon',
			'AltoholicTabCharacters_BagsIcon',
			'AltoholicTabCharacters_QuestsIcon',
			'AltoholicTabCharacters_TalentsIcon',
			'AltoholicTabCharacters_AuctionIcon',
			'AltoholicTabCharacters_MailIcon',
			'AltoholicTabCharacters_SpellbookIcon',
			'AltoholicTabCharacters_ProfessionsIcon',
		}

		for _, object in pairs(Buttons) do
			ApplyTextureStyle(_G[object..'IconTexture'])
			ApplyTextureStyle(_G[object])
		end

		for i = 1, 7 do
			for j = 1, 14 do
				UI.API:Set("ItemButton", _G["AltoholicFrameContainersEntry"..i.."Item"..j])
				_G["AltoholicFrameContainersEntry"..i.."Item"..j]:HookScript('OnShow', ColorAltoBorder)
			end
		end
	end

	if IsAddOnLoaded("Altoholic_Achievements") then
		UI.API:Set("!_Frame", AltoholicFrameAchievements)
		AltoholicFrameAchievementsScrollFrame:RemoveTextures(true)
		AltoholicAchievementsMenuScrollFrame:RemoveTextures(true)
		UI.API:Set("ScrollBar", AltoholicFrameAchievementsScrollFrameScrollBar)
		UI.API:Set("ScrollBar", AltoholicAchievementsMenuScrollFrameScrollBar)
		UI.API:Set("DropDown", AltoholicTabAchievements_SelectRealm)
		AltoholicTabAchievements_SelectRealm:SetPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 205, -57)

		for i = 1, 15 do
			UI.API:Set("Button", _G["AltoholicTabAchievementsMenuItem"..i], true)
		end

		for i = 1, 8 do
			for j = 1, 10 do
				UI.API:Set("!_Frame", _G["AltoholicFrameAchievementsEntry"..i.."Item"..j])
				local Backdrop = _G["AltoholicFrameAchievementsEntry"..i.."Item"..j].backdrop or _G["AltoholicFrameAchievementsEntry"..i.."Item"..j].Backdrop
				ApplyTextureStyle(_G["AltoholicFrameAchievementsEntry"..i.."Item"..j..'_Background'])
				_G["AltoholicFrameAchievementsEntry"..i.."Item"..j..'_Background']:SetInside(Backdrop)
			end
		end
	end

	if IsAddOnLoaded("Altoholic_Agenda") then
		UI.API:Set("Frame", AltoholicFrameCalendarScrollFrame)
		UI.API:Set("Frame", AltoholicTabAgendaMenuItem1)
		UI.API:Set("ScrollBar", AltoholicFrameCalendarScrollFrameScrollBar)
		UI.API:Set("PageButton", AltoholicFrameCalendar_NextMonth)
		UI.API:Set("PageButton", AltoholicFrameCalendar_PrevMonth)
		UI.API:Set("Button", AltoholicTabAgendaMenuItem1, true)

		for i = 1, 14 do
			UI.API:Set("Frame", _G["AltoholicFrameCalendarEntry"..i])
		end
	end

	if IsAddOnLoaded("Altoholic_Grids") then
		AltoholicFrameGridsScrollFrame:RemoveTextures(true)
		UI.API:Set("!_Frame", AltoholicFrameGrids)
		UI.API:Set("ScrollBar", AltoholicFrameGridsScrollFrameScrollBar)
		UI.API:Set("DropDown", AltoholicTabGrids_SelectRealm)
		UI.API:Set("DropDown", AltoholicTabGrids_SelectView)

		for i = 1, 8 do
			for j = 1, 10 do
				UI.API:Set("!_Frame", _G["AltoholicFrameGridsEntry"..i.."Item"..j])
				_G["AltoholicFrameGridsEntry"..i.."Item"..j]:HookScript('OnShow', ColorAltoBorder)
			end
		end

		AltoholicFrameGrids:HookScript('OnUpdate', function()
			for i = 1, 10 do
				for j = 1, 10 do
					if _G["AltoholicFrameGridsEntry"..i.."Item"..j.."_Background"] then
						_G["AltoholicFrameGridsEntry"..i.."Item"..j.."_Background"]:SetTexCoord(.08, .92, .08, .82)
					end
				end
			end
		end)

	end

	if IsAddOnLoaded("Altoholic_Guild") then
		UI.API:Set("Frame", AltoholicFrameGuildMembers)
		UI.API:Set("Frame", AltoholicFrameGuildBank)
		UI.API:Set("ScrollBar", AltoholicFrameGuildMembersScrollFrameScrollBar)
		AltoholicFrameGuildMembersScrollFrame:RemoveTextures(true)

		for i = 1, 2 do
			UI.API:Set("Button", _G["AltoholicTabGuildMenuItem"..i])
		end

		for i = 1, 7 do
			for j = 1, 14 do
				UI.API:Set("ItemButton", _G["AltoholicFrameGuildBankEntry"..i.."Item"..j])
			end
		end

		for i = 1, 19 do
			UI.API:Set("ItemButton", _G["AltoholicFrameGuildMembersItem"..i])
		end

		for i = 1, 5 do
			UI.API:Set("Button", _G["AltoholicTabGuild_Sort"..i])
		end
	end

	if IsAddOnLoaded("Altoholic_Search") then
		UI.API:Set("!_Frame", AltoholicFrameSearch)
		AltoholicFrameSearchScrollFrame:RemoveTextures(true)
		AltoholicSearchMenuScrollFrame:RemoveTextures(true)
		UI.API:Set("ScrollBar", AltoholicFrameSearchScrollFrameScrollBar)
		UI.API:Set("ScrollBar", AltoholicSearchMenuScrollFrameScrollBar)
		UI.API:Set("DropDown", AltoholicTabSearch_SelectRarity)
		UI.API:Set("DropDown", AltoholicTabSearch_SelectSlot)
		UI.API:Set("DropDown", AltoholicTabSearch_SelectLocation)
		AltoholicTabSearch_SelectRarity:SetSize(125, 32)
		AltoholicTabSearch_SelectSlot:SetSize(125, 32)
		AltoholicTabSearch_SelectLocation:SetSize(175, 32)
		UI.API:Set("EditBox", _G["AltoholicTabSearch_MinLevel"])
		UI.API:Set("EditBox", _G["AltoholicTabSearch_MaxLevel"])

		for i = 1, 15 do
			UI.API:Set("Button", _G["AltoholicTabSearchMenuItem"..i])
		end

		for i = 1, 8 do
			UI.API:Set("Button", _G["AltoholicTabSearch_Sort"..i])
		end
	end
end

MOD:SaveAddonStyle("Altoholic", StyleAltoholic, false, true)
