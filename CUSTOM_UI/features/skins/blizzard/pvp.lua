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
PVP MODR
##########################################################
]]--
local _hook_PVPReadyDialogDisplay = function(self, _, _, _, queueType, _, queueRole)
	PVPReadyDialogRoleIconTexture:SetTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	if(queueType == "ARENA") then
		self:SetHeight(100)
	end
end

local function PVPFrameStyle()
	if (UI.db.Skins and (UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.pvp ~= true)) then
		return
	end

	local HonorFrame = _G.HonorFrame;
	local ConquestFrame = _G.ConquestFrame;
	local PVPUIFrame = _G.PVPUIFrame;
	local WarGamesFrame = _G.WarGamesFrame;
	local PVPReadyDialog = _G.PVPReadyDialog;

	UI.API:Set("Window", PVPUIFrame, true)

	UI.API:Set("CloseButton", PVPUIFrameCloseButton)

	for g = 1, 2 do
		UI.API:Set("Tab", _G["PVPUIFrameTab"..g])
	end

	for i = 1, 4 do
		local btn = _G["PVPQueueFrameCategoryButton"..i]
		if(btn) then
			btn.Background:Die()
			btn.Ring:Die()
			btn:SetStyle("Button")
			btn.Icon:SetSize(45, 45)
			btn.Icon:SetTexCoord(.15, .85, .15, .85)
			btn.Icon:SetDrawLayer("OVERLAY", nil, 7)
			btn.Panel:WrapPoints(btn.Icon)
		end
	end

	UI.API:Set("DropDown", HonorFrameTypeDropDown)
	HonorFrame.Inset:RemoveTextures()
	HonorFrame.Inset:SetStyle("!_Frame", "Inset")
	UI.API:Set("ScrollBar", HonorFrameSpecificFrameScrollBar)
	HonorFrameSoloQueueButton:RemoveTextures()
	HonorFrameGroupQueueButton:RemoveTextures()
	HonorFrameSoloQueueButton:SetStyle("Button")
	HonorFrameGroupQueueButton:SetStyle("Button")
	HonorFrame.BonusFrame:RemoveTextures()
	HonorFrame.BonusFrame.ShadowOverlay:RemoveTextures()
	HonorFrame.BonusFrame.RandomBGButton:RemoveTextures()
	HonorFrame.BonusFrame.RandomBGButton:SetStyle("!_Frame", "Button")
	HonorFrame.BonusFrame.RandomBGButton:SetStyle("Button")
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:InsetPoints()
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetTexture(1, 1, 0, 0.1)

	HonorFrame.BonusFrame.DiceButton:DisableDrawLayer("ARTWORK")
	HonorFrame.BonusFrame.DiceButton:SetHighlightTexture("")
	HonorFrame.RoleInset:RemoveTextures()
	HonorFrame.RoleInset.DPSIcon.checkButton:SetStyle("CheckButton")
	HonorFrame.RoleInset.TankIcon.checkButton:SetStyle("CheckButton")
	HonorFrame.RoleInset.HealerIcon.checkButton:SetStyle("CheckButton")
	HonorFrame.RoleInset.TankIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.TankIcon:DisableDrawLayer("BACKGROUND")
	HonorFrame.RoleInset.TankIcon:SetNormalTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	HonorFrame.RoleInset.HealerIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.HealerIcon:DisableDrawLayer("BACKGROUND")
	HonorFrame.RoleInset.HealerIcon:SetNormalTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	HonorFrame.RoleInset.DPSIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.DPSIcon:DisableDrawLayer("BACKGROUND")
	HonorFrame.RoleInset.DPSIcon:SetNormalTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(n)
		if n.bg then
			n.bg:SetDesaturated(true)
		end
	end)

	LFGListPVEStub:RemoveTextures(true)
	LFGListPVPStub:RemoveTextures(true)

	local ConquestPointsBar = _G.ConquestPointsBar;

	ConquestFrame.Inset:RemoveTextures()
	ConquestPointsBarLeft:Die()
	ConquestPointsBarRight:Die()
	ConquestPointsBarMiddle:Die()
	ConquestPointsBarBG:Die()
	ConquestPointsBarShadow:Die()
	ConquestPointsBar.progress:SetTexture(UI.Media.statusbar.default)
	ConquestPointsBar:SetStyle("!_Frame", 'Inset')
	ConquestPointsBar.Panel:WrapPoints(ConquestPointsBar, nil, -2)
	ConquestFrame:RemoveTextures()
	ConquestFrame.ShadowOverlay:RemoveTextures()
	ConquestJoinButton:RemoveTextures()
	ConquestJoinButton:SetStyle("Button")
	ConquestFrame.RatedBG:RemoveTextures()
	ConquestFrame.RatedBG:SetStyle("!_Frame", "Inset")
	ConquestFrame.RatedBG:SetStyle("Button")
	ConquestFrame.RatedBG.SelectedTexture:InsetPoints()
	ConquestFrame.RatedBG.SelectedTexture:SetTexture(1, 1, 0, 0.1)
	WarGamesFrame:RemoveTextures()
	WarGamesFrame.RightInset:RemoveTextures()
	WarGamesFrameInfoScrollFrame:RemoveTextures()
	WarGamesFrameInfoScrollFrameScrollBar:RemoveTextures()
	WarGameStartButton:RemoveTextures()
	WarGameStartButton:SetStyle("Button")
	UI.API:Set("ScrollBar", WarGamesFrameScrollFrameScrollBar)
	UI.API:Set("ScrollBar", WarGamesFrameInfoScrollFrameScrollBar)
	WarGamesFrame.HorizontalBar:RemoveTextures()

	PVPReadyDialog:RemoveTextures()
	PVPReadyDialog:SetStyle("Frame", "Pattern")
	PVPReadyDialogEnterBattleButton:SetStyle("Button")
	PVPReadyDialogLeaveQueueButton:SetStyle("Button")
	UI.API:Set("CloseButton", PVPReadyDialogCloseButton)
	PVPReadyDialogRoleIconTexture:SetTexture("Interface\\AddOns\\CUSTOM_UI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	PVPReadyDialogRoleIconTexture:SetAlpha(0.5)

	ConquestFrame.Inset:SetStyle("!_Frame", "Inset")
	WarGamesFrameScrollFrame:SetStyle("Frame", "Inset",false,2,2,6)

	hooksecurefunc("PVPReadyDialog_Display", _hook_PVPReadyDialogDisplay)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle('Blizzard_PVPUI', PVPFrameStyle)

-- /script StaticPopupSpecial_Show(PVPReadyDialog)
