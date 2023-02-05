-- © 2023 Josh 'Kkthnx' Russell All Rights Reserved

-- | Todo List | --
-- Track how many people we have said thanks to when using this addon thanks button
-- Let the user define the wait time before they can spam the button again? Idk 5 seems more than enough
-- Write a description in the addons settings category explaining the addon

-- Create a frame for the module
local Module = CreateFrame("Frame")
-- Register the events for the module
Module:RegisterEvent("PLAYER_LOGIN")
Module:RegisterEvent("VARIABLES_LOADED")

-- Map WOW_PROJECT_ID values to expansion names
local Expansion = {
	[WOW_PROJECT_MAINLINE] = "Retail",
	[WOW_PROJECT_CLASSIC] = "Classic", -- Not used?
	[WOW_PROJECT_BURNING_CRUSADE_CLASSIC] = "TBC", -- Is TBC still a thing?
	[WOW_PROJECT_WRATH_CLASSIC] = "Wrath",
}

-- Determine the current expansion based on WOW_PROJECT_ID
local currentExpansion = Expansion[WOW_PROJECT_ID]

-- Function to create the "Thanks" button
function Module:CreateThanksButton()
	-- Create a button frame
	self.thanksButton = CreateFrame("Button", nil, TradeFrame, "UIPanelButtonTemplate")

	-- Set the button size to 80x20
	self.thanksButton:SetSize(80, 20)

	-- Set the button text to "Thanks"
	self.thanksButton:SetText("Thanks")

	-- Set the button position to bottom left of the TradeFrame, 4 pixels from the left and 6 pixels from the bottom
	self.thanksButton:SetPoint("BOTTOMLEFT", TradeFrame, "BOTTOMLEFT", 4, 6)

	-- Add a script to the button's OnClick event
	self.thanksButton:SetScript("OnClick", function()
		-- Check if the target name is set and if the player is able to send a "Thanks" message
		if self.targetName and self:CanSendThanks() then
			-- Use the DoEmote function to perform the "THANK" emote towards the target
			DoEmote(EMOTE98_TOKEN, self.targetName)

			-- Set the cooldown for the "Thanks" button
			self:SetThanksCooldown()
		end
	end)
end

function Module:CanSendThanks()
	-- Get the current time
	local currentTime = GetTime()
	-- Check if the time difference between the current time and the last click time is less than 5 value
	if currentTime - self.lastClickTime < 5 then
		-- If the time difference is less than 5 value, return false
		return false
	end
	-- If the time difference is more than or equal to 5 value, return true
	return true
end

function Module:SetThanksCooldown()
	-- Disable the "Thanks" button
	self.thanksButton:Disable()
	-- Get the current time and store it in lastClickTime
	self.lastClickTime = GetTime()
	-- Create a timer that will run after 5 value in seconds
	C_Timer.After(5, function()
		-- Enable the "Thanks" button after 5 set value has passed
		self.thanksButton:Enable()
	end)
end

-- Function to handle trade show interactions
function Module:GetUnitPlayerName()
	-- Get the name of the target NPC
	local targetName = GetUnitName("NPC", true)

	-- Check if the thanks button exists
	if self.thanksButton then
		-- Set the targetName variable to the name of the target NPC
		self.targetName = targetName
	end
end

-- Function to update the thanks button
function Module:UpdateThanksButton()
	-- Check if the trade thanks feature is enabled
	if SimpleTradeThanksDB.enabled then
		-- Check if the thanks button exists
		if self.thanksButton then
			-- Show the thanks button
			self.thanksButton:Show()
		else
			-- Call the setup function for the thanks button
			self:CreateThanksButton()
		end

		-- Register the "TRADE_SHOW" event
		Module:RegisterEvent("TRADE_SHOW")
	else
		-- Check if the thanks button exists
		if self.thanksButton then
			-- Hide the thanks button
			self.thanksButton:Hide()
		end

		-- Unregister the "TRADE_SHOW" event
		Module:UnregisterEvent("TRADE_SHOW")
	end
end

