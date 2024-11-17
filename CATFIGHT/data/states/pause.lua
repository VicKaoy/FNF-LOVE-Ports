local PauseSubstate = Substate:extend("PauseSubstate")

function PauseSubstate:new(cutscene)
	PauseSubstate.super.new(self)
	self.menuItems = {"RESUME", "RESTART", "EXIT"}

	self:loadMusic()

	self.bg = Sprite(0, 0, paths.getImage("menus/menuPause"))
	self.bg.alpha = 0
	self.bg:setScrollFactor()
	self:add(self.bg)

	self.menuList = SpriteGroup(0, 50)
	self:add(self.menuList)

	self.curSelected = 1
	self.selected = false

	local size = (game.height - 50) / 3
	local font = paths.getFont("GILLUBCD.TTF", size)

	for i = 1, #self.menuItems do
		local item = Text(0, (i - 1) * size, self.menuItems[i], font)
		item.height = size
		self.menuList:add(item)
	end

	local headerbg = Graphic(0, 0, game.width, 46, Color.fromHEX(0x1D152A))
	self:add(headerbg)
	local headertxt = Text(30, 2, PlayState.SONG.song:upper() .. " | REWINDS: " .. GameOverSubstate.deaths,
		paths.getFont("FranklinBold.ttf", 30))
	self:add(headertxt)

	self:changeSelection(0)
end

function PauseSubstate:loadMusic()
	self.curPauseMusic = "mod"
	self.music = game.sound.load(paths.getMusic('pause/' .. self.curPauseMusic))
end

function PauseSubstate:enter()
	self.music:play(0, true)
	self.music:fade(6, 0, ClientPrefs.data.menuMusicVolume / 100)

	Tween.tween(self.bg, {alpha = 0.86}, 0.4, {ease = Ease.quartInOut})
end

function PauseSubstate:selectOption(daChoice)
	self.selected = true
	switch(tostring(daChoice):lower(), {
		["resume"] = function()
			Tween.tween(self.menuList, {x = 1280}, 0.3, {ease = "cubeIn"})
			Tween.tween(self.bg, {alpha = 0}, 0.24, {ease = "cubeIn"})
			Timer():start(0.3, function() self:close() end)
		end,
		["restart"] = function()
			game.resetState(true)
		end,
		["exit"] = function()
			game.sound.music:setPitch(1)
			self.music:stop()
			util.playMenuMusic()
			PlayState.chartingMode = false
			PlayState.startPos = 0

			game.switchState(FreeplayState())
			GameOverSubstate.deaths = 0
			PlayState.canFadeInReceptors = true
		end,
		default = function() print("missing option") end
	})
end

function PauseSubstate:update(dt)
	PauseSubstate.super.update(self, dt)

	if love.system.getDevice() == "Mobile" then
		if self.selected then return end
		local overlaps = false
		for i, m in ipairs(self.menuList.members) do
			if game.mouse.overlaps(m, self.parent.camOther) then
				overlaps = true
				if i ~= self.curSelected then
					self:changeSelection(i, true)
				end
				break
			end
		end
		if game.mouse.justPressed and overlaps then
			self:selectOption(self.menuList.members[self.curSelected].content)
		end
	else
		if controls:pressed("ui_up") then
			self:changeSelection(-1)
		elseif controls:pressed("ui_down") then
			self:changeSelection(1)
		elseif controls:pressed("accept") then
			self:selectOption(self.menuList.members[self.curSelected].content)
		end
	end

	for i, m in ipairs(self.menuList.members) do
		m.x = util.coolLerp(m.x, game.width - m.width, 16, dt)
		if self.curSelected ~= i then
			m.x = util.coolLerp(m.x, m.x + 170, 16, dt)
		end
	end
end

function PauseSubstate:changeSelection(c, direct)
	c = c or 0
	self.curSelected = direct and c or self.curSelected + c
	if self.curSelected > 3 then
		if c > 0 then self.curSelected = 1 else self.curSelected = 3 end
	end
	game.sound.play(paths.getSound("scrollMenu"))

	for i, m in ipairs(self.menuList.members) do
		if self.curSelected ~= i then
			m.color = Color.WHITE
		else
			m.color = Color.fromHEX(0xE26132)
		end
	end
end

function PauseSubstate:close()
	self.music:stop()
	self.music:destroy()

	PauseSubstate.super.close(self)
end

return PauseSubstate
