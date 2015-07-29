--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local UI = _G['CUSTOM_UI'];
local L = UI.L;
local MOD = UI.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
ARCHEOLOGYFRAME MODR
##########################################################
]]--
local function ArchaeologyStyle()
	if UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.archaeology ~= true then return end

	ArchaeologyFrame:RemoveTextures()
	ArchaeologyFrameInset:RemoveTextures()
	ArchaeologyFrame:SetStyle("Frame", "Window")
	ArchaeologyFrame.Panel:SetAllPoints()
	ArchaeologyFrame.portrait:SetAlpha(0)
	ArchaeologyFrameInset:SetStyle("Frame", "Inset")
	ArchaeologyFrameInset.Panel:SetPoint("TOPLEFT")
	ArchaeologyFrameInset.Panel:SetPoint("BOTTOMRIGHT", -3, -1)
	ArchaeologyFrameArtifactPageSolveFrameSolveButton:SetStyle("Button")
	ArchaeologyFrameArtifactPageBackButton:SetStyle("Button")
	ArchaeologyFrameRaceFilter:SetFrameLevel(ArchaeologyFrameRaceFilter:GetFrameLevel()+2)
	UI.API:Set("DropDown", ArchaeologyFrameRaceFilter, 125)
	UI.API:Set("PageButton", ArchaeologyFrameCompletedPageNextPageButton)
	UI.API:Set("PageButton", ArchaeologyFrameCompletedPagePrevPageButton)
	ArchaeologyFrameRankBar:RemoveTextures()
	ArchaeologyFrameRankBar:SetStatusBarTexture(UI.Media.statusbar.default)
	ArchaeologyFrameRankBar:SetFrameLevel(ArchaeologyFrameRankBar:GetFrameLevel()+2)
	ArchaeologyFrameRankBar:SetStyle("Frame", "Default")
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:RemoveTextures()
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarTexture(UI.Media.statusbar.default)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarColor(0.7, 0.2, 0)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel()+2)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStyle("Frame", "Default")

	for b = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
		local c = _G["ArchaeologyFrameCompletedPageArtifact"..b]
		if c then
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Border"]:Die()
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Bg"]:Die()
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"]:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"].backdrop = CreateFrame("Frame", nil, c)
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"].backdrop:SetStyle("!_Frame", "Default")
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"].backdrop:WrapPoints(_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"])
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"].backdrop:SetFrameLevel(c:GetFrameLevel()-2)
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"]:SetDrawLayer("OVERLAY")
		end
	end

	ArchaeologyFrameArtifactPageIcon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
	ArchaeologyFrameArtifactPageIcon.backdrop = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPage)
	ArchaeologyFrameArtifactPageIcon.backdrop:SetStyle("!_Frame", "Default")
	ArchaeologyFrameArtifactPageIcon.backdrop:WrapPoints(ArchaeologyFrameArtifactPageIcon)
	ArchaeologyFrameArtifactPageIcon.backdrop:SetFrameLevel(ArchaeologyFrameArtifactPage:GetFrameLevel())
	ArchaeologyFrameArtifactPageIcon:SetParent(ArchaeologyFrameArtifactPageIcon.backdrop)
	ArchaeologyFrameArtifactPageIcon:SetDrawLayer("OVERLAY")
	UI.API:Set("CloseButton", ArchaeologyFrameCloseButton)

	local progressBarHolder = CreateFrame("Frame", "CUSTOM_UI_ArcheologyProgressBar", UI.Screen)
	progressBarHolder:SetSize(240, 24)
	progressBarHolder:SetPoint("TOP", UI.Screen, "CENTER", 0, -180)
	UI:NewAnchor(progressBarHolder, "Archeology Progress Bar")

	ArcheologyDigsiteProgressBar:SetAllPoints(progressBarHolder)
	progressBarHolder:SetParent(ArcheologyDigsiteProgressBar)

	ArcheologyDigsiteProgressBar.Shadow:SetTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\ArcheologyToast")
	ArcheologyDigsiteProgressBar.BarBackground:SetTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\ArcheologyToast")
	ArcheologyDigsiteProgressBar.BarBorderAndOverlay:SetTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\ArcheologyToast")
	ArcheologyDigsiteProgressBar.Flash:SetTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\ArcheologyToast")
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\Arch-Progress-Fill")
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ArchaeologyUI", ArchaeologyStyle)
