local TVScreen = Object:extend("TVScreen")

function TVScreen:new(x, y, framerate)
	TVScreen.super.new(self, x, y)

	self.canvas = love.graphics.newCanvas(748, 421)
	self.canvas2 = love.graphics.newCanvas(748, 421)

	self.width, self.height = 748, 421

	self.copyFrom = game.camera.canvas

	self.framerate = 1 / 50
	self.elapsed = 0
end

function TVScreen:update(dt)
	self.elapsed = self.elapsed + dt
	if self.elapsed >= self.framerate then
		self.elapsed = 0
		self.canvas, self.canvas2 = self.canvas2, self.canvas

		self.canvas:renderTo(function()
			love.graphics.push("all")
			love.graphics.clear()
			local w, h = self.copyFrom:getDimensions()
			love.graphics.draw(self.copyFrom, 0, 0, 0, self.width / w, self.height / h)
			love.graphics.pop()
		end)
	end
	TVScreen.super.update(self, dt)
end

function TVScreen:__render(camera)
	love.graphics.push("all")

	local x, y, rad, sx, sy, ox, oy = self.x, self.y, math.rad(self.angle),
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	x, y = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	love.graphics.setBlendMode(self.blend)
	love.graphics.setColor(Color.vec4(self.color, self.alpha))
	love.graphics.setShader(self.shader)

	love.graphics.stencil(function()
		for i = 0, self.height, 4 do
			love.graphics.rectangle("fill", x - ox, y - oy + i, self.width, 2)
		end
	end, "replace", 1)

	love.graphics.setStencilTest("equal", 1)
	love.graphics.draw(self.canvas2, x, y, rad, sx, sy, ox, oy)
	love.graphics.setStencilTest()

	love.graphics.stencil(function()
		for i = 2, self.height, 4 do
			love.graphics.rectangle("fill", x - ox, y - oy + i, self.width, 2)
		end
	end, "replace", 1)

	love.graphics.setStencilTest("equal", 1)
	love.graphics.draw(self.canvas, x, y, rad, sx, sy, ox, oy)
	love.graphics.setStencilTest()

	love.graphics.pop()
end

function TVScreen:destroy()
	TVScreen.super.destroy(self)
	self.canvas:release()
	self.canvas2:release()
end

return TVScreen
