f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
local title = "DragonFrames"
local author = "knuxyl"
local version = "1.0.0 (3/18/2023)"
local defaults = {
	dynamic = { true, true },
	target = { false, false, true, true, 4, 4 },
	source = 2,
	portrait = { 1, 1 },
	levels = { { 9, 29, 59, 255 }, { 5, 10, 15, 20 } }
}
local strings = {"Normal", "Rare", "RareElite", "Elite", "Disabled", "Hostile Only", "Friendly Only", "Both", "Original", "High Resolution", "Dragonflight"}
local textures = {
	{
		"Interface\\TargetingFrame\\UI-TargetingFrame.blp",
		"Interface\\TargetingFrame\\UI-TargetingFrame-Rare.blp",
		"Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite.blp",
		"Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp"
	},
	{
		"Interface\\AddOns\\DragonFrames\\textures\\normal.blp",
		"Interface\\AddOns\\DragonFrames\\textures\\rare.blp",
		"Interface\\AddOns\\DragonFrames\\textures\\rareelite.blp",
		"Interface\\AddOns\\DragonFrames\\textures\\elite.blp"
	},
	{
		"Interface\\AddOns\\DragonFrames\\textures\\normal.blp",
		"Interface\\AddOns\\DragonFrames\\textures\\new-rare.blp",
		"Interface\\AddOns\\DragonFrames\\textures\\new-rareelite.blp",
		"Interface\\AddOns\\DragonFrames\\textures\\new-elite.blp"
	}
}
function f:OnEvent(event, ...)
	self[event](self, event, ...)
end
function f:ADDON_LOADED(event, name)
	if name == "DragonFrames" then
		if settings == nil then
			settings = defaults
		end
		if settings.dynamic[1] then
			f:RegisterEvent("PLAYER_LEVEL_UP")
		end
		f:InitializeOptions()
		f:UnregisterEvent("ADDON_LOADED")
	end
end
function f:PLAYER_TARGET_CHANGED()
	UpdateTarget()
end
function f:PLAYER_LEVEL_UP(event, level)
	UpdatePlayer(level)
