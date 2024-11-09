local _, Settings = ...

Settings:RegisterSettings("SimpleTradeThanksDB", {
	{
		key = "Enable",
		type = "toggle",
		title = "Enable Simple Trade Thanks",
		default = true,
	},
	-- {
	-- 	key = "share",
	-- 	type = "toggle",
	-- 	title = L["Automatically share quests"],
	-- 	default = false,
	-- },
})

Settings:RegisterSettingsSlash("/stt")

function Settings:OnLoad()
	if not SimpleTradeThanksDB then
		-- set default
		SimpleTradeThanksDB = CopyTable(SimpleTradeThanksDB)
	end

	if SimpleTradeThanksDB and SimpleTradeThanksDB.Enable ~= nil and type(SimpleTradeThanksDB.Enable) == "boolean" then
		SimpleTradeThanksDB.Enable = SimpleTradeThanksDB.Enable and 3 or 1
	end
end
