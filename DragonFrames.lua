f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
local title = "DragonFrames"
local author = "knuxyl"
local version = "2.0.0 (3/20/2023)"
local command = "dragonframes"
local target_texture
local player_texture
local player_settings
local targetnpc_settings
local targetplayer_Settings
local player_p, player_rt, player_rp, player_rx, player_ry = PlayerFrame:GetPoint()
local defaults = {
	["enabled"] = true,
	["player"] = {
		["enabled" ] = true,
		["dynamic"] = false,
		["texture"] = "High Resolution",
		["frame"] = "Elite",
		["levels"] = { 
			["Normal"] = { 1, 9 },
			["Rare"] = { 10, 29 },
			["RareElite"] = { 30, 59 },
			["Elite"] = { 60, 255 }
		},
		["move"] = true
	},
	["target_npc"] = {
		["enabled"] = true,
		["target"] = {
			["Friendly"] = true,
			["Neutral"] = true,
			["Hostile"] = true
		},
		["keep"] = true,
		["dynamic"] = true,
		["based"] = "Levels above player",
		["texture"] = "High Resolution",
		["frame"] = "Rare",
		["unknown"] = {
			["enabled"] = true,
			["frame"] = "Elite"
		},
		["levels"] = { 
			["Normal"] = { 1, 3 },
			["Rare"] = { 4, 6 },
			["RareElite"] = { 7, 9 },
			["Elite"] = { 10, 255 }
		}
	},
	["target_player"] = {
		["enabled"] = true,
		["target"] = {
			["Friendly"] = true,
			["Neutral"] = true,
			["Hostile"] = true
		},
		["keep"] = true,
		["dynamic"] = true,
		["based"] = "Levels above player",
		["texture"] = "High Resolution",
		["frame"] = "Rare",
		["unknown"] = {
			["enabled"] = true,
			["frame"] = "Elite"
		},
		["levels"] = { 
			["Normal"] = { 1, 3 },
			["Rare"] = { 4, 6 },
			["RareElite"] = { 7, 9 },
			["Elite"] = { 10, 255 }
		}
	}
}
local textures = {
	["Original"] = {
		["Normal"] = "Interface\\TargetingFrame\\UI-TargetingFrame.blp",
		["Rare"] = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare.blp",
		["RareElite"] = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite.blp",
		["Elite"] = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp"
	},
	["High Resolution"] = {
		["Normal"] = "Interface\\AddOns\\DragonFrames\\textures\\highresolution\\UI-TargetingFrame.blp",
		["Rare"] = "Interface\\AddOns\\DragonFrames\\textures\\highresolution\\UI-TargetingFrame-Rare.blp",
		["RareElite"] = "Interface\\AddOns\\DragonFrames\\textures\\highresolution\\UI-TargetingFrame-Rare-Elite.blp",
		["Elite"] = "Interface\\AddOns\\DragonFrames\\textures\\highresolution\\UI-TargetingFrame-Elite.blp"
	},
	["Dragonflight"] = {
		["Normal"] = "Interface\\AddOns\\DragonFrames\\textures\\dragonflight\\UI-TargetingFrame.blp",
		["Rare"] = "Interface\\AddOns\\DragonFrames\\textures\\dragonflight\\UI-TargetingFrame-Rare.blp",
		["RareElite"] = "Interface\\AddOns\\DragonFrames\\textures\\dragonflight\\UI-TargetingFrame-Rare-Elite.blp",
		["Elite"] = "Interface\\AddOns\\DragonFrames\\textures\\dragonflight\\UI-TargetingFrame-Elite.blp"
	},
	["Original Black"] = {
		["Normal"] = "Interface\\AddOns\\DragonFrames\\textures\\black\\UI-TargetingFrame.blp",
		["Rare"] = "Interface\\AddOns\\DragonFrames\\textures\\black\\UI-TargetingFrame-Rare.blp",
		["RareElite"] = "Interface\\AddOns\\DragonFrames\\textures\\black\\UI-TargetingFrame-Rare-Elite.blp",
		["Elite"] = "Interface\\AddOns\\DragonFrames\\textures\\black\\UI-TargetingFrame-Elite.blp"
	},
	["Dragonflight Black"] = {
		["Normal"] = "Interface\\AddOns\\DragonFrames\\textures\\dfblack\\UI-TargetingFrame.blp",
		["Rare"] = "Interface\\AddOns\\DragonFrames\\textures\\dfblack\\UI-TargetingFrame-Rare.blp",
		["RareElite"] = "Interface\\AddOns\\DragonFrames\\textures\\dfblack\\UI-TargetingFrame-Rare-Elite.blp",
		["Elite"] = "Interface\\AddOns\\DragonFrames\\textures\\dfblack\\UI-TargetingFrame-Elite.blp"
	},
	["Custom"] = {
		["Normal"] = "Interface\\AddOns\\DragonFrames\\textures\\custom\\UI-TargetingFrame.tga",
		["Rare"] = "Interface\\AddOns\\DragonFrames\\textures\\custom\\UI-TargetingFrame-Rare.tga",
		["RareElite"] = "Interface\\AddOns\\DragonFrames\\textures\\custom\\UI-TargetingFrame-Rare-Elite.tga",
		["Elite"] = "Interface\\AddOns\\DragonFrames\\textures\\custom\\UI-TargetingFrame-Elite.tga"
	}
}
function f:OnEvent(event, ...)
	self[event](self, event, ...)
end
function f:ADDON_LOADED(event, name)
	if name == "DragonFrames" then
		if s == nil then
			s = defaults
		end
		player_texture = PlayerFrameTexture:GetTexture()
		f:InitializeOptions()
		f:UnregisterEvent("ADDON_LOADED")
		f:UpdatePlayer()
	end
end
function f:PLAYER_TARGET_CHANGED()
	if UnitExists("target") then
		target_texture = TargetFrame.borderTexture:GetTexture()
	else
		target_texture = nil
	end
	f:UpdateTarget()
end
function f:PLAYER_LEVEL_UP(event, l)
	f:UpdatePlayer(l)
