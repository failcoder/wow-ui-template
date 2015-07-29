--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
--[[ ADDON ]]--
local UI = _G['CUSTOM_UI'];
local L = UI.L;
local MOD = UI.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local CalendarButtons = {
	"CalendarViewEventAcceptButton",
	"CalendarViewEventTentativeButton",
	"CalendarViewEventRemoveButton",
	"CalendarViewEventDeclineButton"
};
--[[ 
########################################################## 
CALENDAR MODR
##########################################################
]]--
local function CalendarStyle()
	if UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.calendar ~= true then
		 return 
	end

	UI.API:Set("Window", CalendarFrame)

	UI.API:Set("CloseButton", CalendarCloseButton)
	CalendarCloseButton:SetPoint("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -4)
	UI.API:Set("PageButton", CalendarPrevMonthButton)
	UI.API:Set("PageButton", CalendarNextMonthButton)

	do 
		local cfframe = _G["CalendarFilterFrame"];
		
		if(cfframe) then
			cfframe:RemoveTextures()
			cfframe:SetWidth(155)
			cfframe:SetStyle("Frame", "Default")

			local cfbutton = _G["CalendarFilterButton"];
			if(cfbutton) then
				cfbutton:ClearAllPoints()
				cfbutton:SetPoint("RIGHT", cfframe, "RIGHT", -10, 3)
				UI.API:Set("PageButton", cfbutton, true)
				cfframe.Panel:SetPoint("TOPLEFT", 20, 2)
				cfframe.Panel:SetPoint("BOTTOMRIGHT", cfbutton, "BOTTOMRIGHT", 2, -2)

				local cftext = _G["CalendarFilterFrameText"]
				if(cftext) then
					cftext:ClearAllPoints()
					cftext:SetPoint("RIGHT", cfbutton, "LEFT", -2, 0)
				end
			end
		end
	end

	local l = CreateFrame("Frame", "CalendarFrameBackdrop", CalendarFrame)
	l:SetStyle("!_Frame", "Default")
	l:SetPoint("TOPLEFT", 10, -72)
	l:SetPoint("BOTTOMRIGHT", -8, 3)
	CalendarContextMenu:SetStyle("!_Frame", "Default")
	hooksecurefunc(CalendarContextMenu, "SetBackdropColor", function(f, r, g, b, a)
		if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0.5 then
			 f:SetBackdropColor(0, 0, 0, 0.5)
		end 
	end)
	hooksecurefunc(CalendarContextMenu, "SetBackdropBorderColor", function(f, r, g, b)
		if r ~= 0 or g ~= 0 or b ~= 0 then
			 f:SetBackdropBorderColor(0, 0, 0)
		end 
	end)
	for u = 1, 42 do
		 _G["CalendarDayButton"..u]:SetFrameLevel(_G["CalendarDayButton"..u]:GetFrameLevel()+1)
	end 
	CalendarCreateEventFrame:RemoveTextures()
	CalendarCreateEventFrame:SetStyle("!_Frame", "Transparent", true)
	CalendarCreateEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarCreateEventTitleFrame:RemoveTextures()
	CalendarCreateEventCreateButton:SetStyle("Button")
	CalendarCreateEventMassInviteButton:SetStyle("Button")
	CalendarCreateEventInviteButton:SetStyle("Button")
	CalendarCreateEventInviteButton:SetPoint("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	CalendarCreateEventInviteEdit:SetWidth(CalendarCreateEventInviteEdit:GetWidth()-2)
	CalendarCreateEventInviteList:RemoveTextures()
	CalendarCreateEventInviteList:SetStyle("!_Frame", "Default")
	CalendarCreateEventInviteEdit:SetStyle("Editbox")
	CalendarCreateEventTitleEdit:SetStyle("Editbox")
	UI.API:Set("DropDown", CalendarCreateEventTypeDropDown, 120)
	CalendarCreateEventDescriptionContainer:RemoveTextures()
	CalendarCreateEventDescriptionContainer:SetStyle("!_Frame", "Default")
	UI.API:Set("CloseButton", CalendarCreateEventCloseButton)
	CalendarCreateEventLockEventCheck:SetStyle("CheckButton")
	UI.API:Set("DropDown", CalendarCreateEventHourDropDown, 68)
	UI.API:Set("DropDown", CalendarCreateEventMinuteDropDown, 68)
	UI.API:Set("DropDown", CalendarCreateEventAMPMDropDown, 68)
	UI.API:Set("DropDown", CalendarCreateEventRepeatOptionDropDown, 120)
	CalendarCreateEventIcon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
	hooksecurefunc(CalendarCreateEventIcon, "SetTexCoord", function(f, v, w, x, y)
		local z, A, B, C = 0.1, 0.9, 0.1, 0.9 
		if v ~= z or w ~= A or x ~= B or y ~= C then
			 f:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
		end 
	end)
	CalendarCreateEventInviteListSection:RemoveTextures()
	CalendarClassButtonContainer:HookScript("OnShow", function()
		for u, D in ipairs(CLASS_SORT_ORDER)do 	
			local e = _G["CalendarClassButton"..u]e:RemoveTextures()
			e:SetStyle("Frame", "Default")
			local E = CLASS_ICON_TCOORDS[D]
			local F = e:GetNormalTexture()
			F:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			F:SetTexCoord(E[1]+0.015, E[2]-0.02, E[3]+0.018, E[4]-0.02)
		end 
		CalendarClassButton1:SetPoint("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 5, 0)
		CalendarClassTotalsButton:RemoveTextures()
		CalendarClassTotalsButton:SetStyle("Frame", "Default")
	end)
	CalendarTexturePickerFrame:RemoveTextures()
	CalendarTexturePickerTitleFrame:RemoveTextures()
	CalendarTexturePickerFrame:SetStyle("!_Frame", "Transparent", true)
	UI.API:Set("ScrollBar", CalendarTexturePickerScrollBar)
	CalendarTexturePickerAcceptButton:SetStyle("Button")
	CalendarTexturePickerCancelButton:SetStyle("Button")
	CalendarCreateEventInviteButton:SetStyle("Button")
	CalendarCreateEventRaidInviteButton:SetStyle("Button")
	CalendarMassInviteFrame:RemoveTextures()
	CalendarMassInviteFrame:SetStyle("!_Frame", "Transparent", true)
	CalendarMassInviteTitleFrame:RemoveTextures()
	UI.API:Set("CloseButton", CalendarMassInviteCloseButton)
	CalendarMassInviteGuildAcceptButton:SetStyle("Button")
	UI.API:Set("DropDown", CalendarMassInviteGuildRankMenu, 130)
	CalendarMassInviteGuildMinLevelEdit:SetStyle("Editbox")
	CalendarMassInviteGuildMaxLevelEdit:SetStyle("Editbox")
	CalendarViewRaidFrame:RemoveTextures()
	CalendarViewRaidFrame:SetStyle("!_Frame", "Transparent", true)
	CalendarViewRaidFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewRaidTitleFrame:RemoveTextures()
	UI.API:Set("CloseButton", CalendarViewRaidCloseButton)
	CalendarViewHolidayFrame:RemoveTextures(true)
	CalendarViewHolidayFrame:SetStyle("!_Frame", "Transparent", true)
	CalendarViewHolidayFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewHolidayTitleFrame:RemoveTextures()
	UI.API:Set("CloseButton", CalendarViewHolidayCloseButton)
	CalendarViewEventFrame:RemoveTextures()
	CalendarViewEventFrame:SetStyle("!_Frame", "Transparent", true)
	CalendarViewEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewEventTitleFrame:RemoveTextures()
	CalendarViewEventDescriptionContainer:RemoveTextures()
	CalendarViewEventDescriptionContainer:SetStyle("!_Frame", "Transparent", true)
	CalendarViewEventInviteList:RemoveTextures()
	CalendarViewEventInviteList:SetStyle("!_Frame", "Transparent", true)
	CalendarViewEventInviteListSection:RemoveTextures()
	UI.API:Set("CloseButton", CalendarViewEventCloseButton)
	UI.API:Set("ScrollBar", CalendarViewEventInviteListScrollFrameScrollBar)
	for _,btn in pairs(CalendarButtons)do
		 _G[btn]:SetStyle("Button")
	end 
	CalendarEventPickerFrame:RemoveTextures()
	CalendarEventPickerTitleFrame:RemoveTextures()
	CalendarEventPickerFrame:SetStyle("!_Frame", "Transparent", true)
	UI.API:Set("ScrollBar", CalendarEventPickerScrollBar)
	CalendarEventPickerCloseButton:SetStyle("Button")
	UI.API:Set("ScrollBar", CalendarCreateEventDescriptionScrollFrameScrollBar)
	UI.API:Set("ScrollBar", CalendarCreateEventInviteListScrollFrameScrollBar)
	UI.API:Set("ScrollBar", CalendarViewEventDescriptionScrollFrameScrollBar)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_Calendar",CalendarStyle)