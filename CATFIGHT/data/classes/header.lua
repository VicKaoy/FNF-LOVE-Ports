local Header = Text:extend("Header")

function Header:update(dt)
	Header.super.update(self, dt)
	self.time = (self.time or 0) + dt
end

function Header:__render(camera)
	love.graphics.push("all")

	local mode = self.antialiasing and "linear" or "nearest"
	local min, mag, anisotropy = self.font:getFilter()
	self.font:setFilter(mode, mode, anisotropy)

	local rad, sx, sy, ox, oy = math.rad(self.angle),
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	local content, align, outline = self.content, self.alignment, self.outline
	local width, color = self.limit or self:getWidth()

	love.graphics.setShader(self.shader); love.graphics.setBlendMode(self.blend)
	love.graphics.setFont(self.font)

	local tw = self:getWidth()
	local ss = self.scrollSpeed or 50
	local so = ((self.time or 0) * ss) % tw

	for xPos = -so, camera.width, tw do
		local x = xPos + self.x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x)
		local y = self.y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

		love.graphics.setColor(Color.vec4(self.color, self.alpha))
		love.graphics.printf(content, x, y, width, align, rad, sx, sy, ox, oy)
	end

	self.font:setFilter(min, mag, anisotropy)
	love.graphics.pop()
end

return Header