end
function f:InitializeOptions()
	self.panel = CreateFrame("Frame")
	self.panel.name = "DragonFrames"
	local scrollFrame = CreateFrame("ScrollFrame", "gScrollFrame", self.panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 3, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)
	local scrollChild = CreateFrame("Frame")
	scrollFrame:SetScrollChild(scrollChild)
	scrollChild:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth()-18)
	scrollChild:SetHeight(1) 
	local function Button(name, parent, text, size, point, m)
		local b = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
		if text then b:SetText(text) end
		if size then b:SetSize(size[1], size[2]) end
		if point then for i, v in ipairs(point) do
			b:SetPoint(point[i][1], point[i][2], point[i][3], point[i][4], point[i][5])
		end end
		if m then b:SetScript("OnClick", m) end
		return b
	end
	local function Text(name, parent, text, size, color, point)
		local t = parent:CreateFontString(name, "OVERLAY", "GameFontNormal")
		if text then t:SetText(text) end
		if size then t:SetTextHeight(size) end
		if point then for i, v in ipairs(point) do
			t:SetPoint(point[i][1], point[i][2], point[i][3], point[i][4], point[i][5])
		end end
		if color then t:SetTextColor(color[1], color[2], color[3], color[4]) end
		return t
	end
	local function CheckBox(name, parent, default, label, tooltip, point, m)
		local c = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
		c:SetChecked(default)
		if label then local l = Text(name:sub(2, 1).."gt"..name:sub(2), c, label, nil, {1, 1, 1, 1}, {{"LEFT", c, "RIGHT", 4, 0}}) end
		if tooltip then c.tooltip = tooltip end
		if point then for i, v in ipairs(point) do
			c:SetPoint(point[i][1], point[i][2], point[i][3], point[i][4], point[i][5])
		end end
		c:SetHitRectInsets(0, 0, 0, 0)
		if m then c:SetScript("OnClick", m) end
		return c
	end
	local function EditBox(name, parent, point, m)
		local e = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
		if point then for i, v in ipairs(point) do
			e:SetPoint(point[i][1], point[i][2], point[i][3], point[i][4], point[i][5])
		end end
		if m then e:SetScript("OnTextChanged", m) end
		e:SetSize(48, 24)
		e:SetAutoFocus(false)
		e:SetNumeric(true)
		e:SetMaxLetters(3)
		return e
	end
	local function DropDown(name, parent, label, items, default, size, point, m)
		local d = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
		UIDropDownMenu_SetText(d, default)
		UIDropDownMenu_Initialize(d, function(self)
			local i = UIDropDownMenu_CreateInfo()
			for j, v in ipairs(items) do
				i.text = v
				i.checked = false
				i.menuList = key
				i.hasArrow = false
				i.func = function(b)
					UIDropDownMenu_SetSelectedValue(d, b.value)
					UIDropDownMenu_SetText(d, b.value)
					m()
				end
				UIDropDownMenu_AddButton(i)
			end
		end)
		if size then UIDropDownMenu_SetWidth(d, size) end
		if default then UIDropDownMenu_SetSelectedValue(d, default) end
		if point then for i, v in ipairs(point) do
			d:SetPoint(point[i][1], point[i][2], point[i][3], point[i][4], point[i][5])
		end end
		if label then local l = Text(name:sub(2, 1).."gt"..name:sub(2), d, label, nil, {1, 1, 1, 1}, {{"LEFT", d, "RIGHT", -12, 0}}) end
		return d
	end
	local function Levels(v, label, t, text, i)
		v = tonumber(v)
		if v and v ~= "" then
			if i == 2 and v < s[t].levels[text][1] then
				v = s[t].levels[text][1]
			elseif i == 1 and v > s[t].levels[text][2] then
				v = s[t].levels[text][2]
			end
			s[t].levels[text][i] = v
			if s[t].based == "Levels above player" then
				local p = UnitLevel("player")
				label:SetText(text.." ("..s[t].levels[text][1].."-"..s[t].levels[text][2]..")".." Levels ("..s[t].levels[text][1] + p.."-"..s[t].levels[text][2] + p..")")
			else
				label:SetText(text.." ("..s[t].levels[text][1].."-"..s[t].levels[text][2]..")")
			end
		end
	end
	local tTitle = Text("gtTitle", scrollChild, title, 24, nil, {{"TOPLEFT", scrollChild, "TOPLEFT", 8, -8}})
	local tVersion = Text("gtVersion", scrollChild, "Version: "..version, nil, {1, 1, 1, 1}, {{"TOPLEFT", gtTitle, "BOTTOMLEFT"}})
	local tAuthor = Text("gtAuthor", scrollChild, "Author: "..author, nil, {1, 1, 1, 1}, {{"TOPLEFT", gtVersion, "BOTTOMLEFT"}})
	local cAddonEnabled = CheckBox("gcAddonEnabled", scrollChild, s.enabled, "Enable Addon", "Enable Addon", {{"TOPLEFT", gtAuthor, "BOTTOMLEFT", 0, -4}}, function()
		s.enabled = gcAddonEnabled:GetChecked()
		f:UpdatePlayer()
		f:UpdateTarget()
		if not s.enabled then
			PlayerFrameTexture:SetTexture(player_texture)
			if target_texture then
				TargetFrame.borderTexture:SetTexture(target_texture)
			end
		end
	end)
	local bPlayer = CreateFrame("Button", "gbPlayer", scrollChild, "GameMenuButtonTemplate")
	gbPlayer:SetScript("OnClick", function()
		for i, v in ipairs(player_settings) do
			v:Show()
		end
		for i, v in ipairs(targetnpc_settings) do
			v:Hide()
		end
		for i, v in ipairs(targetplayer_settings) do
			v:Hide()
		end
	end)
	gbPlayer:SetSize(80, 32)
	gbPlayer:SetText("Player")
	gbPlayer:SetPoint("TOPLEFT", gcAddonEnabled, "BOTTOMLEFT", 0, 2)
	local bTargetNPC = CreateFrame("Button", "gbTargetNPC", scrollChild, "GameMenuButtonTemplate")
	gbTargetNPC:SetScript("OnClick", function()
		for i, v in ipairs(player_settings) do
			v:Hide()
		end
		for i, v in ipairs(targetnpc_settings) do
			v:Show()
		end
		for i, v in ipairs(targetplayer_settings) do
			v:Hide()
		end
	end)
	gbTargetNPC:SetSize(100, 32)
	gbTargetNPC:SetText("Target NPC")
	gbTargetNPC:SetPoint("LEFT", gbPlayer, "RIGHT")
	local bTargetPlayer = CreateFrame("Button", "gbTargetPlayer", scrollChild, "GameMenuButtonTemplate")
	gbTargetPlayer:SetScript("OnClick", function()
		for i, v in ipairs(player_settings) do
			v:Hide()
		end
		for i, v in ipairs(targetnpc_settings) do
			v:Hide()
		end
		for i, v in ipairs(targetplayer_settings) do
			v:Show()
		end
	end)
	gbTargetPlayer:SetSize(100, 32)
	gbTargetPlayer:SetText("Target Player")
	gbTargetPlayer:SetPoint("LEFT", gbTargetNPC, "RIGHT")
	local bReset = CreateFrame("Button", "gbReset", scrollChild, "GameMenuButtonTemplate")
	gbReset:SetScript("OnClick", function()
		s = defaults
		ReloadUI()
	end)
	gbReset:SetSize(60, 32)
	gbReset:SetText("Reset")
	gbReset:SetPoint("LEFT", gbTargetPlayer, "RIGHT")
	local tPlayer = Text("gtPlayer", scrollChild, "Player Settings", 18, nil, {{"TOPLEFT", gbPlayer, "BOTTOMLEFT", 0, -8}})
	local cPlayerEnabled = CheckBox("gcPlayerEnabled", scrollChild, s.player.enabled, "Enabled", "Enable portrait for player", {{"TOPLEFT", gtPlayer, "BOTTOMLEFT", 0, -8}}, function()
		s.player.enabled = gcPlayerEnabled:GetChecked()
		f:UpdatePlayer()
		if not s.player.enabled then
			PlayerFrameTexture:SetTexture(player_texture)
		end
	end)
	local cPlayerDynamic = CheckBox("gcPlayerDynamic", scrollChild, s.player.dynamic, "Dynamic", "Change portrait dynamically based on level", {{"TOPLEFT", gcPlayerEnabled, "BOTTOMLEFT"}}, function()
		s.player.dynamic = gcPlayerDynamic:GetChecked()
		f:UpdatePlayer()
		UIDropDownMenu_SetSelectedValue(gdPlayerStatic, s.player.frame)
	end)
	local cPlayerMove = CheckBox("gcPlayerMove", scrollChild, s.player.move, "Move player portrait", "Move the player portrait to the right to allow full frame to be seen", {{"TOPLEFT", gcPlayerDynamic, "BOTTOMLEFT"}}, function()
		s.player.move = gcPlayerMove:GetChecked()
		f:MovePortrait()
	end)
	local dPlayerTextures = DropDown("gdPlayerTextures", scrollChild, "Texture source", {"Original", "High Resolution", "Dragonflight", "Original Black", "Dragonflight Black", "Custom"}, s.player.texture, 140, {{"TOPLEFT", gcPlayerMove, "BOTTOMLEFT", -16, -4}}, function()
		s.player.texture = UIDropDownMenu_GetSelectedValue(gdPlayerTextures)
		f:UpdatePlayer()
	end)
	local dPlayerStatic = DropDown("gdPlayerStatic", scrollChild, "Player frame", {"Normal", "Rare", "RareElite", "Elite"}, s.player.frame, 140, {{"TOPLEFT", gdPlayerTextures, "BOTTOMLEFT", 0, 0}}, function()
		s.player.frame = UIDropDownMenu_GetSelectedValue(gdPlayerStatic)
		s.player.dynamic = false
		gcPlayerDynamic:SetChecked(false)
		f:UpdatePlayer()
	end)
	local tPlayerLevels = Text("gtPlayerLevels", scrollChild, "Dynamic Settings", 14, nil, {{"TOPLEFT", gdPlayerStatic, "BOTTOMLEFT", 16, -4}})
	local ePlayerNormal1 = EditBox("gePlayerNormal1", scrollChild, {{"TOPLEFT", gtPlayerLevels, "BOTTOMLEFT", 6, -6}}, function()
		Levels(gePlayerNormal1:GetText(), gtPlayerNormal, "player", "Normal", 1)
		f:UpdatePlayer()
	end)
	local ePlayerNormal2 = EditBox("gePlayerNormal2", scrollChild, {{"LEFT", gePlayerNormal1, "RIGHT", 8, 0}}, function()
		Levels(gePlayerNormal2:GetText(), gtPlayerNormal, "player", "Normal", 2)
		f:UpdatePlayer()
	end)
	local tPlayerNormal = Text("gtPlayerNormal", scrollChild, "Normal ("..s.player.levels["Normal"][1].."-"..s.player.levels["Normal"][2]..")", nil, {1, 1, 1, 1}, {{"LEFT", ePlayerNormal2, "RIGHT", 4, 0}})
	local ePlayerRare1 = EditBox("gePlayerRare1", scrollChild, {{"TOPLEFT", gePlayerNormal1, "BOTTOMLEFT"}}, function()
		Levels(gePlayerRare1:GetText(), gtPlayerRare, "player", "Rare", 1)
		f:UpdatePlayer()
	end)
	local ePlayerRare2 = EditBox("gePlayerRare2", scrollChild, {{"LEFT", gePlayerRare1, "RIGHT", 8, 0}}, function()
		Levels(gePlayerRare2:GetText(), gtPlayerRare, "player", "Rare", 2)
		f:UpdatePlayer()
	end)
	local tPlayerRare = Text("gtPlayerRare", scrollChild, "Rare ("..s.player.levels["Rare"][1].."-"..s.player.levels["Rare"][2]..")", nil, {1, 1, 1, 1}, {{"LEFT", ePlayerRare2, "RIGHT", 4, 0}})

	local ePlayerRareElite1 = EditBox("gePlayerRareElite1", scrollChild, {{"TOPLEFT", gePlayerRare1, "BOTTOMLEFT"}}, function()
		Levels(gePlayerRareElite1:GetText(), gtPlayerRareElite, "player", "RareElite", 1)
		f:UpdatePlayer()
	end)
	local ePlayerRareElite2 = EditBox("gePlayerRareElite2", scrollChild, {{"LEFT", gePlayerRareElite1, "RIGHT", 8, 0}}, function()
		Levels(gePlayerRareElite2:GetText(), gtPlayerRareElite, "player", "RareElite", 2)
		f:UpdatePlayer()
	end)
	local tPlayerRareElite = Text("gtPlayerRareElite", scrollChild, "RareElite ("..s.player.levels["RareElite"][1].."-"..s.player.levels["RareElite"][2]..")", nil, {1, 1, 1, 1}, {{"LEFT", ePlayerRareElite2, "RIGHT", 4, 0}})
	
	local ePlayerElite1 = EditBox("gePlayerElite1", scrollChild, {{"TOPLEFT", gePlayerRareElite1, "BOTTOMLEFT"}}, function()
		Levels(gePlayerElite1:GetText(), gtPlayerElite, "player", "Elite", 1)
		f:UpdatePlayer()
	end)
	local ePlayerElite2 = EditBox("gePlayerElite2", scrollChild, {{"LEFT", gePlayerElite1, "RIGHT", 8, 0}}, function()
		Levels(gePlayerElite2:GetText(), gtPlayerElite, "player", "Elite", 2)
		f:UpdatePlayer()
	end)
	local tPlayerElite = Text("gtPlayerElite", scrollChild, "Elite ("..s.player.levels["Elite"][1].."-"..s.player.levels["Elite"][2]..")", nil, {1, 1, 1, 1}, {{"LEFT", ePlayerElite2, "RIGHT", 4, 0}})
	local tTargetNPC = Text("gtTargetNPC", scrollChild, "Target NPC Settings", 18, nil, {{"TOPLEFT", gbPlayer, "BOTTOMLEFT", 0, -8}})
	local cTargetNPCEnabled = CheckBox("gcTargetNPCEnabled", scrollChild, s.target_npc.enabled, "Enabled", "Enable portrait for target npc", {{"TOPLEFT", gtTargetNPC, "BOTTOMLEFT", 0, -8}}, function()
		s.target_npc.enabled = gcTargetNPCEnabled:GetChecked()
		f:UpdateTarget()
	end)
	local cTargetNPCDynamic = CheckBox("gcTargetNPCDynamic", scrollChild, s.target_npc.dynamic, "Dynamic", "Change portrait dynamically based on level", {{"TOPLEFT", gcTargetNPCEnabled, "BOTTOMLEFT"}}, function()
		s.target_npc.dynamic = gcTargetNPCDynamic:GetChecked()
		f:UpdateTarget()
		UIDropDownMenu_SetSelectedValue(gdTargetNPCStatic, s.target_npc.frame)
	end)
	local cTargetNPCKeep = CheckBox("gcTargetNPCKeep", scrollChild, s.target_npc.keep, "Keep current dragons", "If a target already has a dragon frame, keep it but change texture source", {{"TOPLEFT", gcTargetNPCDynamic, "BOTTOMLEFT"}}, function()
		s.target_npc.keep = gcTargetNPCKeep:GetChecked()
		f:UpdateTarget()
	end)
	local cTargetNPCFriendly = CheckBox("gcTargetNPCFriendly", scrollChild, s.target_npc.target["Friendly"], "Friendly", "Change portrait for friendly targets", {{"TOPLEFT", gcTargetNPCKeep, "BOTTOMLEFT"}}, function()
		s.target_npc.target["Friendly"] = gcTargetNPCFriendly:GetChecked()
		f:UpdateTarget()
	end)
	local cTargetNPCNeutral = CheckBox("gcTargetNPCNeutral", scrollChild, s.target_npc.target["Neutral"], "Neutral", "Change portrait for neutral targets", {{"LEFT", gtcTargetNPCFriendly, "RIGHT", 8, 0}}, function()
		s.target_npc.target["Neutral"] = gcTargetNPCNeutral:GetChecked()
		f:UpdateTarget()
	end)
	local cTargetNPCHostile = CheckBox("gcTargetNPCHostile", scrollChild, s.target_npc.target["Hostile"], "Hostile", "Change portrait for hostile targets", {{"LEFT", gtcTargetNPCNeutral, "RIGHT", 8, 0}}, function()
		s.target_npc.target["Hostile"] = gcTargetNPCHostile:GetChecked()
		f:UpdateTarget()
	end)	
	local cTargetNPCUnknown = CheckBox("gcTargetNPCUnknown", scrollChild, s.target_npc.unknown.enabled, "Unknown Level", "Change portrait for unknown level targets (another match must be enabled)", {{"LEFT", gtcTargetNPCHostile, "RIGHT", 8, 0}}, function()
		s.target_npc.unknown.enabled = gcTargetNPCUnknown:GetChecked()
		f:UpdateTarget()
	end)
	local dTargetNPCTextures = DropDown("gdTargetNPCTextures", scrollChild, "Texture source", {"Original", "High Resolution", "Dragonflight", "Original Black", "Dragonflight Black", "Custom"}, s.target_npc.texture, 140, {{"TOPLEFT", gcTargetNPCFriendly, "BOTTOMLEFT", -16, -4}}, function()
		s.target_npc.texture = UIDropDownMenu_GetSelectedValue(gdTargetNPCTextures)
		f:UpdateTarget()
	end)
	local dTargetNPCStatic = DropDown("gdTargetNPCStatic", scrollChild, "Portrait frame", {"Normal", "Rare", "RareElite", "Elite"}, s.target_npc.frame, 140, {{"TOPLEFT", gdTargetNPCTextures, "BOTTOMLEFT", 0, 0}}, function()
		s.target_npc.frame = UIDropDownMenu_GetSelectedValue(gdTargetNPCStatic)
		s.target_npc.dynamic = false
		gcTargetNPCDynamic:SetChecked(false)
		f:UpdateTarget()
	end)
	local dTargetNPCUnknown = DropDown("gdTargetNPCUnknown", scrollChild, "Unknown level portrait frame", {"Normal", "Rare", "RareElite", "Elite"}, s.target_npc.unknown.frame, 140, {{"TOPLEFT", gdTargetNPCStatic, "BOTTOMLEFT", 0, 0}}, function()
		s.target_npc.unknown.frame = UIDropDownMenu_GetSelectedValue(gdTargetNPCUnknown)
		f:UpdateTarget()
	end)
	local tTargetNPCLevels = Text("gtTargetNPCLevels", scrollChild, "Dynamic Settings", 14, nil, {{"TOPLEFT", gdTargetNPCUnknown, "BOTTOMLEFT", 16, -4}})
	local dTargetNPCDynamic = DropDown("gdTargetNPCDynamic", scrollChild, "Portrait based on", {"Levels above player", "Target level"}, "Levels above player", 140, {{"TOPLEFT", gtTargetNPCLevels, "BOTTOMLEFT", -16, -8}}, function()
		s.target_npc.based = UIDropDownMenu_GetSelectedValue(gdTargetNPCDynamic)
		f:UpdateTarget()
		f:UpdateLevels()
	end)
	local eTargetNPCNormal1 = EditBox("geTargetNPCNormal1", scrollChild, {{"TOPLEFT", gdTargetNPCDynamic, "BOTTOMLEFT", 24, 0}}, function()
		Levels(geTargetNPCNormal1:GetText(), gtTargetNPCNormal, "target_npc", "Normal", 1)
		f:UpdateTarget()
	end)
	local eTargetNPCNormal2 = EditBox("geTargetNPCNormal2", scrollChild, {{"LEFT", geTargetNPCNormal1, "RIGHT", 8, 0}}, function()
		Levels(geTargetNPCNormal2:GetText(), gtTargetNPCNormal, "target_npc", "Normal", 2)
		f:UpdateTarget()
	end)
	local tTargetNPCNormal = Text("gtTargetNPCNormal", scrollChild, "Normal", nil, {1, 1, 1, 1}, {{"LEFT", eTargetNPCNormal2, "RIGHT", 4, 0}})
	local eTargetNPCRare1 = EditBox("geTargetNPCRare1", scrollChild, {{"TOPLEFT", geTargetNPCNormal1, "BOTTOMLEFT"}}, function()
		Levels(geTargetNPCRare1:GetText(), gtTargetNPCRare, "target_npc", "Rare", 1)
		f:UpdateTarget()
	end)
	local eTargetNPCRare2 = EditBox("geTargetNPCRare2", scrollChild, {{"LEFT", geTargetNPCRare1, "RIGHT", 8, 0}}, function()
		Levels(geTargetNPCRare2:GetText(), gtTargetNPCRare, "target_npc", "Rare", 2)
		f:UpdateTarget()
	end)
	local tTargetNPCRare = Text("gtTargetNPCRare", scrollChild, "Rare", nil, {1, 1, 1, 1}, {{"LEFT", eTargetNPCRare2, "RIGHT", 4, 0}})
	local eTargetNPCRareElite1 = EditBox("geTargetNPCRareElite1", scrollChild, {{"TOPLEFT", geTargetNPCRare1, "BOTTOMLEFT"}}, function()
		Levels(geTargetNPCRareElite1:GetText(), gtTargetNPCRareElite, "target_npc", "RareElite", 1)
		f:UpdateTarget()
	end)
	local eTargetNPCRareElite2 = EditBox("geTargetNPCRareElite2", scrollChild, {{"LEFT", geTargetNPCRareElite1, "RIGHT", 8, 0}}, function()
		Levels(geTargetNPCRareElite2:GetText(), gtTargetNPCRareElite, "target_npc", "RareElite", 2)
		f:UpdateTarget()
	end)
	local tTargetNPCRareElite = Text("gtTargetNPCRareElite", scrollChild, "RareElite", nil, {1, 1, 1, 1}, {{"LEFT", eTargetNPCRareElite2, "RIGHT", 4, 0}})
	
	local eTargetNPCElite1 = EditBox("geTargetNPCElite1", scrollChild, {{"TOPLEFT", geTargetNPCRareElite1, "BOTTOMLEFT"}}, function()
		Levels(geTargetNPCElite1:GetText(), gtTargetNPCElite, "target_npc", "Elite", 1)
		f:UpdateTarget()
	end)
	local eTargetNPCElite2 = EditBox("geTargetNPCElite2", scrollChild, {{"LEFT", geTargetNPCElite1, "RIGHT", 8, 0}}, function()
		Levels(geTargetNPCElite2:GetText(), gtTargetNPCElite, "target_npc", "Elite", 2)
		f:UpdateTarget()
	end)
	local tTargetNPCElite = Text("gtTargetNPCElite", scrollChild, "Elite", nil, {1, 1, 1, 1}, {{"LEFT", eTargetNPCElite2, "RIGHT", 4, 0}})
	local tTargetPlayer = Text("gtTargetPlayer", scrollChild, "Target Player Settings", 18, nil, {{"TOPLEFT", gbPlayer, "BOTTOMLEFT", 0, -8}})
	local cTargetPlayerEnabled = CheckBox("gcTargetPlayerEnabled", scrollChild, s.target_player.enabled, "Enabled", "Enable portrait for target player", {{"TOPLEFT", gtTargetPlayer, "BOTTOMLEFT", 0, -8}}, function()
		s.target_player.enabled = gcTargetPlayerEnabled:GetChecked()
		f:UpdateTarget()
	end)
	local cTargetPlayerDynamic = CheckBox("gcTargetPlayerDynamic", scrollChild, s.target_player.dynamic, "Dynamic", "Change portrait dynamically based on level", {{"TOPLEFT", gcTargetPlayerEnabled, "BOTTOMLEFT"}}, function()
		s.target_player.dynamic = gcTargetPlayerDynamic:GetChecked()
		f:UpdateTarget()
		UIDropDownMenu_SetSelectedValue(gdTargetPlayerStatic, s.target_player.frame)
	end)
	local cTargetPlayerKeep = CheckBox("gcTargetPlayerKeep", scrollChild, s.target_player.keep, "Keep current dragons", "If a target already has a dragon frame, keep it but change texture source", {{"TOPLEFT", gcTargetPlayerDynamic, "BOTTOMLEFT"}}, function()
		s.target_player.keep = gcTargetPlayerKeep:GetChecked()
		f:UpdateTarget()
	end)
	local cTargetPlayerFriendly = CheckBox("gcTargetPlayerFriendly", scrollChild, s.target_player.target["Friendly"], "Friendly", "Change portrait for friendly targets", {{"TOPLEFT", gcTargetPlayerKeep, "BOTTOMLEFT"}}, function()
		s.target_player.target["Friendly"] = gcTargetPlayerFriendly:GetChecked()
		f:UpdateTarget()
	end)
	local cTargetPlayerNeutral = CheckBox("gcTargetPlayerNeutral", scrollChild, s.target_player.target["Neutral"], "Neutral", "Change portrait for neutral targets", {{"LEFT", gtcTargetPlayerFriendly, "RIGHT", 8, 0}}, function()
		s.target_player.target["Neutral"] = gcTargetPlayerNeutral:GetChecked()
		f:UpdateTarget()
	end)
	local cTargetPlayerHostile = CheckBox("gcTargetPlayerHostile", scrollChild, s.target_player.target["Hostile"], "Hostile", "Change portrait for hostile targets", {{"LEFT", gtcTargetPlayerNeutral, "RIGHT", 8, 0}}, function()
		s.target_player.target["Hostile"] = gcTargetPlayerHostile:GetChecked()
		f:UpdateTarget()
	end)	
	local cTargetPlayerUnknown = CheckBox("gcTargetPlayerUnknown", scrollChild, s.target_player.unknown.enabled, "Unknown Level", "Change portrait for unknown level targets (another match must be enabled)", {{"LEFT", gtcTargetPlayerHostile, "RIGHT", 8, 0}}, function()
		s.target_player.unknown.enabled = gcTargetPlayerUnknown:GetChecked()
		f:UpdateTarget()
	end)
	local dTargetPlayerTextures = DropDown("gdTargetPlayerTextures", scrollChild, "Texture source", {"Original", "High Resolution", "Dragonflight", "Original Black", "Dragonflight Black", "Custom"}, s.target_player.texture, 140, {{"TOPLEFT", gcTargetPlayerFriendly, "BOTTOMLEFT", -16, -4}}, function()
		s.target_player.texture = UIDropDownMenu_GetSelectedValue(gdTargetPlayerTextures)
		f:UpdateTarget()
	end)
	local dTargetPlayerStatic = DropDown("gdTargetPlayerStatic", scrollChild, "Portrait frame", {"Normal", "Rare", "RareElite", "Elite"}, s.target_player.frame, 140, {{"TOPLEFT", gdTargetPlayerTextures, "BOTTOMLEFT", 0, 0}}, function()
		s.target_player.frame = UIDropDownMenu_GetSelectedValue(gdTargetPlayerStatic)
		s.target_player.dynamic = false
		gcTargetPlayerDynamic:SetChecked(false)
		f:UpdateTarget()
	end)
	local dTargetPlayerUnknown = DropDown("gdTargetPlayerUnknown", scrollChild, "Unknown level portrait frame", {"Normal", "Rare", "RareElite", "Elite"}, s.target_player.unknown.frame, 140, {{"TOPLEFT", gdTargetPlayerStatic, "BOTTOMLEFT", 0, 0}}, function()
		s.target_player.unknown.frame = UIDropDownMenu_GetSelectedValue(gdTargetPlayerUnknown)
		f:UpdateTarget()
	end)
	local tTargetPlayerLevels = Text("gtTargetPlayerLevels", scrollChild, "Dynamic Settings", 14, nil, {{"TOPLEFT", gdTargetPlayerUnknown, "BOTTOMLEFT", 16, -4}})
	local dTargetPlayerDynamic = DropDown("gdTargetPlayerDynamic", scrollChild, "Portrait based on", {"Levels above player", "Target level"}, "Levels above player", 140, {{"TOPLEFT", gtTargetPlayerLevels, "BOTTOMLEFT", -16, -8}}, function()
		s.target_player.based = UIDropDownMenu_GetSelectedValue(gdTargetPlayerDynamic)
		f:UpdateTarget()
		f:UpdateLevels()
	end)
	local eTargetPlayerNormal1 = EditBox("geTargetPlayerNormal1", scrollChild, {{"TOPLEFT", gdTargetPlayerDynamic, "BOTTOMLEFT", 24, 0}}, function()
		Levels(geTargetPlayerNormal1:GetText(), gtTargetPlayerNormal, "target_player", "Normal", 1)
		f:UpdateTarget()
	end)
	local eTargetPlayerNormal2 = EditBox("geTargetPlayerNormal2", scrollChild, {{"LEFT", geTargetPlayerNormal1, "RIGHT", 8, 0}}, function()
		Levels(geTargetPlayerNormal2:GetText(), gtTargetPlayerNormal, "target_player", "Normal", 2)
		f:UpdateTarget()
	end)
	local tTargetPlayerNormal = Text("gtTargetPlayerNormal", scrollChild, "Normal", nil, {1, 1, 1, 1}, {{"LEFT", eTargetPlayerNormal2, "RIGHT", 4, 0}})
	local eTargetPlayerRare1 = EditBox("geTargetPlayerRare1", scrollChild, {{"TOPLEFT", geTargetPlayerNormal1, "BOTTOMLEFT"}}, function()
		Levels(geTargetPlayerRare1:GetText(), gtTargetPlayerRare, "target_player", "Rare", 1)
		f:UpdateTarget()
	end)
	local eTargetPlayerRare2 = EditBox("geTargetPlayerRare2", scrollChild, {{"LEFT", geTargetPlayerRare1, "RIGHT", 8, 0}}, function()
		Levels(geTargetPlayerRare2:GetText(), gtTargetPlayerRare, "target_player", "Rare", 2)
		f:UpdateTarget()
	end)
	local tTargetPlayerRare = Text("gtTargetPlayerRare", scrollChild, "Rare", nil, {1, 1, 1, 1}, {{"LEFT", eTargetPlayerRare2, "RIGHT", 4, 0}})
	local eTargetPlayerRareElite1 = EditBox("geTargetPlayerRareElite1", scrollChild, {{"TOPLEFT", geTargetPlayerRare1, "BOTTOMLEFT"}}, function()
		Levels(geTargetPlayerRareElite1:GetText(), gtTargetPlayerRareElite, "target_player", "RareElite", 1)
		f:UpdateTarget()
	end)
	local eTargetPlayerRareElite2 = EditBox("geTargetPlayerRareElite2", scrollChild, {{"LEFT", geTargetPlayerRareElite1, "RIGHT", 8, 0}}, function()
		Levels(geTargetPlayerRareElite2:GetText(), gtTargetPlayerRareElite, "target_player", "RareElite", 2)
		f:UpdateTarget()
	end)
	local tTargetPlayerRareElite = Text("gtTargetPlayerRareElite", scrollChild, "RareElite", nil, {1, 1, 1, 1}, {{"LEFT", eTargetPlayerRareElite2, "RIGHT", 4, 0}})
	
	local eTargetPlayerElite1 = EditBox("geTargetPlayerElite1", scrollChild, {{"TOPLEFT", geTargetPlayerRareElite1, "BOTTOMLEFT"}}, function()
		Levels(geTargetPlayerElite1:GetText(), gtTargetPlayerElite, "target_player", "Elite", 1)
		f:UpdateTarget()
	end)
	local eTargetPlayerElite2 = EditBox("geTargetPlayerElite2", scrollChild, {{"LEFT", geTargetPlayerElite1, "RIGHT", 8, 0}}, function()
		Levels(geTargetPlayerElite2:GetText(), gtTargetPlayerElite, "target_player", "Elite", 2)
		f:UpdateTarget()
	end)
	local tTargetPlayerElite = Text("gtTargetPlayerElite", scrollChild, "Elite", nil, {1, 1, 1, 1}, {{"LEFT", eTargetPlayerElite2, "RIGHT", 4, 0}})
	player_settings = {
		gtPlayer, gcPlayerEnabled, gcPlayerDynamic, gcPlayerMove, gdPlayerTextures, gdPlayerStatic, gtPlayerLevels, gePlayerNormal1, gePlayerNormal2, gePlayerRare1, gePlayerRare2, gePlayerRareElite1, gePlayerRareElite2, gePlayerElite1, gePlayerElite2, gtPlayerNormal, gtPlayerRare, gtPlayerRareElite, gtPlayerElite
	}
	targetnpc_settings = {
		gtTargetNPC, gcTargetNPCEnabled, gcTargetNPCDynamic, gcTargetNPCKeep, gcTargetNPCFriendly, gcTargetNPCNeutral, gcTargetNPCHostile, gcTargetNPCUnknown, gdTargetNPCTextures, gdTargetNPCStatic, gdTargetNPCUnknown, gtTargetNPCLevels, gdTargetNPCDynamic, geTargetNPCNormal1, geTargetNPCNormal2, gtTargetNPCNormal, geTargetNPCRare1, geTargetNPCRare2, gtTargetNPCRare, geTargetNPCRareElite1, geTargetNPCRareElite2, gtTargetNPCRareElite, geTargetNPCElite1, geTargetNPCElite2, gtTargetNPCElite
	}
	targetplayer_settings = {
		gtTargetPlayer, gcTargetPlayerEnabled, gcTargetPlayerDynamic, gcTargetPlayerKeep, gcTargetPlayerFriendly, gcTargetPlayerNeutral, gcTargetPlayerHostile, gcTargetPlayerUnknown, gdTargetPlayerTextures, gdTargetPlayerStatic, gdTargetPlayerUnknown, gtTargetPlayerLevels, gdTargetPlayerDynamic, geTargetPlayerNormal1, geTargetPlayerNormal2, gtTargetPlayerNormal, geTargetPlayerRare1, geTargetPlayerRare2, gtTargetPlayerRare, geTargetPlayerRareElite1, geTargetPlayerRareElite2, gtTargetPlayerRareElite, geTargetPlayerElite1, geTargetPlayerElite2, gtTargetPlayerElite
	}
	for i, v in ipairs(targetplayer_settings) do
		v:Hide()
	end
	for i, v in ipairs(targetnpc_settings) do
		v:Hide()
	end
	f:UpdateLevels()
	f:UpdatePlayer()
	InterfaceOptions_AddCategory(self.panel)