end
function f:InitializeOptions()
	self.panel = CreateFrame("Frame")
	self.panel.name = "DragonFrames"
	local logo = self.panel:CreateTexture("logo", "ARTWORK")
	logo:SetTexture("Interface\\AddOns\\DragonFrames\\textures\\logo.blp")
	logo:SetSize(80, 80)
	logo:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 8, 0)
	logo:SetTexCoord(1, 0, 0, 1)
	local logoend = self.panel:CreateTexture("logoend", "ARTWORK")
	logoend:SetTexture("Interface\\AddOns\\DragonFrames\\textures\\logo.blp")
	logoend:SetSize(80, 80)
	logoend:SetPoint("TOPRIGHT", self.panel, "TOPRIGHT", -8, 0)
	local txtTitle = self.panel:CreateFontString("gtxtVersion", "OVERLAY", "GameFontNormal");
	txtTitle:SetPoint("CENTER", self.panel, "CENTER")
	txtTitle:SetPoint("TOP", self.panel, "TOP", 0, -8)
	txtTitle:SetText(title)
	txtTitle:SetTextHeight(26)
	local txtVersion = self.panel:CreateFontString("gtxtVersion", "OVERLAY", "GameFontNormal");
	txtVersion:SetPoint("CENTER", self.panel, "CENTER")
	txtVersion:SetPoint("TOP", txtTitle, "BOTTOM", 0, -4)
	txtVersion:SetText("version "..version)
	local txtAuthor = self.panel:CreateFontString("gtxtAuthor", "OVERLAY", "GameFontNormal");
	txtAuthor:SetPoint("CENTER", self.panel, "CENTER")
	txtAuthor:SetPoint("TOP", txtVersion, "BOTTOM", 0, -4)
	txtAuthor:SetText("by "..author)
	local ddTexture = createDropdown({name = "gddTexture", parent = self.panel, items = {"Original", "High Resolution", "Dragonflight"}, defaultVal = strings[settings.source + 8],
	changeFunc = function(self)
		for i, v in ipairs(strings) do
			if self.value == v then
				settings.source = i - 8
				break
			end
		end
		UpdateTextures()
	end
	})
	local txtTexture = self.panel:CreateFontString("txtTexture", "OVERLAY", "GameFontNormal");
	UIDropDownMenu_SetWidth(ddTexture, 140)
	ddTexture:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", -16, -8)
	txtTexture:SetPoint("LEFT", ddTexture, "RIGHT", -10, 4)
	txtTexture:SetText("Texture Source")
	local cbPlayer = CreateFrame("CheckButton", "gcbPlayer", self.panel, "ChatConfigCheckButtonTemplate")
	cbPlayer:SetScript("OnClick", function(self)
		if self:GetChecked() then
			UIDropDownMenu_DisableDropDown(gddPlayer)
			settings.dynamic[1] = true
			f:RegisterEvent("PLAYER_LEVEL_UP")
		else
			UIDropDownMenu_EnableDropDown(gddPlayer)
			settings.dynamic[1] = false
			f:UnregisterEvent("PLAYER_LEVEL_UP")
		end
		UIDropDownMenu_SetText(gddPlayer, strings[settings.portrait[1]])
		UpdatePlayer()
	end)
	local ddPlayer = createDropdown({name = "gddPlayer", parent = self.panel, items = {"Normal", "Rare", "RareElite", "Elite"}, defaultVal = strings[settings.portrait[1]],
	changeFunc = function(self)
		for i, v in ipairs(strings) do
			if self.value == v then
				settings.portrait[1] = i
				break
			end
		end
		UpdateTextures()
	end
	})
	cbPlayer:SetChecked(settings.dynamic[1])
	if settings.dynamic[1] then
		UIDropDownMenu_DisableDropDown(ddPlayer)
	else
		UIDropDownMenu_EnableDropDown(ddPlayer)
	end
	local txtPlayer = self.panel:CreateFontString("gtxtPlayer", "OVERLAY", "GameFontNormal");
	local txtPlayerDynamic = self.panel:CreateFontString("gtxtPlayerDynamic", "OVERLAY", "GameFontNormal");
	
	local txtPlayerNormal = self.panel:CreateFontString("gtxtPlayerNormal", "OVERLAY", "GameFontNormal");
	local edtPlayerNormal = CreateFrame("EditBox", "gedtPlayerNormal", self.panel, "InputBoxTemplate")
	edtPlayerNormal:SetScript("OnTextChanged", function(self)
		InputValidation(self, txtPlayerNormal, 1, 1)
		UpdatePlayer()
	end)
	local txtPlayerRare = self.panel:CreateFontString("gtxtPlayerRare", "OVERLAY", "GameFontNormal");
	local edtPlayerRare = CreateFrame("EditBox", "gedtPlayerRare", self.panel, "InputBoxTemplate")
	edtPlayerRare:SetScript("OnTextChanged", function(self)
		InputValidation(self, txtPlayerRare, 1, 2)
		UpdatePlayer()
	end)
	local txtPlayerRareElite = self.panel:CreateFontString("gtxtPlayerRareElite", "OVERLAY", "GameFontNormal");
	local edtPlayerRareElite = CreateFrame("EditBox", "gedtPlayerRareElite", self.panel, "InputBoxTemplate")
	edtPlayerRareElite:SetScript("OnTextChanged", function(self)
		InputValidation(self, txtPlayerRareElite, 1, 3)
		UpdatePlayer()
	end)
	local txtPlayerElite = self.panel:CreateFontString("gtxtPlayerElite", "OVERLAY", "GameFontNormal");
	local edtPlayerElite = CreateFrame("EditBox", "gedtPlayerElite", self.panel, "InputBoxTemplate")
	edtPlayerElite:SetScript("OnTextChanged", function(self)
		InputValidation(self, txtPlayerElite, 1, 4)
		UpdatePlayer()
	end)
	UIDropDownMenu_SetWidth(ddPlayer, 140)
	cbPlayer:SetPoint("TOPLEFT", ddTexture, "BOTTOMLEFT", 16, 0)
	txtPlayerDynamic:SetPoint("LEFT", cbPlayer, "RIGHT", 0, 2)
	txtPlayerDynamic:SetText("Set dynamic player frame based on level")
	txtPlayerNormal:SetPoint("TOPLEFT", cbPlayer, "BOTTOMLEFT", 0, -4)
	txtPlayerNormal:SetText("Normal("..settings.levels[1][2]..")")
	txtPlayerRare:SetPoint("LEFT", txtPlayerNormal, "RIGHT", 12, 0)
	txtPlayerRare:SetText("Rare("..settings.levels[1][2]..")")
	txtPlayerRareElite:SetPoint("LEFT", txtPlayerRare, "RIGHT", 12, 0)
	txtPlayerRareElite:SetText("RareElite("..settings.levels[1][3]..")")	
	txtPlayerElite:SetPoint("LEFT", txtPlayerRareElite, "RIGHT", 12, 0)
	txtPlayerElite:SetText("Elite("..settings.levels[1][4]..")")	
	edtPlayerNormal:SetPoint("TOPLEFT", txtPlayerNormal, "BOTTOMLEFT", 8, -8)
	edtPlayerNormal:SetSize(40, 20)
	edtPlayerNormal:SetAutoFocus(false)
	edtPlayerNormal:SetNumeric(true)
	edtPlayerNormal:SetMaxLetters(3)
	edtPlayerRare:SetPoint("TOPLEFT", txtPlayerRare, "BOTTOMLEFT", 8, -8)
	edtPlayerRare:SetSize(40, 20)
	edtPlayerRare:SetAutoFocus(false)
	edtPlayerRare:SetNumeric(true)
	edtPlayerRare:SetMaxLetters(3)
	edtPlayerRareElite:SetPoint("TOPLEFT", txtPlayerRareElite, "BOTTOMLEFT", 8, -8)
	edtPlayerRareElite:SetSize(40, 20)
	edtPlayerRareElite:SetAutoFocus(false)
	edtPlayerRareElite:SetNumeric(true)
	edtPlayerRareElite:SetMaxLetters(3)
	edtPlayerElite:SetPoint("TOPLEFT", txtPlayerElite, "BOTTOMLEFT", 8, -8)
	edtPlayerElite:SetSize(40, 20)
	edtPlayerElite:SetAutoFocus(false)
	edtPlayerElite:SetNumeric(true)
	edtPlayerElite:SetMaxLetters(3)
	ddPlayer:SetPoint("TOPLEFT", edtPlayerNormal, "BOTTOMLEFT", -20, -8)
	txtPlayer:SetPoint("LEFT", ddPlayer, "RIGHT", -10, 4);
	txtPlayer:SetText("Player Portrait Frame")
	local cbTarget = CreateFrame("CheckButton", "gcbTarget", self.panel, "ChatConfigCheckButtonTemplate")
