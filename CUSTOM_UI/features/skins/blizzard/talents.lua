--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= _G.unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local type 		= _G.type;
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
local SpecButtonList = {
	"PlayerTalentFrameSpecializationLearnButton",
	"PlayerTalentFrameTalentsLearnButton",
	"PlayerTalentFramePetSpecializationLearnButton"
};

local function Tab_OnEnter(this)
	this.backdrop:SetPanelColor("highlight")
	this.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local function Tab_OnLeave(this)
	this.backdrop:SetPanelColor("dark")
	this.backdrop:SetBackdropBorderColor(0,0,0,1)
end

local function ChangeTabHelper(this)
	this:RemoveTextures()
	local nTex = this:GetNormalTexture()
	if(nTex) then
		nTex:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
		nTex:InsetPoints()
	end

	this.pushed = true;

	this.backdrop = CreateFrame("Frame", nil, this)
	this.backdrop:WrapPoints(this,1,1)
	this.backdrop:SetFrameLevel(0)
	this.backdrop:SetBackdrop(UI.Media.backdrop.glow);
    this.backdrop:SetBackdropColor(0,0,0,1)
	this.backdrop:SetBackdropBorderColor(0,0,0,1)
	this:SetScript("OnEnter", Tab_OnEnter)
	this:SetScript("OnLeave", Tab_OnLeave)
end

local function StyleGlyphHolder(holder, offset)
    if((not holder) or holder.styled) then return end 
    offset = offset or 1;

    holder:RemoveTextures()

    local outer = holder:CreateTexture(nil, "OVERLAY")
    outer:WrapPoints(holder, offset, offset)
    outer:SetTexture(UI.Media.button.round)
    outer:SetGradient(unpack(UI.Media.gradient.class))

    local hover = holder:CreateTexture(nil, "HIGHLIGHT")
    hover:WrapPoints(holder, offset, offset)
    hover:SetTexture(UI.Media.button.round)
    hover:SetGradient(unpack(UI.Media.gradient.yellow))
    holder.hover = hover

    if holder.SetDisabledTexture then 
        local disabled = holder:CreateTexture(nil, "BORDER")
        disabled:WrapPoints(holder, offset, offset)
        disabled:SetTexture(UI.Media.button.round)
        disabled:SetGradient(unpack(UI.Media.gradient.default))
        holder:SetDisabledTexture(disabled)
    end 

    local cd = holder:GetName() and _G[holder:GetName().."Cooldown"]
    if cd then 
        cd:ClearAllPoints()
        cd:InsetPoints(holder)
    end

    holder.styled = true
