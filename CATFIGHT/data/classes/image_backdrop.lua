local stencilSprite, stencilX, stencilY = nil, 0, 0

local function stencil()
	if stencilSprite then
		love.graphics.push()
		love.graphics.translate(
			stencilX + stencilSprite.clipRect.x + stencilSprite.clipRect.width / 2,
			stencilY + stencilSprite.clipRect.y + stencilSprite.clipRect.height / 2
		)
		love.graphics.rotate(stencilSprite.angle)
		love.graphics.translate(-stencilSprite.clipRect.width / 2, -stencilSprite.clipRect.height / 2)
		love.graphics.rectangle(
			"fill",
			-stencilSprite.width / 2,
			-stencilSprite.height / 2,
			stencilSprite.clipRect.width,
			stencilSprite.clipRect.height
		)
		love.graphics.pop()
	end
end

local function mod(val, step, tar, max)
	return val - math[max and "ceil" or "floor"]((val - tar) / step) * step
end

local Backdrop = Sprite:extend("Backdrop")

function Backdrop:new(texture, repeatAxes, spacingX, spacingY)
	Backdrop.super.new(self, 0, 0, texture)

	self.repeatAxes = repeatAxes or "xy"
	self.spacingX = spacingX or 0
	self.spacingY = spacingY or 0
end

function Backdrop:_isOnScreen()
	return true
end

function Backdrop:_getBoundary()
	return 0, 0, 0, 0, 1, 1, 0, 0
end

function Backdrop:__render(camera)
	love.graphics.push("all")

	local mode = self.antialiasing and "linear" or "nearest"
	local min, mag, anisotropy = self.texture:getFilter()
	self.texture:setFilter(mode, mode, anisotropy)

	local f = self:getCurrentFrame()

	local x, y, rad, sx, sy, ox, oy, spx, spy, fw, fh =
		self.x, self.y, math.rad(self.angle),
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y,
		self.spacingX * self.scale.x, self.spacingY * self.scale.y

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	x, y = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	if f then ox, oy = ox + f.offset.x, oy + f.offset.y end

	fw, fh = self:getFrameDimensions()
	fw, fh = fw * sx, fh * sy

	local tsx, tsy = spx + fw, spy + fh
	local tx, ty, haveX, haveY = 1, 1, self.repeatAxes:find("x"), self.repeatAxes:find("y")

	if haveY then
		local t, b = mod(y + fh, tsy, 0) - fh, mod(y, tsy, camera.height, true) + tsy
		ty, y = math.round((b - t) / tsy), mod(y + fh, fh + spy, 0) - fh
	end
	if haveX then
		local l, r = mod(x + fw, tsx, 0) - fw, mod(x, tsx, camera.width, true) + tsx
		tx, x = math.round((r - l) / tsx), mod(x + fw, fw + spx, 0) - fw
	end

	love.graphics.setShader(self.shader)
	love.graphics.setBlendMode(self.blend)
	love.graphics.setColor(Color.vec4(self.color, self.alpha))

	for tlx = 0, tx do
		for tly = 0, ty do
			local xx, yy = x + tsx * tlx, y + tsy * tly
			if self.clipRect then
				stencilSprite, stencilX, stencilY = self, xx, yy
				love.graphics.stencil(stencil, "replace", 1, false)
				love.graphics.setStencilTest("greater", 0)
			end

			if f then
				love.graphics.draw(self.texture, f.quad, xx, yy, rad, sx, sy, ox, oy)
			else
				love.graphics.draw(self.texture, xx, yy, rad, sx, sy, ox, oy)
			end
		end
	end

	love.graphics.setStencilTest()
	self.texture:setFilter(min, mag, anisotropy)

	love.graphics.pop()
end

return Backdrop