cbTarget:SetScript("OnClick", function(self)
		if self:GetChecked() then
			UIDropDownMenu_DisableDropDown(gddTarget)
			settings.dynamic[2] = true
		else
			UIDropDownMenu_EnableDropDown(gddTarget)
			settings.dynamic[2] = false
		end
		UpdateTarget()
		UIDropDownMenu_SetText(gddTarget, strings[settings.portrait[2]])
	end)
	local ddTarget = createDropdown({name = "gddTarget", parent = self.panel, items = {"Normal", "Rare", "RareElite", "Elite"}, defaultVal = strings[settings.portrait[2]],
	changeFunc = function(self)
		for i, v in ipairs(strings) do
			if self.value == v then
				settings.portrait[2] = i
				break
			end
		end
		UpdateTextures()
	end
	})
	cbTarget:SetChecked(settings.dynamic[2])
	if settings.dynamic[2] then
		UIDropDownMenu_DisableDropDown(ddTarget)
	else
		UIDropDownMenu_EnableDropDown(ddTarget)
	end
	local txtTarget = self.panel:CreateFontString("gtxtTarget", "OVERLAY", "GameFontNormal");
	local txtTargetDynamic = self.panel:CreateFontString("gtxtTargetDynamic", "OVERLAY", "GameFontNormal");
	local txtTargetNormal = self.panel:CreateFontString("gtxtTargetNormal", "OVERLAY", "GameFontNormal");
	local edtTargetNormal = CreateFrame("EditBox", "gedtTargetNormal", self.panel, "InputBoxTemplate")
	edtTargetNormal:SetScript("OnTextChanged", function(self)
		InputValidation(self, txtTargetNormal, 2, 1)
		UpdateTarget()
	end)
	local txtTargetRare = self.panel:CreateFontString("gtxtTargetRare", "OVERLAY", "GameFontNormal");
	local edtTargetRare = CreateFrame("EditBox", "gedtTargetRare", self.panel, "InputBoxTemplate")
	edtTargetRare:SetScript("OnTextChanged", function(self)
		InputValidation(self, txtTargetRare, 2, 2)
		UpdateTarget()
	end)
	local txtTargetRareElite = self.panel:CreateFontString("gtxtTargetRareElite", "OVERLAY", "GameFontNormal");
	local edtTargetRareElite = CreateFrame("EditBox", "gedtTargetRareElite", self.panel, "InputBoxTemplate")
	edtTargetRareElite:SetScript("OnTextChanged", function(self)
		InputValidation(self, txtTargetRareElite, 2, 3)
		UpdateTarget()
	end)
	local txtTargetElite = self.panel:CreateFontString("gtxtTargetElite", "OVERLAY", "GameFontNormal");
	local edtTargetElite = CreateFrame("EditBox", "gedtTargetElite", self.panel, "InputBoxTemplate")
	edtTargetElite:SetScript("OnTextChanged", function(self)
		InputValidation(self, txtTargetElite, 2, 4)
		UpdateTarget()
	end)
	UIDropDownMenu_SetWidth(ddTarget, 140)
	cbTarget:SetPoint("TOPLEFT", ddPlayer, "BOTTOMLEFT", 16, 0)
	txtTargetDynamic:SetPoint("LEFT", cbTarget, "RIGHT", 0, 2)
	txtTargetDynamic:SetText("Set dynamic target frame based on levels above the player")
	txtTargetNormal:SetPoint("TOPLEFT", cbTarget, "BOTTOMLEFT", 0, -4)
	txtTargetNormal:SetText("Normal("..settings.levels[1][2]..")")
	txtTargetRare:SetPoint("LEFT", txtTargetNormal, "RIGHT", 12, 0)
	txtTargetRare:SetText("Rare("..settings.levels[1][2]..")")
	txtTargetRareElite:SetPoint("LEFT", txtTargetRare, "RIGHT", 12, 0)
	txtTargetRareElite:SetText("RareElite("..settings.levels[1][3]..")")	
	txtTargetElite:SetPoint("LEFT", txtTargetRareElite, "RIGHT", 12, 0)
	txtTargetElite:SetText("Elite("..settings.levels[1][4]..")")	
	edtTargetNormal:SetPoint("TOPLEFT", txtTargetNormal, "BOTTOMLEFT", 8, -8)
	edtTargetNormal:SetSize(40, 20)
	edtTargetNormal:SetAutoFocus(false)
	edtTargetNormal:SetNumeric(true)
	edtTargetNormal:SetMaxLetters(3)
	edtTargetRare:SetPoint("TOPLEFT", txtTargetRare, "BOTTOMLEFT", 8, -8)
	edtTargetRare:SetSize(40, 20)
	edtTargetRare:SetAutoFocus(false)
	edtTargetRare:SetNumeric(true)
	edtTargetRare:SetMaxLetters(3)
	edtTargetRareElite:SetPoint("TOPLEFT", txtTargetRareElite, "BOTTOMLEFT", 8, -8)
	edtTargetRareElite:SetSize(40, 20)
	edtTargetRareElite:SetAutoFocus(false)
	edtTargetRareElite:SetNumeric(true)
	edtTargetRareElite:SetMaxLetters(3)
	edtTargetElite:SetPoint("TOPLEFT", txtTargetElite, "BOTTOMLEFT", 8, -8)
	edtTargetElite:SetSize(40, 20)
	edtTargetElite:SetAutoFocus(false)
	edtTargetElite:SetNumeric(true)
	edtTargetElite:SetMaxLetters(3)
	ddTarget:SetPoint("TOPLEFT", edtTargetNormal, "BOTTOMLEFT", -24, -8)
	txtTarget:SetPoint("LEFT", ddTarget, "RIGHT", -10, 4);
	txtTarget:SetText("Target Portrait Frame")
	local ddTargetNPC = createDropdown({name = "gddTargetNPC", parent = self.panel, items = {"Disabled", "Hostile Only", "Friendly Only", "Both"}, defaultVal = strings[settings.target[5] + 4],
	changeFunc = function(self)
		UpdateTargetSelect(self.value, 0, 0)
		UpdateTarget()
	end
	})
	local txtTargetNPC = self.panel:CreateFontString("gtxtTargetNPC", "OVERLAY", "GameFontNormal");
	UIDropDownMenu_SetWidth(ddTargetNPC, 140)
	ddTargetNPC:SetPoint("TOPLEFT", ddTarget, "BOTTOMLEFT", 0, 0)
	txtTargetNPC:SetPoint("LEFT", ddTargetNPC, "RIGHT", -10, 4);
	txtTargetNPC:SetText("NPC Target")
	local ddTargetPlayer = createDropdown({name = "gddTargetPlayer", parent = self.panel, items = {"Disabled", "Hostile Only", "Friendly Only", "Both"}, defaultVal = strings[settings.target[6] + 4],
	changeFunc = function(self)
		UpdateTargetSelect(self.value, 1, 2)
		UpdateTarget()
	end
	})
	local txtTargetPlayer = self.panel:CreateFontString("gtxtTargetPlayer", "OVERLAY", "GameFontNormal");
	UIDropDownMenu_SetWidth(ddTargetPlayer, 140)
	ddTargetPlayer:SetPoint("TOPLEFT", ddTargetNPC, "BOTTOMLEFT", 0, 0)
	txtTargetPlayer:SetPoint("LEFT", ddTargetPlayer, "RIGHT", -10, 4);
	txtTargetPlayer:SetText("Player Target")
	UpdateFields()
	UpdatePlayer()
	UpdateTarget()
	InterfaceOptions_AddCategory(self.panel)