end 
--[[ 
########################################################## 
TALENTFRAME MODR
##########################################################
]]--
local function TalentFrameStyle()
	if UI.db.Skins.blizzard.enable ~= true or UI.db.Skins.blizzard.talent ~= true then return end

	UI.API:Set("Window", PlayerTalentFrame)

	PlayerTalentFrameInset:RemoveTextures()
	PlayerTalentFrameTalents:RemoveTextures()
	PlayerTalentFrameTalentsClearInfoFrame:RemoveTextures()

	PlayerTalentFrame.Panel:SetPoint("BOTTOMRIGHT", PlayerTalentFrame, "BOTTOMRIGHT", 0, -5)
	PlayerTalentFrameSpecializationTutorialButton:Die()
	PlayerTalentFrameTalentsTutorialButton:Die()
	PlayerTalentFramePetSpecializationTutorialButton:Die()
	UI.API:Set("CloseButton", PlayerTalentFrameCloseButton)
	PlayerTalentFrameActivateButton:SetStyle("Button")

	for _,name in pairs(SpecButtonList)do
		local button = _G[name];
		if(button) then
			button:RemoveTextures()
			button:SetStyle("Button")
			local initialAnchor, anchorParent, relativeAnchor, xPosition, yPosition = button:GetPoint()
			button:SetPoint(initialAnchor, anchorParent, relativeAnchor, xPosition, -28)
		end
	end 

	PlayerTalentFrameTalents:SetStyle("!_Frame", "Inset")
	PlayerTalentFrameTalentsClearInfoFrame.icon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
	PlayerTalentFrameTalentsClearInfoFrame:SetWidth(PlayerTalentFrameTalentsClearInfoFrame:GetWidth()-2)
	PlayerTalentFrameTalentsClearInfoFrame:SetHeight(PlayerTalentFrameTalentsClearInfoFrame:GetHeight()-2)
	PlayerTalentFrameTalentsClearInfoFrame.icon:SetSize(PlayerTalentFrameTalentsClearInfoFrame:GetSize())
	PlayerTalentFrameTalentsClearInfoFrame:SetPoint('TOPLEFT', PlayerTalentFrameTalents, 'BOTTOMLEFT', 8, -8)

	for i = 1, 4 do
		UI.API:Set("Tab", _G["PlayerTalentFrameTab"..i])
		if i == 1 then 
			local d, e, k, g = _G["PlayerTalentFrameTab"..i]:GetPoint()
			_G["PlayerTalentFrameTab"..i]:SetPoint(d, e, k, g, -4)
		end 
	end 

	hooksecurefunc("PlayerTalentFrame_UpdateTabs", function()
		for i = 1, 4 do 
			local d, e, k, g = _G["PlayerTalentFrameTab"..i]:GetPoint()
			_G["PlayerTalentFrameTab"..i]:SetPoint(d, e, k, g, -4)
		end 
	end)

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)

	for i = 1, 2 do 
		local v = _G["PlayerSpecTab"..i]
		_G["PlayerSpecTab"..i.."Background"]:Die()
		ChangeTabHelper(v)
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecs", function()
		local d, x, f, g, h = PlayerSpecTab1:GetPoint()
		PlayerSpecTab1:SetPoint(d, x, f, -1, h)
	end)

	local maxTiers = MAX_TALENT_TIERS

	for i = 1, maxTiers do
		local gName = ("PlayerTalentFrameTalentsTalentRow%d"):format(i)
		local rowFrame = _G[gName]
		if(rowFrame) then
			local bgFrame = _G[("%sBg"):format(gName)]
			if(bgFrame) then bgFrame:Hide() end

			rowFrame:DisableDrawLayer("BORDER")
			rowFrame:RemoveTextures()
			rowFrame.TopLine:SetPoint("TOP", 0, 4)
			rowFrame.BottomLine:SetPoint("BOTTOM", 0, -4)

			for z = 1, NUM_TALENT_COLUMNS do 
				local talentItem = _G[("%sTalent%d"):format(gName, z)]
				if(talentItem) then
					UI.API:Set("ItemButton", talentItem)
				end
			end
		end
	end

	hooksecurefunc("TalentFrame_Update", function()
		for i = 1, maxTiers do
			local gName = ("PlayerTalentFrameTalentsTalentRow%d"):format(i)

			for z = 1, NUM_TALENT_COLUMNS do
				local talentItem = _G[("%sTalent%d"):format(gName, z)]
				if(talentItem) then
					if talentItem.knownSelection:IsShown() then
						talentItem:SetBackdropBorderColor(0, 1, 0)
					else
			 			talentItem:SetBackdropBorderColor(0, 0, 0)
					end 
					if talentItem.learnSelection:IsShown() then
			 			talentItem:SetBackdropBorderColor(1, 1, 0)
					end 
				end
			end 
		end 
	end)

	for b = 1, 5 do
		 select(b, PlayerTalentFrameSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
	end

	local C = _G["PlayerTalentFrameSpecializationSpellScrollFrameScrollChild"]
	C.ring:Hide()
	C:SetStyle("!_Frame", "Inset")
	C.Panel:WrapPoints(C.specIcon)
	C.specIcon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))

	local D = _G["PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild"]
	D.ring:Hide()
	D:SetStyle("!_Frame", "Inset")
	D.Panel:WrapPoints(D.specIcon)
	D.specIcon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))

	hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, arg1)
		local arg2 = GetSpecialization(nil, self.isPet, PlayerSpecTab2:GetChecked() and 2 or 1)
		local spec = arg1 or arg2 or 1;
		local arg3, _, _, icon = GetSpecializationInfo(spec, nil, self.isPet)
		local scrollChild = self.spellsScroll.child;
		scrollChild.specIcon:SetTexture(icon)

		local cache;
		if self.isPet then
			cache = { GetSpecializationSpells(spec, nil, self.isPet) }
		else
			 cache = SPEC_SPELLS_DISPLAY[arg3]
		end

		local indexOffset = 1;
		for i = 1, #cache, 2 do 
			local button = scrollChild["abilityButton" .. indexOffset]
			if(button) then
				local _, icon = GetSpellTexture(cache[i])
				button.icon:SetTexture(icon)
				if not button.restyled then
					button.restyled = true;
					button:SetSize(30, 30)
					button.ring:Hide()
					button:SetStyle("!_Frame", "Inset")
					button.icon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
					button.icon:InsetPoints()
				end 
			end
			indexOffset = indexOffset + 1 
		end

		for i = 1, GetNumSpecializations(nil, self.isPet)do 
			local specButton = self["specButton"..i]
			if(specButton) then
				specButton.SelectedTexture:InsetPoints(specButton.Panel)
				if specButton.selected then
					 specButton.SelectedTexture:Show()
				else
					 specButton.SelectedTexture:Hide()
				end
			end
		end 
	end)

	for b = 1, GetNumSpecializations(false, nil)do 
		local button = PlayerTalentFrameSpecialization["specButton"..b]
		if(button) then
			local _, _, _, icon = GetSpecializationInfo(b, false, nil)
			button.ring:Hide()
			button.specIcon:SetTexture(icon)
			button.specIcon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
			button.specIcon:SetSize(50, 50)
			button.specIcon:SetPoint("LEFT", button, "LEFT", 15, 0)
			button.SelectedTexture = button:CreateTexture(nil, 'ARTWORK')
			button.SelectedTexture:SetTexture(1, 1, 0, 0.1)
		end
	end

	local btnList = {
		"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"
	}

	for _, gName in pairs(btnList)do
		for b = 1, 4 do 
			local button = _G[gName..b]
			if(button) then
				if(_G[gName..b.."Glow"]) then _G[gName..b.."Glow"]:Die() end
				local bTex = button:CreateTexture(nil, 'ARTWORK')
				bTex:SetTexture(1, 1, 1, 0.1)
				button:SetHighlightTexture(bTex)
				button.bg:SetAlpha(0)
				button.learnedTex:SetAlpha(0)
				button.selectedTex:SetAlpha(0)
				button:SetStyle("!_Frame", "Button")
				button:GetHighlightTexture():InsetPoints(button.Panel)
			end
		end 
	end

	if UI.class == "HUNTER" then
		for b = 1, 6 do
			 select(b, PlayerTalentFramePetSpecialization:GetRegions()):Hide()
		end 
		for b = 1, PlayerTalentFramePetSpecialization:GetNumChildren()do 
			local O = select(b, PlayerTalentFramePetSpecialization:GetChildren())
			if O and not O:GetName() then
				 O:DisableDrawLayer("OVERLAY")
			end 
		end 
		for b = 1, 5 do
			 select(b, PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
		end 
		for b = 1, GetNumSpecializations(false, true)do 
			local A = PlayerTalentFramePetSpecialization["specButton"..b]
			local p, p, p, icon = GetSpecializationInfo(b, false, true)
			A.ring:Hide()
			A.specIcon:SetTexture(icon)
			A.specIcon:SetTexCoord(unpack(_G.CUSTOM_UI_ICON_COORDS))
			A.specIcon:SetSize(50, 50)
			A.specIcon:SetPoint("LEFT", A, "LEFT", 15, 0)
			A.SelectedTexture = A:CreateTexture(nil, 'ARTWORK')
			A.SelectedTexture:SetTexture(1, 1, 0, 0.1)
		end 
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)
	end

	PlayerTalentFrameSpecialization:DisableDrawLayer('ARTWORK')
	PlayerTalentFrameSpecialization:DisableDrawLayer('BORDER')

	for b = 1, PlayerTalentFrameSpecialization:GetNumChildren()do 
		local O = select(b, PlayerTalentFrameSpecialization:GetChildren())
		if O and not O:GetName() then
			 O:DisableDrawLayer("OVERLAY")
		end 
	end 
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TalentUI", TalentFrameStyle)

