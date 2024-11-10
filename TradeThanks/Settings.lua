local _, Settings = ...

Settings:RegisterSettings("TradeThanksDB", {
	{
		key = "enableButton",
		type = "toggle",
		title = "Enable Thank-You Button",
		tooltip = "Adds a button to the trade window that allows you to quickly send a thank-you message to your trading partner.",
		default = true,
	},
	{
		key = "thanksCounter",
		type = "toggle",
		title = "Track Thank-You Messages",
		tooltip = "Keeps track of the total number of thank-you messages sent per session.",
		default = false,
	},
	{
		key = "thanksSource",
		type = "menu",
		title = "Choose Thanks Method",
		tooltip = "Select the preferred method for sending thanks.",
		default = EMOTE,
		options = {
			{ value = EMOTE, label = "Emote" },
			{ value = WHISPER, label = "Whisper" },
			{ value = SAY, label = "Say" },
		},
	},
})

Settings:RegisterSettingsSlash("/stt")

function Settings:OnLoad()
	if not TradeThanksDB then
		-- set default
		TradeThanksDB = CopyTable(TradeThanksDB)
	end

	if TradeThanksDB and TradeThanksDB.enableButton ~= nil and type(TradeThanksDB.enableButton) == "boolean" then
		TradeThanksDB.enableButton = TradeThanksDB.enableButton and 3 or 1
	end

	if TradeThanksDB and TradeThanksDB.thanksCounter ~= nil and type(TradeThanksDB.thanksCounter) == "boolean" then
		TradeThanksDB.thanksCounter = TradeThanksDB.thanksCounter and 3 or 1
	end
end
