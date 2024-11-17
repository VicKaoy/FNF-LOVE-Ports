local TVScreen = require "tvscreen"

local isFH = Project.FHversion ~= nil

local cmin, csec

function create()
	if not isFH then
		local room = Sprite(0, -700, paths.getImage(SCRIPT_PATH .. "roombg"))
		self:add(room)
		local clockface = Sprite(2200, 150, paths.getImage(SCRIPT_PATH .. "clock/CLOCK"))
		self:add(clockface)
		local clockminute = Sprite(2200, 150, paths.getImage(SCRIPT_PATH .. "clock/minutes"))
		self:add(clockminute)
		local clocksecond = Sprite(2200, 150, paths.getImage(SCRIPT_PATH .. "clock/seconds"))
		self:add(clocksecond)
		cmin, csec = clockminute, clocksecond

		self.camZoom = 0.7
		self.boyfriendPos = {x = 1870, y = 480}
		self.gfPos = {x = 1450, y = 400}
		self.dadPos = {x = 700, y = 100}
	else
		cmin, csec = clockminute, clocksecond
	end

	cmin:centerOrigin()
	csec:centerOrigin()

	cmin.origin.y = cmin.origin.y - 5
	csec.origin.y = cmin.origin.y

	game.camera.simple = false

	local scrn = TVScreen(1306, 78)
	local shader = Shader("hsb")

	shader.hue = 0.1
	shader.saturation = -0.35
	shader.brightness = 0.0

	scrn.shader = shader:get()

	self:add(scrn)
end

function postUpdate(dt)
	cmin.angle = ((PlayState.conductor.time / 1000) / game.sound.music:getDuration()) * 360
	csec.angle = cmin.angle * 60
end