function Module:CreateSimpleTradeThankOptions()
	-- Determine which options panel to use
	local optionsPanel = currentExpansion == "Retail" and SettingsPanel.Container or InterfaceOptionsFramePanelContainer

	-- Define the default saved variable values
	local SimpleTradeThanksDefaults = {
		-- Boolean indicating if the trade thanks feature is enabled
		enabled = false,
	}

	-- Create the saved variable or use the existing one
	SimpleTradeThanksDB = SimpleTradeThanksDB or CopyTable(SimpleTradeThanksDefaults)

	-- Create the config panel frame
	self.ConfigPanel = CreateFrame("Frame")
	-- Set the name of the config panel to be displayed in the Interface Options
	self.ConfigPanel.name = "|cff669DFFSimpleTradeThanks|r"

	-- Create the scroll frame and position it within the panel
	local scrollFrame = CreateFrame("ScrollFrame", nil, self.ConfigPanel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 3, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)

	-- Create the scroll child frame and set its width to fit within the panel
	local scrollChild = CreateFrame("Frame")
	scrollFrame:SetScrollChild(scrollChild)
	scrollChild:SetWidth(optionsPanel:GetWidth() - 18)

	-- Set a minimum height for the scroll child frame
	scrollChild:SetHeight(1)

	-- Add widgets to the scrolling child frame as desired
	local title = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
	title:SetPoint("TOP")
	title:SetText(self.ConfigPanel.name)

	local footer = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormal")
	footer:SetPoint("TOP", 0, -26)
	footer:SetText("SimpleTradeThanks is a World of Warcraft addon that|nallows players to send a thank you message to their trade partners.|nMore features coming soon!")

	-- Create the Enable/Disable checkbox for the Thanks Module
	local EnableCheckbox = CreateFrame("CheckButton", nil, scrollChild, "InterfaceOptionsCheckButtonTemplate")
	-- Set the position of the checkbox on the config panel
	EnableCheckbox:SetPoint("TOPLEFT", 0, -80)
	-- Set the text of the checkbox
	EnableCheckbox.Text:SetText("Enable and add a thanks button to the trade frame")
	-- Add an OnClick event to the checkbox
	EnableCheckbox:SetScript("OnClick", function()
		-- Save the state of the checkbox to the saved variable SimpleTradeThanksDB
		SimpleTradeThanksDB.enabled = EnableCheckbox:GetChecked()

		-- If the checkbox is checked (enabled), then show the button and register TRADE_SHOW event
		if SimpleTradeThanksDB.enabled then
			Module:UpdateThanksButton()
			-- If the checkbox is not checked (disabled), then hide the button and unregister TRADE_SHOW event
		else
			Module:UpdateThanksButton()
		end
	end)
	EnableCheckbox:SetChecked(SimpleTradeThanksDB.enabled)

	-- Add the config panel to the Interface Options
	InterfaceOptions_AddCategory(self.ConfigPanel)
end

-- Function to handle events
Module:SetScript("OnEvent", function(self, event)
	-- Check if the event is "PLAYER_LOGIN"
	if event == "PLAYER_LOGIN" then
		-- Set the last click time to 0
		self.lastClickTime = 0
		if SimpleTradeThanksDB.enabled then
			-- Call the function to create the thanks button
			self:CreateThanksButton()
			-- Register the "TRADE_SHOW" event
			Module:RegisterEvent("TRADE_SHOW")
		end
	-- Check if the event is "VARIABLES_LOADED"
	elseif event == "VARIABLES_LOADED" then
		-- Call the functions to create the options panel and unregister the event
		self:CreateSimpleTradeThankOptions()
		self:UnregisterEvent(event)
	elseif event == "TRADE_SHOW" then
		-- Call the functions to create the options panel and unregister the event
		self:GetUnitPlayerName()
	end
end)

-- Define the slash commands for opening the options panel
SLASH_SIMPLETRADETHANKS1 = "/stt"
SLASH_SIMPLETRADETHANKS2 = "/simpletradethanks"
SlashCmdList.SIMPLETRADETHANKS = function()
	-- Open the options panel to the "Module.ConfigPanel" category
	InterfaceOptionsFrame_OpenToCategory(Module.ConfigPanel)
end
