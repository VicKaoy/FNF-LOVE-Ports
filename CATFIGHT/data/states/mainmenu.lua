local confirmed, p = false, "menus/mainmenu/"

local start, options, startovl, optionsovl
local selection, prevselection, selected = 0, 0, false

local ssx, ssy, osx, osy
local mods

local trans = require "transition"
game.discardTransition()
game.getState().transIn = trans()
game.getState().transOut = trans()

local function hover(s)
	if selected then return end

	game.sound.play(paths.getSound("scrollMenu"))
	Tween.cancelTweensOf(optionsovl)
	Tween.cancelTweensOf(startovl)

	Tween.tween(optionsovl, {alpha = s}, 0.2)
	Tween.tween(startovl, {alpha = 1 - s}, 0.2)

	if s == 0 then
		Tween.cancelTweensOf(start)
		Tween.tween(start.scale, {x = ssx + 0.06, y = ssy + 0.06}, 0.05, {
			onComplete = function()
			Tween.tween(start.scale, {x = ssx, y = ssy}, 0.2)
		end})
	else
		Tween.cancelTweensOf(options)
		Tween.tween(options.scale, {x = osx + 0.06, y = osy + 0.06}, 0.05, {
			onComplete = function()
			Tween.tween(options.scale, {x = osx, y = osy}, 0.2)
		end})
	end
end

local function enter(s)
	if selected then return end
	selected = true
	Tween.cancelTweensOf(start)
	Tween.cancelTweensOf(options)

	Tween.cancelTweensOf(optionsovl)
	Tween.cancelTweensOf(startovl)

	Tween.tween(optionsovl, {alpha = s}, 0.2)
	Tween.tween(startovl, {alpha = 1 - s}, 0.2)

	game.sound.play(paths.getSound("confirmMenu"))
	if s == 0 then
		Tween.cancelTweensOf(start)
		Tween.tween(start.scale, {x = ssx + 0.06, y = ssy + 0.06}, 0.2)
		Timer():start(1, function() game.switchState(FreeplayState()) end)
	else
		Tween.cancelTweensOf(options)
		Tween.tween(options.scale, {x = osx + 0.06, y = osy + 0.06}, 0.2)

		Timer():start(0.5, function()
			local options = Options(true, function()
				selected = false
				if mods then state:add(mods) end

				if Discord then
					Discord.changePresence({details = "In the Menus", state = "Main Menu"})
				end
				Tween.cancelTweensOf(options)
				Tween.tween(options.scale, {x = osx, y = osy}, 0.2)
			end)
			options:setScrollFactor()
			options:screenCenter()
			state:add(options)
			if mods then state:remove(mods) end
		end)
	end
end

function create()
	local splash = Sprite(0, 0, paths.getImage(p .. "bg_mm"))
	splash:setGraphicSize(1280)
	splash:updateHitbox()
	state:add(splash)

	local coffeebg = Sprite(0, 0, paths.getImage(p .. "side_mm"))
	coffeebg:setGraphicSize(coffeebg.width / 1.5)
	coffeebg:updateHitbox()
	coffeebg.x = game.width - coffeebg.width
	state:add(coffeebg)

	local anim = Sprite(768, 158)
	anim:setFrames(paths.getAtlas(p .. "coffee"))
	anim:addAnimByPrefix("anim", "coffee", 24, true)
	anim:play("anim")
	anim:setGraphicSize(anim.width / 1.5)
	anim:updateHitbox()
	state:add(anim)

	start = Sprite(382, 24, paths.getImage(p .. "start"))
	start:setGraphicSize(256)
	ssx, ssy = start.scale.x, start.scale.y
	start:updateHitbox()
	state:add(start)

	options = Sprite(75, 325, paths.getImage(p .. "optionscard"))
	options:setGraphicSize(336)
	options:updateHitbox()
	osx, osy = options.scale.x, options.scale.y
	state:add(options)

	startovl = Sprite(0, 0)
	startovl:setFrames(paths.getAtlas(p .. "start_select"))
	startovl:addAnimByPrefix("anim", "start_selected", 24, true)
	startovl:play("anim")
	startovl:setGraphicSize(720)
	startovl:updateHitbox()
	state:add(startovl)

	optionsovl = Sprite(0, 0)
	optionsovl:setFrames(paths.getAtlas(p .. "options_select"))
	optionsovl:addAnimByPrefix("anim", "options_selected", 24, true)
	optionsovl:play("anim")
	optionsovl:setGraphicSize(720)
	optionsovl:updateHitbox()
	state:add(optionsovl)

	if love.system.getDevice() == "Desktop" then
		Discord.changePresence({details = "In the Menus", state = "Main Menu"})
	elseif love.system.getDevice() == "Mobile" then
		mods = VirtualPad("tab", game.width - 134, game.height - 134, 134, 134, Color.fromHEX(0x281C2A))
		mods.line.color = Color.fromHEX(0xFC7639)
		state:add(mods)
	end

	state.versionText.font = paths.getFont("FranklinBold.ttf", 18)
	state.versionText.content = "FNF LÖVE " .. state.versionText.content:upper()
	state.versionText:__updateDimension()
	state.versionText:setOutline()
	state.versionText.y = 8
	state.versionText.x = game.width - state.versionText.width - 8

	hover(0)

	return Event_Cancel
end

function update(dt)
	if love.system.getDevice() == "Mobile" then
		local jp = game.mouse.justPressed
		local os, ox = game.mouse.overlaps(start), game.mouse.overlaps(options)
		if os and selection ~= 0 then
			selection = 0
			if not jp then hover(0) end
		elseif ox and selection ~= 1 then
			selection = 1
			if not jp then hover(1) end
		end

		if jp and (os or ox) then
			if ox then selection = 1 elseif os then selection = 0 end
			enter(selection)
		end
	else
		if controls:pressed("ui_up") or controls:pressed("ui_down") then
			selection = (selection + 1) % 2
			hover(selection)
		end
		if controls:pressed("accept") then
			enter(selection)
		end
	end

	if controls:pressed("back") and not selected then
		game.switchState(TitleState())
		game.sound.play(paths.getSound("cancelMenu"))
		selected = true
	elseif controls:pressed("pick_mods") and not selected then
		local state = ModsState()
		state.transIn, state.transOut = trans(), trans()
		game.switchState(state)
		selected = true
	end
end
