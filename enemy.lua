enemy = {
    types = {
        bat = {
            flying = true,
            melee = true,
            speed = 50,
            health = 9,
            states = {"move"},
            startState = "move",
            color = {170, 0 ,170},
            size = 15,
            thinks = false,
            thinkTime = -1,
            clips = true,  -- true if can collide with terrain
        }
    },
    jitter = 2,
    jitterTime = 0.5
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

        state = type.startState,
        thinkCounter = type.thinkTime,

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
            -- TODO: pick a random state out of the available states
            
            enemy[i].thinkCounter = enemy[i].thinkTime
        end
    end

    -- determine next action by state
    if enemy[i].state == "move" then
        if enemy[i].flying then
            -- TODO: beeline toward player's centre
            angle = util.angleFromTo(enemy[i].position.x + enemy[i].size/2, enemy[i].position.y + enemy[i].size/2, player.position.x + player.width/2, player.position.y + player.height / 2)
            x, y = util.toCartesian(angle, enemy[i].speed)
            enemy[i].velocity.x = x
            enemy[i].velocity.y = y
        end
    end

    -- apply gravity to non-flyers
    if not flying then
        enemy[i].velocity.y = enemy[i].velocity.y + game.constants.gravity * dt
    end

    -- update positions based on velocity
    enemy[i].position.x = enemy[i].position.x + enemy[i].velocity.x * dt
    if enemy[i].clips then
        -- TODO: collision detection with terrain
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
            end
        end
    end
    enemy[i].position.y = enemy[i].position.y + enemy[i].velocity.y * dt
    if enemy[i].clips then
        -- TODO: collision detection with terrain
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
        love.graphics.setColor(255, 0, 0, 100)
        love.graphics.rectangle("fill", enemy[i].position.x + jitterX, enemy[i].position.y + jitterY, enemy[i].size, enemy[i].size)
    end
end
function enemy.drawAll()
    for i = 1, #enemy do
        enemy.draw(i)
    end
end
