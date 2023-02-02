-- © 2023 Josh 'Kkthnx' Russell All Rights Reserved

-- | Todo List | --
-- Track how many people we have said thanks to when using this addon thanks button
-- Let the user define the wait time before they can spam the button again? Idk 5 seems more than enough
-- Write a description in the addons settings category explaining the addon

-- Create a frame for the module
local Module = CreateFrame("Frame")

-- Register events for the frame: PLAYER_LOGIN and ADDON_LOADED
Module:RegisterEvent("PLAYER_LOGIN")
Module:RegisterEvent("ADDON_LOADED")

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
			DoEmote("THANK", self.targetName)

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

function Module:InitializeOptions()
	if not SimpleTradeThanksDB then
		SimpleTradeThanksDB = {}
	end
	SimpleTradeThanksDB.enabled = SimpleTradeThanksDB.enabled or false

	-- Create the config panel frame
	local ConfigPanel = CreateFrame("Frame")
	-- Set the name of the config panel to be displayed in the Interface Options
	ConfigPanel.name = "|cff669DFFSimpleTradeThanks|r"

	-- Create the Enable/Disable checkbox for the Thanks Module
	local EnableCheckbox = CreateFrame("CheckButton", nil, ConfigPanel, "InterfaceOptionsCheckButtonTemplate")
	-- Set the position of the checkbox on the config panel
	EnableCheckbox:SetPoint("TOPLEFT", 20, -20)
	-- Set the text of the checkbox
	EnableCheckbox.Text:SetText("Enable and add a thanks button to the trade frame")
	-- Add an OnClick event to the checkbox
	EnableCheckbox:SetScript("OnClick", function()
		-- Save the state of the checkbox to the saved variable SimpleTradeThanksDB
		SimpleTradeThanksDB.enabled = EnableCheckbox:GetChecked()
		-- If the checkbox is checked (enabled), then show the button
		if SimpleTradeThanksDB.enabled then
			Module.thanksButton:Show()
			-- print("SimpleTradeThanks enabled")
			-- If the checkbox is not checked (disabled), then hide the button
		else
			Module.thanksButton:Hide()
			-- print("SimpleTradeThanks disabled")
		end
	end)

	-- Add the config panel to the Interface Options
	InterfaceOptions_AddCategory(ConfigPanel)
end

function Module:OnEvent(event, addon)
	-- Check if the event that triggered the function is TRADE_SHOW
	if event == "TRADE_SHOW" then
		-- Set the targetName variable to the name of the target NPC
		self.targetName = UnitName("NPC")
	-- Check if the event that triggered the function is PLAYER_LOGIN
	elseif event == "PLAYER_LOGIN" then
		self.lastClickTime = 0
		-- Create the "Thanks" button
		self:CreateThanksButton()
		-- Register the TRADE_SHOW event to trigger the OnEvent function
		if SimpleTradeThanksDB.enabled then
			self:RegisterEvent("TRADE_SHOW", self.OnEvent)
		end
	-- Check if the event that triggered the function is ADDON_LOADED and the addon that loaded is SimpleTradeThanks
	elseif event == "ADDON_LOADED" and addon == "SimpleTradeThanks" then
		-- Initialize the options for the addon
		self:InitializeOptions()
	end
end

-- Set the OnEvent script for the Module frame to trigger the OnEvent function when an event is fired
Module:SetScript("OnEvent", Module.OnEvent)
