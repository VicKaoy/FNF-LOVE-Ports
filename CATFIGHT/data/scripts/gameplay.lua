local lyricsText
local Pause = Script("data/states/pause").chunk()
local isFH = Project.FHversion ~= nil

function postCreate()
	if not isFH then
		state.healthBar.bar.color = Color.fromHEX(0xFFF1E2)
		state.healthBar.bar.color.bg = Color.fromHEX(0x2B1F2D)
	end

	for _, nf in pairs(state.notefields) do
		if nf.is then
			local prevspeed = nf.speed
			nf.offsetTime = -1.25
			nf.speed = prevspeed / 3.6
			local t = state.conductor.crotchet
			state.tween:tween(nf, {offsetTime = 0}, 0.5, {
				ease = "quadInOut",
				onComplete = function()
					state.tween:tween(nf, {speed = prevspeed}, 1, {ease = "quadIn"})
				end}
			)
		end
	end
	state:playSong(0)

	lyricsText = Text(400, 480, "",
		paths.getFont("lyricfont.ttf", 16), Color.WHITE, "center", game.width - 800)
	lyricsText:setOutline("simple", nil, {x = 1, y = 2})
	lyricsText:setScrollFactor()
	lyricsText.cameras = {state.camHUD}
	state:add(lyricsText)

	lyricsText.scale.x = 1.3
	state.scoreText.scale.y = 1.3
	lyricsText:centerOrigin()
	state.scoreText:centerOrigin()

	state.scoreText.font = paths.getFont("lyricfont.ttf", 16)
	state.scoreText:setOutline("simple", nil, {x = 1, y = 2})
	state.scoreText:__updateDimension()
	state.scoreText.antialiasing = true
	if state.positionHUD then
		state:positionHUD()
	else
		state:positionText()
	end

	game.camera.alpha = 0.001
end

function beat(b)
	if b == 3 then
		state.tween:tween(game.camera, {alpha = 1}, state.conductor.crotchet / 1000)
	end

	if b == 292 and state.SONG.song:lower():endsWith("silly") then
		state.tween:tween(lyricsText, {angle = 56, x = -400, y = -200}, 2, {ease = Ease.sineInOut})
	end
end

function onCountdownCreation(e)
	e:cancel()
end

function onEvent(event)
	if event.e == "Lyrics" then
		lyricsText.content = event.v[1]
	end
end

local botplaySine = 0
function postUpdate(dt)
	if lyricsText.visible then
		botplaySine = botplaySine + 180 * dt
		lyricsText.alpha = 1 - (math.sin((math.pi * botplaySine) / 180) / 4)
	end
end

function onGameOver(event)
	event:cancel()

	state.paused = true
	state.isDead = true
	GameOverSubstate.deaths = GameOverSubstate.deaths + 1

	Tween.tween(state, {playback = 0}, 0.6, {
		ease = Ease.sineIn,
		onComplete = function()
			state:pauseSong()
			Tween.tween(game.camera, {alpha = 0}, 0.23, {onComplete = function()
				game.resetState(true)
			end})
		end,
		onUpdate = function() state:setPlayback() end
	})
end

function pause()
	game.camera:unfollow()
	game.camera:freeze()
	state.camNotes:freeze()
	state.camHUD:freeze()

	state:pauseSong()

	if state.buttons then state:remove(state.buttons) end

	local pause = Pause()
	pause.cameras = {state.camOther}
	state:openSubstate(pause)

	return Event_Cancel
end

function endSong()
	game.sound.music.onComplete = nil

	local score = state.score or state.playerNotefield.score
	if not state.usedBotPlay then
		Highscore.saveScore(PlayState.SONG.song, score, state.songDifficulty)
	end

	game.sound.music:reset(true)

	GameOverSubstate.deaths = 0
	PlayState.canFadeInReceptors = true
	game.camera:unfollow()

	game.switchState(FreeplayState())
	util.playMenuMusic()

	controls:unbindPress(state.bindedKeyPress)
	controls:unbindRelease(state.bindedKeyRelease)

	return Event_Cancel
end