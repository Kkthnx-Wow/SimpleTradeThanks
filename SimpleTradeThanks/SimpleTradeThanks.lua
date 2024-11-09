local _, Module = ...

-- local Module = CreateFrame("Frame")
-- Module:RegisterEvent("PLAYER_LOGIN")
-- Module:RegisterEvent("VARIABLES_LOADED")

local LocaleTable = {
	["Thanks_deDE"] = "Danke",
	["Thanks_esES"] = "Gracias",
	["Thanks_esMX"] = "Gracias",
	["Thanks_frFR"] = "Merci",
	["Thanks_itIT"] = "Grazie",
	["Thanks_koKR"] = "감사합니다",
	["Thanks_ptBR"] = "Obrigado",
	["Thanks_ruRU"] = "Спасибо",
	["Thanks_zhCN"] = "谢谢",
	["Thanks_zhTW"] = "謝謝",
	["SimpleTradeThanks_deDE"] = "SimpleTradeThanks ist ein World of Warcraft-Addon,|ndas Spielern ermöglicht, ihren Handelspartnern eine Dankesbotschaft zu senden.",
	["SimpleTradeThanks_esES"] = "SimpleTradeThanks es un complemento de World of Warcraft|nque permite a los jugadores enviar un mensaje de agradecimiento a sus compañeros de comercio.",
	["SimpleTradeThanks_esMX"] = "SimpleTradeThanks es un complemento de World of Warcraft|nque permite a los jugadores enviar un mensaje de agradecimiento a sus compañeros de comercio.",
	["SimpleTradeThanks_frFR"] = "SimpleTradeThanks est un complément de World of Warcraft|npermettant aux joueurs d'envoyer un message de remerciement à leurs partenaires de commerce.",
	["SimpleTradeThanks_itIT"] = "SimpleTradeThanks è un addon di World of Warcraft|nche consente ai giocatori di inviare un messaggio di ringraziamento ai loro partner commerciali.",
	["SimpleTradeThanks_koKR"] = "SimpleTradeThanks는 World of Warcraft의 애드온입니다.|n거래 상대에게 감사 메시지를 보낼 수 있습니다.",
	["SimpleTradeThanks_ptBR"] = "SimpleTradeThanks é um complemento do World of Warcraft|nque permite que os jogadores enviam uma mensagem de agradecimento aos seus parceiros comerciais.",
	["SimpleTradeThanks_ruRU"] = "SimpleTradeThanks - это дополнение для World of Warcraft,|nпозволяющее игрокам отправлять сообщение с благодарностью своим торговым партнерам.",
	["SimpleTradeThanks_zhCN"] = "SimpleTradeThanks是一款魔兽世界的插件，|n允许玩家向他们的交易伙伴发送感谢信息。",
	["SimpleTradeThanks_zhTW"] = "SimpleTradeThanks是一個魔獸世界的插件，|n允許玩家向他們的交易夥伴發送感謝信息。",
}

local ThanksText = LocaleTable["Thanks_" .. GetLocale()] or "Thanks"
-- local SimpleTradeThanksText = LocaleTable["SimpleTradeThanks_" .. GetLocale()] or "SimpleTradeThanks is a World of Warcraft addon|nthat allows players to send a thank you message to their trade partners."

function Module:CreateThanksButton()
	self.thanksButton = CreateFrame("Button", nil, TradeFrame, "UIPanelButtonTemplate")
	self.thanksButton:SetSize(80, 20)
	self.thanksButton:SetText(ThanksText)
	self.thanksButton:SetPoint("BOTTOMLEFT", TradeFrame, "BOTTOMLEFT", 4, 6)
	self.thanksButton:SetScript("OnClick", function()
		if self.targetName and self:CanSendThanks() then
			DoEmote(EMOTE98_TOKEN, self.targetName)
			self:SetThanksCooldown()
		end
	end)
end

function Module:CanSendThanks()
	local currentTime = GetTime()
	if currentTime - self.lastClickTime < 5 then
		return false
	end
	return true
end

function Module:SetThanksCooldown()
	self.thanksButton:Disable()
	self.lastClickTime = GetTime()
	self:SetScript("OnUpdate", self.UpdateThanksText)
	C_Timer.After(5, function()
		self.thanksButton:Enable()
		self.thanksButton:SetText(ThanksText)
		self:SetScript("OnUpdate", nil)
	end)
end

function Module:UpdateThanksText()
	if self.lastClickTime then
		local currentTime = GetTime()
		local elapsedTime = currentTime - self.lastClickTime
		if elapsedTime < 5 then
			self.thanksButton:SetText(string.format(ThanksText .. " (%d)", 5 - elapsedTime))
		end
	end
end

function Module:GetUnitPlayerName()
	local targetName = GetUnitName("NPC", true)
	if self.thanksButton then
		self.targetName = targetName
	end
end

function Module:UpdateThanksButton()
	if Module:GetOption("Enable") then
		if self.thanksButton then
			self.thanksButton:Show()
		else
			self:CreateThanksButton()
		end
	else
		if self.thanksButton then
			self.thanksButton:Hide()
		end
	end
end

function Module:PLAYER_LOGIN()
	self.lastClickTime = 0
	if Module:GetOption("Enable") then
		self:CreateThanksButton()
		Module:TRADE_SHOW()
	end
end

function Module:TRADE_SHOW()
	self:GetUnitPlayerName()
end