end
function f:UpdateLevels()
	local p = UnitLevel("player")
	if s.target_npc.based == "Levels above player" then
		gvTargetNPCNormal = "Normal ("..s.target_npc.levels["Normal"][1].."-"..s.target_npc.levels["Normal"][2]..") Levels ("..s.target_npc.levels["Normal"][1] + p.."-"..s.target_npc.levels["Normal"][2] + p..")"
		gvTargetNPCRare = "Rare ("..s.target_npc.levels["Rare"][1].."-"..s.target_npc.levels["Rare"][2]..") Levels ("..s.target_npc.levels["Rare"][1] + p.."-"..s.target_npc.levels["Rare"][2] + p..")"
		gvTargetNPCRareElite = "RareElite ("..s.target_npc.levels["RareElite"][1].."-"..s.target_npc.levels["RareElite"][2]..") Levels ("..s.target_npc.levels["RareElite"][1] + p.."-"..s.target_npc.levels["RareElite"][2] + p..")"
		gvTargetNPCElite = "Elite ("..s.target_npc.levels["Elite"][1].."-"..s.target_npc.levels["Elite"][2]..") Levels ("..s.target_npc.levels["Elite"][1] + p.."-"..s.target_npc.levels["Elite"][2] + p..")"
	else
		gvTargetNPCNormal = "Normal ("..s.target_npc.levels["Normal"][1].."-"..s.target_npc.levels["Normal"][2]..")"
		gvTargetNPCRare = "Rare ("..s.target_npc.levels["Rare"][1].."-"..s.target_npc.levels["Rare"][2]..")"
		gvTargetNPCRareElite = "RareElite ("..s.target_npc.levels["RareElite"][1].."-"..s.target_npc.levels["RareElite"][2]..")"
		gvTargetNPCElite = "Elite ("..s.target_npc.levels["Elite"][1].."-"..s.target_npc.levels["Elite"][2]..")"
	end
	if s.target_player.based == "Levels above player" then
		gvTargetPlayerNormal = "Normal ("..s.target_player.levels["Normal"][1].."-"..s.target_player.levels["Normal"][2]..") Levels ("..s.target_player.levels["Normal"][1] + p.."-"..s.target_player.levels["Normal"][2] + p..")"
		gvTargetPlayerRare = "Rare ("..s.target_player.levels["Rare"][1].."-"..s.target_player.levels["Rare"][2]..") Levels ("..s.target_player.levels["Rare"][1] + p.."-"..s.target_player.levels["Rare"][2] + p..")"
		gvTargetPlayerRareElite = "RareElite ("..s.target_player.levels["RareElite"][1].."-"..s.target_player.levels["RareElite"][2]..") Levels ("..s.target_player.levels["RareElite"][1] + p.."-"..s.target_player.levels["RareElite"][2] + p..")"
		gvTargetPlayerElite = "Elite ("..s.target_player.levels["Elite"][1].."-"..s.target_player.levels["Elite"][2]..") Levels ("..s.target_player.levels["Elite"][1] + p.."-"..s.target_player.levels["Elite"][2] + p..")"
	else
		gvTargetPlayerNormal = "Normal ("..s.target_player.levels["Normal"][1].."-"..s.target_player.levels["Normal"][2]..")"
		gvTargetPlayerRare = "Rare ("..s.target_player.levels["Rare"][1].."-"..s.target_player.levels["Rare"][2]..")"
		gvTargetPlayerRareElite = "RareElite ("..s.target_player.levels["RareElite"][1].."-"..s.target_player.levels["RareElite"][2]..")"
		gvTargetPlayerElite = "Elite ("..s.target_player.levels["Elite"][1].."-"..s.target_player.levels["Elite"][2]..")"
	end
	gtTargetNPCNormal:SetText(gvTargetNPCNormal)
	gtTargetNPCRare:SetText(gvTargetNPCRare)
	gtTargetNPCRareElite:SetText(gvTargetNPCRareElite)
	gtTargetNPCElite:SetText(gvTargetNPCElite)
	gtTargetPlayerNormal:SetText(gvTargetPlayerNormal)
	gtTargetPlayerRare:SetText(gvTargetPlayerRare)
	gtTargetPlayerRareElite:SetText(gvTargetPlayerRareElite)
	gtTargetPlayerElite:SetText(gvTargetPlayerElite)
