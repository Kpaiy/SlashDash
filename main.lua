require("game")
require("terrain")

function love.load()
	game.init()
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- terrain.new(0, 0, 100, 100, game.resources.graphics.dirt)
	terrain.generateLevel()
end

function love.update()

end

function love.draw()
	-- love.graphics.draw(image, quad, 50, 50, 0, 1, 1)
	terrain.drawAll()
end