end
f:SetScript("OnEvent", f.OnEvent)
SLASH_DragonFrames1 = "/dragonframes"
SlashCmdList["DragonFrames"] = function(value)
	if value == "a" then--------------------------------------------------------------------
		PlayerFrameTexture:SetTexture("Interface\\AddOns\\DragonFrames\\textures\\new-elite.blp")
	elseif value == "b" then
		settings = defaults
	elseif value == "c" then
		StaticFrame()
	elseif value == "d" then
		DynamicFrame()
	else
		InterfaceOptionsFrame_OpenToCategory(f.panel)
	end
end
function InputValidation(input, text, x, y)
	local n = input:GetText()
	if n ~= "" then
		n = tonumber(n)
		if n > 255 then
			n = 255
		end
		settings.levels[x][y] = n
		text:SetText(strings[y].."("..settings.levels[x][y]..")")
	end
end
function UpdateTextures()
	UpdatePlayer()
	UpdateTarget()
end
function UpdateFields()
	gtxtPlayerNormal:SetText("Normal("..settings.levels[1][1]..")")
	gtxtPlayerRare:SetText("Rare("..settings.levels[1][2]..")")
	gtxtPlayerRareElite:SetText("RareElite("..settings.levels[1][3]..")")
	gtxtPlayerElite:SetText("Elite("..settings.levels[1][4]..")")
	gtxtTargetNormal:SetText("Normal("..settings.levels[2][1]..")")
	gtxtTargetRare:SetText("Rare("..settings.levels[2][2]..")")
	gtxtTargetRareElite:SetText("RareElite("..settings.levels[2][3]..")")
	gtxtTargetElite:SetText("Elite("..settings.levels[2][4]..")")
