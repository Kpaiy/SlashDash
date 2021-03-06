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
    -- projectile.new(400, 400, math.pi, projectile.types.normal)
    -- enemy.new(600, 400, enemy.types.bat)
    -- enemy.new(1000, 200, enemy.types.archer)
end

function love.update(dt)
	deltaTime = dt
	player.update(dt)
    projectile.updateAll(dt)
    enemy.updateAll(dt)

    -- if no enemies left, spawn 10 more
    if #enemy == 0 then
        for i = 1, 7 do
            game.spawnEnemy()
        end
    end
end

function love.draw()
	-- love.graphics.draw(image, quad, 50, 50, 0, 1, 1)
    
    love.graphics.setColor(255, 255, 255, 255)

	terrain.drawAll()
    projectile.drawAll()
    enemy.drawAll()
	player.draw()
    game.hud()
end
