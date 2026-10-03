isInitialized = false

local function getAssignedChannel()
	local channel = LocalPlayer.state.assignedChannel
	if type(channel) ~= 'number' or channel == 0 then
		return playerServerId
	end
	return channel
end

function handleInitialState()
	local voiceModeData = Cfg.voiceModes[mode]
	MumbleSetAudioInputDistance(voiceModeData[1] + 0.0)
	MumbleSetTalkerProximity(voiceModeData[1] + 0.0)
	MumbleClearVoiceTarget(voiceTarget)
	MumbleSetVoiceTarget(voiceTarget)

	local waited = 0
	while (type(LocalPlayer.state.assignedChannel) ~= 'number' or LocalPlayer.state.assignedChannel == 0) and waited < 50 do
		Wait(100)
		waited = waited + 1
	end

	local assignedChannel = getAssignedChannel()
	MumbleSetVoiceChannel(assignedChannel)

	-- The first MumbleSetVoiceChannel often fails; retry until we actually land on the channel.
	local channelWait = 0
	while MumbleGetVoiceChannelFromServerId(playerServerId) ~= assignedChannel and channelWait < 50 do
		Wait(100)
		MumbleSetVoiceChannel(assignedChannel)
		channelWait = channelWait + 1
	end

	if MumbleGetVoiceChannelFromServerId(playerServerId) ~= assignedChannel then
		logger.warn('Could not join assigned voice channel %s, proximity voice may fail until reconnect.', assignedChannel)
	end

	isInitialized = true
	MumbleAddVoiceTargetChannel(voiceTarget, assignedChannel)
	addNearbyPlayers()
end

AddEventHandler('mumbleConnected', function(address, isReconnecting)
	logger.info('Connected to mumble server with address of %s, is this a reconnect %s', GetConvarInt('voice_hideEndpoints', 1) == 1 and 'HIDDEN' or address, isReconnecting)

	logger.log('Connecting to mumble, setting targets.')
	-- don't try to set channel instantly, we're still getting data.
	local voiceModeData = Cfg.voiceModes[mode]
	LocalPlayer.state:set('proximity', {
		index = mode,
		distance =  voiceModeData[1],
		mode = voiceModeData[2],
	}, true)

	handleInitialState()

	logger.log('Finished connection logic')
end)

AddEventHandler('mumbleDisconnected', function(address)
	isInitialized = false
	logger.info('Disconnected from mumble server with address of %s', GetConvarInt('voice_hideEndpoints', 1) == 1 and 'HIDDEN' or address)
end)

-- TODO: Convert the last Cfg to a Convar, while still keeping it simple.
AddEventHandler('pma-voice:settingsCallback', function(cb)
	cb(Cfg)
end)

-- mumbleConnected may have already fired before this file registered the handler
CreateThread(function()
	while not MumbleIsConnected() do
		Wait(100)
	end
	if not isInitialized then
		logger.log('Mumble already connected, running initial voice state.')
		handleInitialState()
	end
end)