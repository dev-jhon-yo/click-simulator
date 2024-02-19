local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Template = require(ServerScriptService.Server.PlayerData.Template)
local Manager = require(ServerScriptService.Server.PlayerData.Manager)
local ProfileService = require(ServerScriptService.Server.Libs.ProfileService)

local ProfileStore = ProfileService.GetProfileStore("Production", Template)

local KICK_MESSAGE = "Data issue, try again shortly. If issue persists, contact us!"

local function CreateLeaderstats(player: Player)
	local profile = Manager.Profiles[player]

	if not profile then
		return
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local clicks = Instance.new("NumberValue")
	clicks.Name = "Clicks"
	clicks.Value = profile.Data.Clicks
	clicks.Parent = leaderstats

	local gems = Instance.new("NumberValue")
	gems.Name = "Gems"
	gems.Value = profile.Data.Gems
	gems.Parent = leaderstats
end

local function LoadProfile(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if not profile then
		player:Kick(KICK_MESSAGE)
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		Manager.Profiles[player] = nil
		player:Kick(KICK_MESSAGE)
	end)

	if player:IsDescendantOf(Players) == true then
		Manager.Profiles[player] = profile
		CreateLeaderstats(player)
	else
		profile:Release()
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(LoadProfile, player)
end

Players.PlayerAdded:Connect(LoadProfile)
Players.PlayerRemoving:Connect(function(player)
	local profile = Manager.Profiles[player]

	if profile then
		profile:Release()
	end
end)
