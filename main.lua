require("game")
require("terrain")
require("player")
require("util")
require("projectile")

deltaTime = 0

function love.load()
	game.init()
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- terrain.new(0, 0, 100, 100, game.resources.graphics.dirt)
	terrain.generateLevel()
    projectile.new(900, 400, -1, projectile.types.normal)
end

function love.update(dt)
	deltaTime = dt
	player.update(dt)
    projectile.updateAll(dt)
end

function love.draw()
	-- love.graphics.draw(image, quad, 50, 50, 0, 1, 1)
	terrain.drawAll()
    projectile.drawAll()
	player.draw()
end
