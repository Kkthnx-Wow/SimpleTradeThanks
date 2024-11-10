local _, Module = ...

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
}

local ThanksText = LocaleTable["Thanks_" .. GetLocale()] or "Thanks"

local ThanksValue
Module:RegisterOptionCallback("thanksSource", function(value)
	ThanksValue = value
end)

local thanksCount = 0
function Module:DisplayThanksCount()
	local message = "You've sent thanks " .. thanksCount .. " times this session."
	DEFAULT_CHAT_FRAME:AddMessage(message)
end

function Module:CreateThanksButton()
	self.thanksButton = Module:CreateFrame("Button", nil, TradeFrame, "UIPanelButtonTemplate")
	self.thanksButton:SetSize(80, 20)
	self.thanksButton:SetText(ThanksText)
	self.thanksButton:SetPoint("BOTTOMLEFT", TradeFrame, "BOTTOMLEFT", 4, 6)
	self.thanksButton:SetScript("OnClick", function()
		if self.targetName and self:CanSendThanks() then
			-- print(ThanksValue)
			if ThanksValue == EMOTE then
				DoEmote(EMOTE98_TOKEN, self.targetName)
			elseif ThanksValue == WHISPER then
				SendChatMessage(ThanksText, "WHISPER", nil, self.targetName)
			elseif ThanksValue == SAY then
				SendChatMessage(ThanksText .. " " .. self.targetName)
			else
				SendChatMessage(ThanksText .. " " .. self.targetName) -- Fallback
			end
			self:SetThanksCooldown()
			if Module:GetOption("thanksCounter") then
				thanksCount = thanksCount + 1
				Module:DisplayThanksCount()
			end
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
	self.thanksButton:SetScript("OnUpdate", self.UpdateThanksText)
	C_Timer.After(5, function()
		self.thanksButton:Enable()
		self.thanksButton:SetText(ThanksText)
		self.thanksButton:SetScript("OnUpdate", nil)
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
	if Module:GetOption("enableButton") then
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
	if Module:GetOption("enableButton") then
		self:CreateThanksButton()
		Module:TRADE_SHOW()
	end
end

function Module:TRADE_SHOW()
	self:GetUnitPlayerName()
end
