enemy = {
    types = {
        bat = {
            flying = true,
            melee = true,
            speed = 50,
            health = 2,
            states = {"move"},
            startState = "move",
            color = {170, 0 ,170},
            size = 15,
            thinks = false,
            thinkTime = -1,
            clips = true,  -- true if can collide with terrain

            fireRate = -1,
            bullet = projectile.types.normal,
        },
        archer = {
            flying = false,
            melee = false,
            speed = 300,
            health = 3,
            states = {"move", "shoot"},
            startState = "move",
            color = {0, 170, 0},
            size = 20,
            thinks = true,
            thinkTime = 3,
            clips = true,

            fireRate = 1,
            bullet = projectile.types.normal,
        },
    },
    jitter = 2,
    jitterTime = 0.5,
    jumpStrength = 300,
    friction = 10,
    airControl = 2.5
}

enemy.types = {
    enemy.types.bat,
    enemy.types.archer,
}

function enemy.new(x, y, type)
    enemy[#enemy + 1] = {
        flying = type.flying,
        melee = type.melee,
        speed = type.speed,
        health = type.health,
        states = type.states,
        color = type.color,
        size = type.size,
        thinks = type.thinks,
        thinkTime = type.thinkTime,
        clips = type.clips,

        fireRate = type.fireRate,
        bullet = type.bullet,

        state = type.startState,
        thinkCounter = type.thinkTime,
        fireCounter = 0,

        onGround = false,

        jitter = 0,
        
        position = {
            x = x,
            y = y,
        },
        velocity = {
            x = 0,
            y = 0,
        },
        onGround = false,
    }
end

