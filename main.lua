require("game")
require("terrain")
require("player")
require("util")

function love.load()
	game.init()
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- terrain.new(0, 0, 100, 100, game.resources.graphics.dirt)
	terrain.generateLevel()
end

function love.update(dt)
	player.update(dt)
end

function love.draw()
	-- love.graphics.draw(image, quad, 50, 50, 0, 1, 1)
	terrain.drawAll()
	player.draw()
end