local function GlyphStyle()
	assert(GlyphFrame, "GlyphFrame Not Loaded")

	GlyphFrame:RemoveTextures()
	GlyphFrame:SetStyle("!_Frame", "Premium")

	if(GlyphFrameSideInset) then GlyphFrameSideInset:RemoveTextures() end
	if(GlyphFrameHeader1) then GlyphFrameHeader1:RemoveTextures() end
	if(GlyphFrameHeader2) then GlyphFrameHeader2:RemoveTextures() end
	if(GlyphFrameScrollFrame) then GlyphFrameScrollFrame:SetStyle("Frame", "Inset", false, 3, 2, 2) end
	if(GlyphFrameSearchBox) then GlyphFrameSearchBox:SetStyle("Editbox") end
	
	if(GlyphFrameClearInfoFrame and GlyphFrameClearInfoFrame.icon) then
		GlyphFrameClearInfoFrame:RemoveTextures()

		local w,h = GlyphFrameClearInfoFrame:GetSize()
		GlyphFrameClearInfoFrame:SetSize((w - 2),(h - 2))
		GlyphFrameClearInfoFrame:SetPoint("TOPLEFT", GlyphFrame, "BOTTOMLEFT", 6, -10)
		GlyphFrameClearInfoFrame.icon:SetSize((w - 2),(h - 2))
		GlyphFrameClearInfoFrame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	UI.API:Set("DropDown", GlyphFrameFilterDropDown, 212)
	UI.API:Set("ScrollBar", GlyphFrameScrollFrameScrollBar, 5)

	for i = 1, 10 do 
		local button = _G["GlyphFrameScrollFrameButton"..i]
		if(button) then
			UI.API:Set("ItemButton", button)
			local icon = _G["GlyphFrameScrollFrameButton"..i.."Icon"]
			if(icon) then
				icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			end
		end
	end 

	for i = 1, 6 do 
		local glyphHolder = _G["GlyphFrameGlyph"..i]
		if glyphHolder then 
			if(i % 2 == 0) then
				StyleGlyphHolder(glyphHolder, 4)
			else
				StyleGlyphHolder(glyphHolder, 1)
			end
		end 
	end 
end 

MOD:SaveBlizzardStyle("Blizzard_GlyphUI", GlyphStyle)