end
function UpdateTargetSelect(dropdown, offset, selection)
	local index = 5 + offset
	local enemy = 1 + selection
	local friend = 2 + selection
	for i, v in ipairs(strings) do
		if dropdown == v then
			settings.target[index] = i - 4
			break
		end
		settings.target[index] = i - 4
	end
	local lookup = {
		{ false, false },
		{ true, false },
		{ false, true },
		{ true, true }
	}
	settings.target[enemy] = lookup[settings.target[index]][1]
	settings.target[friend] = lookup[settings.target[index]][2]
end
function UpdateTarget()
	if UnitExists("target") then
		level = UnitLevel("target")
		playerlevel = UnitLevel("player")
		settings.target[1] = settings.target[5] == 2 or settings.target[5] == 4
		settings.target[2] = settings.target[5] == 3 or settings.target[5] == 4
		settings.target[3] = settings.target[6] == 2 or settings.target[6] == 4
		settings.target[4] = settings.target[6] == 3 or settings.target[6] == 3
		npc_enemy = (not UnitIsPlayer("target") and UnitIsEnemy("player", "target") and settings.target[1])
		npc_friend = (not UnitIsPlayer("target") and not UnitIsEnemy("player", "target") and settings.target[2])
		player_enemy = (UnitIsPlayer("target") and UnitIsEnemy("player", "target") and settings.target[3])
		player_friend = (UnitIsPlayer("target") and not UnitIsEnemy("player", "target") and settings.target[4])
		if npc_enemy or npc_friend or player_enemy or player_friend then
			if settings.dynamic[2] then
				if level < 1 then
					settings.portrait[2] = 4
				else
					for i, v in ipairs(settings.levels[2]) do
						if i <= 3 then
							if level >= playerlevel + v and level < playerlevel + settings.levels[2][i + 1] then
								settings.portrait[2] = i
								break
							end
						else
							if level >= playerlevel + v then
								settings.portrait[2] = 4
								break
							end
						end
						settings.portrait[2] = 1
					end
				end
			end
			TargetFrame.borderTexture:SetTexture(textures[settings.source][settings.portrait[2]])
		end
	end
