local Transition = TransitionData:extend("Transition")
Transition.color = Color.fromHEX(0x291D2B)

function Transition:new()
	Transition.super.new(self, 0.42)
end

function Transition:draw()
	love.graphics.push("all")
	local progress = self.timer / self.duration
	if self.status == "in" then progress = -progress + 1 end

	local color = Transition.color
	love.graphics.setColor(color[1], color[2], color[3], 1)

	local topBoxY = -60 + (60 * progress)
	local bottomBoxY = self.height - (60 * progress)

	love.graphics.rectangle("fill", 0, topBoxY, self.width, 60)
	love.graphics.rectangle("fill", 0, bottomBoxY, self.width, 60)

	love.graphics.setColor(color[1], color[2], color[3], progress)
	love.graphics.rectangle("fill", 0, 0, self.width, self.height)
	love.graphics.pop()
end

return Transition