end
function f:MovePortrait()
	if s.enabled and s.player.enabled and s.player.move then
		local offset
		if s.player.frame == "RareElite" or s.player.frame == "Elite" then
			if s.player.texture == "Dragonflight" or s.player.texture == "Dragonflight Black" then
				offset = player_rx + 18
			else
				offset = player_rx + 20
			end
		elseif s.player.frame == "Rare" then
			if s.player.texture == "Dragonflight" or s.player.texture == "Dragonflight Black" then
				offset = player_rx
			else
				offset = player_rx + 3
			end
		else
			offset = player_rx
		end
		if gcPlayerMove:GetChecked() then
			PlayerFrame:ClearAllPoints()
			PlayerFrame:SetPoint(player_p, player_rt, player_rp, offset, player_ry)
		else
			PlayerFrame:ClearAllPoints()
			PlayerFrame:SetPoint(player_p, player_rt, player_rp, player_rx, player_ry)
		end
	else
		PlayerFrame:ClearAllPoints()
		PlayerFrame:SetPoint(player_p, player_rt, player_rp, player_rx, player_ry)
	end
end
function f:UpdatePlayer(l)
	local t = s.player
	if s.enabled and t.enabled then
		if not l then
			l = UnitLevel("player")
		end
		if t.dynamic then
			for k, v in pairs(t.levels) do
				if l >= v[1] and l <= v[2] then
					t.frame = k
					break
				end
				t.frame = "Normal"
			end
		else
			t.frame = UIDropDownMenu_GetSelectedValue(gdPlayerStatic)
		end
		PlayerFrameTexture:SetTexture(textures[t.texture][t.frame])
	end
	f:MovePortrait()
