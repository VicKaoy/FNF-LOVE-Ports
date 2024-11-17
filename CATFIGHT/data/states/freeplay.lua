local Header = require "header"
local confirmed, select, p = false, 0, "menus/songs/"

local mix, underlay, overlay, blacat, silk

local trans = require "transition"
game.discardTransition()
game.getState().transIn = trans()
game.getState().transOut = trans()

local function updateAnims()
	local anim = select == 0 and "silly" or "fucked"

	game.sound.play(paths.getSound("scrollMenu"))

	blacat:play(anim)
	silk:play(anim)
	underlay:play(anim)
	overlay:play(anim)

	mix:loadTexture(paths.getImage(p .. anim .. "_mix"))
	mix:updateHitbox()
	mix:screenCenter("x")
	mix.y = game.height - mix.height + 8
	Tween.cancelTweensOf(mix)
	Tween.tween(mix, {y = mix.y - 8}, 0.6)

	overlay:updateHitbox()
	overlay:screenCenter("x")
	overlay.y = game.height - overlay.height - 50

	underlay:updateHitbox()
	underlay:screenCenter("x")
	underlay.y = game.height - underlay.height
end

function create()
	local bg = Sprite(0, 0, paths.getImage(p .. "bg_mix"))
	bg:setGraphicSize(1280)
	bg:updateHitbox()
	state:add(bg)

	blacat = Sprite(0, 0)
	blacat:setFrames(paths.getAtlas(p .. "animated/black-cat"))
	blacat:addAnimByPrefix("silly", "flowers0", 24, true)
	blacat:addAnimByPrefix("fucked", "flower0", 24, true)
	blacat:play("silly")
	blacat:setGraphicSize(blacat.width / 1.5)
	blacat:updateHitbox()
	state:add(blacat)

	silk = Sprite(620, 0)
	silk:setFrames(paths.getAtlas(p .. "animated/silk"))
	silk:addAnimByPrefix("silly", "flower0", 24, true)
	silk:addAnimByPrefix("fucked", "flowers0", 24, true)
	silk:play("silly")
	silk:setGraphicSize(silk.width / 1.5)
	silk:updateHitbox()
	state:add(silk)

	local colune = Sprite(0, 0, paths.getImage(p .. "collume"))
	colune:setGraphicSize(colune.width / 1.5)
	colune:updateHitbox()
	colune:screenCenter("x")
	state:add(colune)

	underlay = Sprite(0, 0)
	underlay:setFrames(paths.getAtlas(p .. "animated/underlays"))
	underlay:addAnimByPrefix("silly", "cloud", 24, true)
	underlay:addAnimByPrefix("fucked", "wave", 24, true)
	underlay:play("silly")
	underlay:setGraphicSize(underlay.width / 1.5)
	underlay:updateHitbox()
	underlay:screenCenter("x")
	underlay.y = game.height - underlay.height
	state:add(underlay)

	mix = Sprite(0, 0, paths.getImage(p .. "silly_mix"))
	mix:setGraphicSize(mix.width / 1.5)
	mix:updateHitbox()
	mix:screenCenter("x")
	mix.y = game.height - mix.height
	state:add(mix)

	overlay = Sprite(0, 0)
	overlay:setFrames(paths.getAtlas(p .. "animated/overlays"))
	overlay:addAnimByPrefix("silly", "flowers", 24, true)
	overlay:addAnimByPrefix("fucked", "bolts", 24, true)
	overlay:play("silly")
	overlay:setGraphicSize(overlay.width / 1.5)
	overlay:updateHitbox()
	overlay:screenCenter("x")
	overlay.y = game.height - overlay.height - 50
	state:add(overlay)

	local headerbg = Graphic(0, 0, game.width, 40, Color.fromHEX(0x1D152A))
	state:add(headerbg)
	local header = Header(0, 0, "SELECT YOUR MIX ", paths.getFont("FranklinBold.ttf", 30))
	state:add(header)

	if love.system.getDevice() == "Mobile" then
		state:add(VirtualPad("left", 0, 0, game.width / 4, game.height, false))
		state:add(VirtualPad("right", game.width - game.width / 4, 0, game.width / 4, game.height, false))
		state:add(VirtualPad("return", game.width / 4, 0, game.width / 2, game.height, false))
	end

	return Event_Cancel
end

function update(dt)
	if not confirmed and (controls:pressed("ui_left") or controls:pressed("ui_right")) then
		select = (select + 1) % 2
		updateAnims()
	end

	if controls:pressed("accept") and not confirmed then
		confirmed = true
		game.sound.music:fade(0.4, ClientPrefs.data.menuMusicVolume / 100, 0)
		game.sound.play(paths.getSound("confirmMenu"))
		Tween.tween(game.camera, {alpha = 0, zoom = 1.21}, 1)
		Timer():start(1.2, function()
			game.switchState(PlayState(false,
				"mrow-" .. (select == 0 and "silly" or "fucked"), "Normal"))
		end)
	elseif controls:pressed("back") and not confirmed then
		confirmed = true
		game.switchState(MainMenuState())
		game.sound.play(paths.getSound("cancelMenu"))
	end
end
