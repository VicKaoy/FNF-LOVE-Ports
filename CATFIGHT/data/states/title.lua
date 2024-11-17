local IMGBackdrop = require "image_backdrop"
local confirmed, p = false, "menus/title/"

local trans = require "transition"
game.discardTransition()
game.getState().transIn = trans()
game.getState().transOut = trans()

local bd1, bd2

function create()
	local back = Graphic(0, 0,
		game.width, game.height, Color.fromHEX(0x1D152A))
	state:add(back)

	bd2 = IMGBackdrop(paths.getImage(p .. "CUNT"))
	bd2:setGraphicSize(576)
	bd2:updateHitbox()
	bd2.color = Color.fromHEX(0xDC5D24)
	state:add(bd2)

	bd1 = IMGBackdrop(paths.getImage(p .. "CUNT"))
	bd1:setGraphicSize(576)
	bd1:updateHitbox()
	state:add(bd1)

	local splash = Sprite(0, 0, paths.getImage(p .. "splashhole"))
	splash:setGraphicSize(1280)
	splash:updateHitbox()
	state:add(splash)

	local notes = Sprite(600, 0)
	notes:setFrames(paths.getAtlas(p .. "music_notes"))
	notes:addAnimByPrefix("anim", "music notes", 24, true)
	notes:play("anim")
	notes:setGraphicSize(notes.width / 1.5)
	notes:updateHitbox()
	state:add(notes)

	local overlay = Sprite(0, 0, paths.getImage(p .. "overlaything"))
	overlay:setGraphicSize(1280)
	overlay:updateHitbox()
	state:add(overlay)

	local title = Sprite(0, 0, paths.getImage(p .. "logoyes"))
	title:setGraphicSize(1280)
	title:updateHitbox()
	state:add(title)

	if love.system.getDevice() == "Mobile" then
		state:add(VirtualPad("return", 0, 0, game.width, game.height, false))
	elseif love.system.getDevice() == "Desktop" then
		Discord.changePresence({details = "In the Menus", state = "Title Screen"})
	end

	local color = ClientPrefs.data.flashingLights and Color.WHITE or Color.BLACK
	game.camera:flash(color, 2)

	util.playMenuMusic(true)

	return Event_Cancel
end

function update(dt)
	bd1.x = bd1.x - 60 * dt
	bd2.x = bd2.x + 60 * dt

	local pressed = controls:pressed("accept")

	if pressed and not confirmed then
		confirmed = true
		if ClientPrefs.data.flashingLights then
			game.camera:flash(Color.WHITE, 1.2)
			game.camera.__flashAlpha = 0.5
		end
		game.sound.play(paths.getSound("confirmMenu"))

		Timer():start(1.5, function() game.switchState(MainMenuState()) end)
	end
end