-- returns true if the enemy is dead
function enemy.update(i, dt)
    if enemy[i].health <= 0 then
        return true
    end

    -- pain jitter tracking
    if enemy[i].jitter > 0 then
        enemy[i].jitter = enemy[i].jitter - dt
    end

    -- if enemy thinks, calculate thinks
    if enemy[i].thinks then
        enemy[i].thinkCounter = enemy[i].thinkCounter - dt
        if enemy[i].thinkCounter <= 0 then
            -- think if the cooldown is ready
            r = math.random(1, #enemy[i].states)
            enemy[i].state = enemy[i].states[r]
            
            enemy[i].thinkCounter = enemy[i].thinkTime
        end
    end

    -- calculate fire rate cooldown
    if enemy[i].fireCounter > 0 then
        enemy[i].fireCounter = enemy[i].fireCounter - dt
    end

    -- determine next action by state
    if enemy[i].state == "move" then
        if enemy[i].flying then
            -- TODO: beeline toward player's centre
            angle = util.angleFromTo(enemy[i].position.x + enemy[i].size/2, enemy[i].position.y + enemy[i].size/2, player.position.x + player.width/2, player.position.y + player.height / 2)
            x, y = util.toCartesian(angle, enemy[i].speed)
            enemy[i].velocity.x = x
            enemy[i].velocity.y = y
        else
            -- if not flying, move only horizontally, according to friction rules
            if enemy[i].onGround then
                -- move toward player
                direction = 0
                if player.position.x + player.width/2 < enemy[i].position.x + enemy[i].size/2 then
                    direction = -1
                end
                if player.position.x + player.width/2 > enemy[i].position.x + enemy[i].size/2 then
                    direction = 1
                end
                if onGround then
                    enemy[i].velocity.x = enemy[i].velocity.x + direction * enemy[i].speed * enemy.friction * dt
                else
                    enemy[i].velocity.x = enemy[i].velocity.x + direction * enemy[i].speed * enemy.airControl * dt
                end
            end
        end
    end

    -- apply gravity to non-flyers
    if not flying then
        enemy[i].velocity.y = enemy[i].velocity.y + game.constants.gravity * dt
        -- apply friction to ground units
        if enemy[i].onGround then
            enemy[i].velocity.x = enemy[i].velocity.x - enemy[i].velocity.x * enemy.friction * dt
        end
    end

    -- update positions based on velocity
    enemy[i].position.x = enemy[i].position.x + enemy[i].velocity.x * dt
    if enemy[i].clips then
        for j = 1, #terrain do
            if util.intersects(enemy[i].position.x, enemy[i].position.y, enemy[i].size, enemy[i].size,
                terrain[j].position.x, terrain[j].position.y, terrain[j].width, terrain[j].height) then

                if enemy[i].velocity.x >= 0 then
                    overlap = terrain[j].position.x - (enemy[i].position.x + enemy[i].size)
                else
                    overlap = terrain[j].position.x + terrain[j].width - enemy[i].position.x
                end
                enemy[i].position.x = enemy[i].position.x + overlap
                enemy[i].velocity.x = 0

                -- if the enemy is a grounded type and on the ground, jump
                if enemy[i].onGround and enemy[i].flying == false then
                    enemy[i].velocity.y = -enemy.jumpStrength
                    enemy[i].onGround = false
                end
            end
        end
    end
    enemy[i].position.y = enemy[i].position.y + enemy[i].velocity.y * dt
    if not enemy[i].flying then
        enemy[i].onGround = false
    end
    if enemy[i].clips then
        for j = 1, #terrain do
            if util.intersects(enemy[i].position.x, enemy[i].position.y, enemy[i].size, enemy[i].size,
                terrain[j].position.x, terrain[j].position.y, terrain[j].width, terrain[j].height) then

                if enemy[i].velocity.y >= 0 then
                    overlap = terrain[j].position.y - (enemy[i].position.y + enemy[i].size)
                else
                    overlap = terrain[j].position.y + terrain[j].height - enemy[i].position.y
                end
                enemy[i].position.y = enemy[i].position.y + overlap
                enemy[i].velocity.y = 0
            end
            if not enemy[i].flying then
                enemy[i].onGround = true
            end
        end
    end

    -- damage player if melee and touching player
    if enemy[i].melee then
        -- check collision with player
        collides = util.intersects(enemy[i].position.x, enemy[i].position.y, enemy[i].size, enemy[i].size, player.position.x, player.position.y, player.width, player.height)
        if collides then
            player.damage(1)
        end
    end

    if enemy[i].state == "shoot" then
        -- shoot if the enemy is able to
        if enemy[i].fireCounter <= 0 then
            -- TODO: spawn projectile
            angle = util.angleFromTo(enemy[i].position.x + enemy[i].size/2, enemy[i].position.y + enemy[i].size/2,
                player.position.x + player.width/2, player.position.y + player.height/2)
            -- calculate offset so projectile doesn't spawn inside enemy and damage them
            xo, yo = util.toCartesian(angle, enemy[i].size)
            x = enemy[i].position.x + enemy[i].size/2 + xo
            y = enemy[i].position.y + enemy[i].size/2 + yo
            projectile.new(x, y, angle, enemy[i].bullet)

            enemy[i].fireCounter = enemy[i].fireRate
        end
    end

    return false
end
function enemy.updateAll(dt)
    for i = #enemy, 1, -1 do
        delete = enemy.update(i, dt)
        if delete then
            table.remove(enemy, i)
        end
    end
end

function enemy.damage(i, dmg)
    enemy[i].jitter = enemy.jitterTime
    enemy[i].health = enemy[i].health - 1
end

function enemy.draw(i)
    -- calculate jitter
    jitterX = 0
    jitterY = 0
    if enemy[i].jitter > 0 then
        jitterX = math.random(-enemy.jitter, enemy.jitter)
        jitterY = math.random(-enemy.jitter, enemy.jitter)
    end

    love.graphics.setColor(unpack(enemy[i].color))
    love.graphics.rectangle("fill", enemy[i].position.x + jitterX, enemy[i].position.y + jitterY, enemy[i].size, enemy[i].size)

    -- draw pain color if hurt
    if enemy[i].jitter > enemy.jitterTime/3 then
        love.graphics.setColor(255, 0, 0, 125)
        love.graphics.rectangle("fill", enemy[i].position.x + jitterX, enemy[i].position.y + jitterY, enemy[i].size, enemy[i].size)
    end
end
function enemy.drawAll()
    for i = 1, #enemy do
        enemy.draw(i)
    end
end
