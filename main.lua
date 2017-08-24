require("game")
require("terrain")

function love.load()
	game.init()
	love.graphics.setDefaultFilter("nearest", "nearest")
	-- image = love.graphics.newImage("resources/graphics/dirt.png")
	-- image:setWrap("repeat")

	-- w, h = image:getDimensions()
	-- quad = love.graphics.newQuad(0, 0, 100, 25, w, h)

	terrain.new(0, 0, 100, 100, game.resources.graphics.dirt)
end

function love.update()

end

function love.draw()
	-- love.graphics.draw(image, quad, 50, 50, 0, 1, 1)
	terrain.drawAll()
end