end
function UpdatePlayer(level)
	if settings.dynamic[1] then
		if level == nil then
			level = UnitLevel("player")
		end
		for i, v in ipairs(settings.levels[1]) do
			if level < v then
				settings.portrait[1] = i
				break
			end
			settings.portrait[1] = 4
		end
	end
	PlayerFrameTexture:SetTexture(textures[settings.source][settings.portrait[1]])
end
--Code below found on internet, cannot remember the source. Could've rewrote it, but wow's ui api is garbage / thanks object orientation
function createDropdown(opts)
	local dropdown_name = opts['name']
	local menu_items = opts['items'] or {}
	local title_text = opts['title'] or ''
	local dropdown_width = 0
	local default_val = opts['defaultVal'] or ''
	local change_func = opts['changeFunc'] or function (dropdown_val) end
	local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
	local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
	dd_title:SetPoint("TOPLEFT", 20, 10)
	for _, item in pairs(menu_items) do
		dd_title:SetText(item)
		local text_width = dd_title:GetStringWidth() + 20
		if text_width > dropdown_width then
			dropdown_width = text_width
		end
	end
	UIDropDownMenu_SetWidth(dropdown, dropdown_width)
	UIDropDownMenu_SetText(dropdown, default_val)
	dd_title:SetText(title_text)
	UIDropDownMenu_Initialize(dropdown, function(self, level, _)
	local info = UIDropDownMenu_CreateInfo()
	for key, val in pairs(menu_items) do
		info.text = val;
		info.checked = false
		info.menuList= key
		info.hasArrow = false
		info.func = function(b)
			UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
			UIDropDownMenu_SetText(dropdown, b.value)
			change_func(b)
		end
		UIDropDownMenu_AddButton(info)
		end
	end)
	return dropdown
end
