game = {
	settings = {},
	constants = {
		tileWidth = 25,
		gradientTolerance = 1,	-- the max height difference between tiles
		gravity = 1000,
        spawnDistance = 250, -- minimum distance of newly spawned enemies from player's center
        spawnHealth = 5, -- starting health of the player
	},
	resources = {
		graphics = {}
	}
}

game.settings.resolution = {
	x = 1600,
	y = 900
}
game.settings.title = "Slash Dash"

function game.init()
	math.randomseed(os.time())

	love.window.setTitle(game.settings.title)
	love.window.setMode(game.settings.resolution.x, game.settings.resolution.y)
	love.graphics.setDefaultFilter("nearest", "nearest")

	game.resources.graphics.dirt = love.graphics.newImage("resources/graphics/dirt.png")
    game.resources.graphics.background = love.graphics.newImage("resources/graphics/backdrop.png")

    terrain.init()
end

-- spawns a random enemy at a random position not too close to player
function game.spawnEnemy()
    -- pick type of enemy to spawn
    r = math.random(1, #enemy.types)
    type = enemy.types[r]

    -- if flying type, pick random x and y
    if type.flying then
        ::flyRetry::
        x = math.random(0, game.settings.resolution.x - type.size)
        y = math.random(0, game.settings.resolution.y - type.size)

        -- check if not too close to player
        if util.distance(x + type.size/2, y + type.size/2, player.position.x + player.width/2, 
            player.position.y + player.height/2) <= game.constants.spawnDistance then
            goto flyRetry
        end

        -- check for collision with terrain
        for i = 1, #terrain do
            if util.intersects(x, y, type.size, type.size, terrain[i].position.x, terrain[i].position.y,
                terrain[i].width, terrain[i].height) then
                goto flyRetry
            end
        end

        -- all good, spawn enemy
        enemy.new(x, y, type)
    else
        -- for ground types, pick x only and move up until no collision
        ::groundRetry::

        x = math.random(0, game.settings.resolution.x - type.size)
        y = game.settings.resolution.y - 1

        -- check terrain collisions
        for i = 1, #terrain do
            if util.intersects(x, y, type.size, type.size, terrain[i].position.x, terrain[i].position.y,
                terrain[i].width, terrain[i].height) then
                y = terrain[i].position.y - type.size
            end
        end

        -- check distance to player
        if util.distance(x + type.size/2, y + type.size/2, player.position.x + player.width/2, 
            player.position.y + player.height/2) <= game.constants.spawnDistance then
            goto groundRetry
        end

        -- all good, spawn
        enemy.new(x, y, type)
    end
end

-- draw the hud onto the screen
function game.hud()

end

function love.keypressed(key)
	player.key(key)
end

function love.mousepressed(x ,y, button, istouch)
	if button == 1 then
		if player.aiming then
			player.aiming = false
		else
			player.slash()
		end
	end
	if button == 2 then
		player.aiming = true
	end
end
