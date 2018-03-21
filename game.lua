game = {
	settings = {},
	constants = {
		tileWidth = 25,
		gradientTolerance = 1,	-- the max height difference between tiles
		gravity = 1000,
        spawnDistance = 250, -- minimum distance of newly spawned enemies from player's center
        spawnHealth = 5, -- starting health of the player
        topHud = 3, -- how to portion the screen for each side of the top of the hud to take up
        botHud = 4, -- how to portion the lower segment of the hud
        hudOpacity = 50,

        comboMax = 5.0, -- maximum combo multiplier
        comboDecay = 0.10, -- combo decay scalar
        decayExponent = 0.5, -- combo exponent for decay

        comboHit = 1.00, -- amount of multiplier to remove when player is hurt
        comboDash = 0.20, -- amount to give for every enemy hurt by dash
        comboSlash = 0.05, -- amount to give for every enemy hurt by slash
        comboDeflect = 0.05, -- amount to give for every projectile deflected
        comboProjectile = 0.3, -- amount to give for every enemy hit by a projectile
        comboKill = 0.30 -- amount to give for every enemy killed
	},
	resources = {
		graphics = {
            ui = {},
        }
	},

    ui = {}
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

    game.resources.graphics.ui.heart = love.graphics.newImage("resources/graphics/ui/heart.png")
    game.resources.graphics.ui.dash = love.graphics.newImage("resources/graphics/ui/dash.png")
    game.resources.graphics.ui.noDash = love.graphics.newImage("resources/graphics/ui/nodash.png")
    game.resources.graphics.ui.star = love.graphics.newImage("resources/graphics/ui/star.png")

    terrain.init()

    w, h = game.resources.graphics.ui.heart:getDimensions()
    game.ui.heart = love.graphics.newQuad(0, 0, w, h, w, h)
    w, h = game.resources.graphics.ui.dash:getDimensions()
    game.ui.dash = love.graphics.newQuad(0, 0, w, h, w, h)
    w, h = game.resources.graphics.ui.noDash:getDimensions()
    game.ui.noDash = love.graphics.newQuad(0, 0, w, h, w, h)
    w, h = game.resources.graphics.ui.star:getDimensions()
    game.ui.star = love.graphics.newQuad(0, 0, w, h, w, h)
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
    eLTop = game.settings.resolution.x / game.constants.topHud

    -- top left
    love.graphics.setColor(0, 0, 0, game.constants.hudOpacity)
    love.graphics.rectangle("fill", 0, 0, eLTop, 50)
    love.graphics.setColor(255, 255, 255, 255)
    w, h = game.resources.graphics.ui.heart:getDimensions()
    love.graphics.draw(game.resources.graphics.ui.heart, game.ui.heart, 10, 25 - h/2)

    -- health bar
    love.graphics.setColor(180, 0, 75, 255)
    love.graphics.setColor( 90, 0, 37, 255)
    love.graphics.rectangle("fill", w + 20, 35/2, eLTop - w - 40, 15)
    healthP = player.health / game.constants.spawnHealth
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.rectangle("fill", w + 20, 35/2, (eLTop - w - 40) * healthP, 15)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", w + 20, 35/2, eLTop - w - 40, 15)
    
    -- top right
    love.graphics.setColor(0, 0, 0, game.constants.hudOpacity)
    love.graphics.rectangle("fill", game.settings.resolution.x - eLTop, 0, eLTop, 50)
    -- combo bar
    comboP = (player.combo - 1) / (game.constants.comboMax - 1)

    -- get combo colour
    h = (1 - comboP) * 300 / 60 - 1
    x = 1 - math.abs((h % 2) - 1)
    c = 1
    r = 0
    g = 0
    b = 0
    if -1 <= h and h <= 0 then
        r = c
        b = x
    elseif 0 <= h and h <= 1 then
        r = c
        g = x
    elseif 1 <= h and h <= 2 then
        r = x
        g = c
    elseif 2 <= h and h <= 3 then
        g = c
        b = x
    elseif 3 <= h and h <= 4 then
        g = x
        b = c
    elseif 4 <= h and h <= 5 then
        r = x
        b = c
    elseif 5 <= h and h <= 6 then
        r = c
        b = x
    end

    r = r * 255
    g = g * 255
    b = b * 255
    love.graphics.setColor(r, g, b, 255)
    w, h = game.resources.graphics.ui.heart:getDimensions()
    love.graphics.draw(game.resources.graphics.ui.star, game.ui.star, game.settings.resolution.x - w - 10, 25 - h/2)


    love.graphics.rectangle("fill", game.settings.resolution.x - w - 20 - (eLTop - w - 40) * comboP, 35/2, (eLTop - w - 40) * comboP, 15)
    -- love.graphics.rectangle("fill", game.settings.resolution.x - w - 20 - (eLTop - w - 40) * 0.5, 35/2, (eLTop - w - 40) * 0.5, 15)
    
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", game.settings.resolution.x - w - 20 - (eLTop - w - 40), 35/2, eLTop - w - 40, 15)

    -- bottom left
    eLBot = game.settings.resolution.x / game.constants.botHud
    love.graphics.setColor(0, 0, 0, game.constants.hudOpacity)
    love.graphics.rectangle("fill", 0, 50, eLBot, 50)

    -- cooldown radial
    cd = player.coolDowns.dash / player.dashStats.coolDown * 2*math.pi
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.arc("fill", 28, 75, 18, -math.pi/2, 2*math.pi - cd - math.pi/2)
    love.graphics.setColor(150, 0, 0, 255)
    love.graphics.arc("fill", 28, 75, 15, -math.pi/2, 2*math.pi - cd - math.pi/2)

	if player.dashes == 3 then
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.setLineWidth(3)
		love.graphics.arc("line", 28, 75, 18, -math.pi/2, 1.5*math.pi)
	end

    -- ability graphics
	love.graphics.setColor(255, 255, 255, 255)
    w, h = game.resources.graphics.ui.dash:getDimensions()
    if player.dashes >= 1 then
        love.graphics.draw(game.resources.graphics.ui.dash, game.ui.dash, 75, 75 - h/2)
    else
        love.graphics.draw(game.resources.graphics.ui.noDash, game.ui.dash, 75, 75 - h/2)
    end
    if player.dashes >= 2 then
        love.graphics.draw(game.resources.graphics.ui.dash, game.ui.dash, 75 + w, 75 - h/2)
    else
        love.graphics.draw(game.resources.graphics.ui.noDash, game.ui.dash, 75 + w, 75 - h/2)
    end
    if player.dashes >= 3 then
        love.graphics.draw(game.resources.graphics.ui.dash, game.ui.dash, 75 + 2*w, 75 - h/2)
    else
        love.graphics.draw(game.resources.graphics.ui.noDash, game.ui.dash, 75 + 2*w, 75 - h/2)
    end
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
