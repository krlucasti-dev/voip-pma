-- used when muted
local disableUpdates = false
local isListenerEnabled = false

function addNearbyPlayers()
	if disableUpdates then return end
	local voiceModeData = Cfg.voiceModes[mode]
	if not voiceModeData then return end

	local coords = GetEntityCoords(PlayerPedId())
	local distance = GetConvar('voice_useNativeAudio', 'false') == 'true' and voiceModeData[1] * 3 or voiceModeData[1]
	local assignedChannel = LocalPlayer.state.assignedChannel or playerServerId

	MumbleClearVoiceTargetChannels(voiceTarget)
	MumbleSetVoiceTarget(voiceTarget)

	local myChannel = MumbleGetVoiceChannelFromServerId(playerServerId)
	if assignedChannel and myChannel ~= assignedChannel then
		MumbleSetVoiceChannel(assignedChannel)
		myChannel = assignedChannel
	end

	if myChannel and myChannel ~= -1 then
		MumbleAddVoiceTargetChannel(voiceTarget, myChannel)
	end

	local players = GetActivePlayers()
	for i = 1, #players do
		local ply = players[i]
		local serverId = GetPlayerServerId(ply)

		if serverId == playerServerId then goto skip_loop end

		local ped = GetPlayerPed(ply)
		if DoesEntityExist(ped) and #(coords - GetEntityCoords(ped)) < distance then
			local channel = MumbleGetVoiceChannelFromServerId(serverId)
			if channel ~= -1 then
				logger.verbose('Added %s as a voice target (channel %s)', serverId, channel)
				MumbleAddVoiceTargetChannel(voiceTarget, channel)
			end
		end

		::skip_loop::
	end
end

function setSpectatorMode(enabled)
	logger.info('Setting spectate mode to %s', enabled)
	isListenerEnabled = enabled
	local players = GetActivePlayers()
	if isListenerEnabled then
		for i = 1, #players do
			local ply = players[i]
			local serverId = GetPlayerServerId(ply)
			if serverId == playerServerId then goto skip_loop end
			logger.verbose("Adding %s to listen table", serverId)
			MumbleAddVoiceChannelListen(serverId)
			::skip_loop::
		end
	else
		for i = 1, #players do
			local ply = players[i]
			local serverId = GetPlayerServerId(ply)
			if serverId == playerServerId then goto skip_loop end
			logger.verbose("Removing %s from listen table", serverId)
			MumbleRemoveVoiceChannelListen(serverId)
			::skip_loop::
		end
	end
end

RegisterNetEvent('onPlayerJoining', function(serverId)
	if isListenerEnabled then
		MumbleAddVoiceChannelListen(serverId)
		logger.verbose("Adding %s to listen table", serverId)
	end
end)

RegisterNetEvent('onPlayerDropped', function(serverId)
	if isListenerEnabled then
		MumbleRemoveVoiceChannelListen(serverId)
		logger.verbose("Removing %s from listen table", serverId)
	end
end)

-- cache talking status so we only send a nui message when its not the same as what it was before
local lastTalkingStatus = false
local lastRadioStatus = false
Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/muteply', 'Mutes the player with the specified id', {
		{ name = "player id", help = "the player to toggle mute" },
		{ name = "duration", help = "(opt) the duration the mute in seconds (default: 900)" }
	})
	while true do
		-- wait for mumble to reconnect
		while not MumbleIsConnected() or not isInitialized do
			Wait(100)
		end
		if GetConvarInt('voice_enableUi', 1) == 1 then
			if lastRadioStatus ~= radioPressed or lastTalkingStatus ~= (MumbleIsPlayerTalking(PlayerId()) == 1) then
				lastRadioStatus = radioPressed
				lastTalkingStatus = MumbleIsPlayerTalking(PlayerId()) == 1
				SendNUIMessage({
					usingRadio = lastRadioStatus,
					talking = lastTalkingStatus
				})
				TriggerEvent("hv-hud:voiceTalking", lastTalkingStatus)
			end
		end
		addNearbyPlayers()
		local isSpectating = NetworkIsInSpectatorMode()
		if isSpectating and not isListenerEnabled then
			setSpectatorMode(true)
		elseif not isSpectating and isListenerEnabled then
			setSpectatorMode(false)
		end

		Wait(GetConvarInt('voice_refreshRate', 200))
	end
end)