end
function f:Target(t)
	local l = UnitLevel("target")
	local p = UnitLevel("player")
	local dragon
	local match
	if t.keep then
		local r = UnitClassification("target")
		if r == "normal" or r == "trivial" or r == "minus" then
			dragon = nil
		end
		if r == "rare" then
			dragon = "Rare"
		elseif r == "rarelite" then
			dragon = "RareElite"
		elseif r == "elite" then
			dragon = "Elite"
		elseif r == "worldboss" then
			dragon = "Elite"
		end
	else
		dragon = nil
	end
	if l > -1 then
		if t.dynamic then
			if t.based == "Levels above player" then
				for k, v in pairs(t.levels) do
					if l >= p + v[1] and l <= p + v[2] then
						t.frame = k
						match = true
						break
					end
				end
			elseif t.based == "Target level" then
				for k, v in pairs(t.levels) do
					if l >= v[1] and l <= v[2] then
						t.frame = k
						match = true
						break
					end
				end
			end
		else
			match = true
		end
		if match and not dragon then
			TargetFrame.borderTexture:SetTexture(textures[t.texture][t.frame])
		elseif dragon then
			TargetFrame.borderTexture:SetTexture(textures[t.texture][dragon])
		else
			TargetFrame.borderTexture:SetTexture(target_texture)
		end
	else
		if t.keep then
			TargetFrame.borderTexture:SetTexture(textures[t.texture]["Elite"])
		else
			if t.unknown.enabled then
				TargetFrame.borderTexture:SetTexture(textures[t.texture][t.unknown.frame])
			else
				TargetFrame.borderTexture:SetTexture(target_texture)
			end
		end
	end
end
function f:UpdateTarget()
	local relation
	local player
	if UnitExists("target") and s.enabled then
		player = UnitIsPlayer("target")
		if UnitIsFriend("player", "target") then
			relation = "Friendly"
		else
			if UnitIsEnemy("player", "target") then
				relation = "Hostile"
			else
				relation = "Neutral"
			end
		end
		if not player and s.target_npc.target[relation] and s.target_npc.enabled then
			f:Target(s.target_npc)
		elseif player and s.target_player.target[relation] and s.target_player.enabled then
			f:Target(s.target_player)
		else
			TargetFrame.borderTexture:SetTexture(target_texture)
		end
	end
end
SLASH_DragonFrames1 = "/dragonframes"
SlashCmdList["DragonFrames"] = function(v)
	InterfaceOptionsFrame_OpenToCategory(f.panel)
end
f:SetScript("OnEvent", f.OnEvent)
