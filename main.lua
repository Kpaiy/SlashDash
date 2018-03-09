require("game")
require("terrain")
require("player")
require("util")
require("projectile")
require("enemy")

deltaTime = 0

function love.load()
	game.init()
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- terrain.new(0, 0, 100, 100, game.resources.graphics.dirt)
	terrain.generateLevel()
    projectile.new(900, 400, math.pi, projectile.types.normal)
    enemy.new(1500, 400, enemy.types.bat)
end

function love.update(dt)
	deltaTime = dt
	player.update(dt)
    projectile.updateAll(dt)
    enemy.updateAll(dt)
end

function love.draw()
	-- love.graphics.draw(image, quad, 50, 50, 0, 1, 1)
	terrain.drawAll()
    projectile.drawAll()
    enemy.drawAll()
	player.draw()
end
