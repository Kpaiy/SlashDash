enemy = {
    types = {
        bat = {
            flying = true,
            melee = true,
            speed = 50,
            health = 1,
            states = {"move"},
            startState = "move",
            color = {170, 0 ,170},
            size = 30,
            thinks = false,
            thinkTime = -1
        }
    }
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

        state = type.startState,
        thinkCounter = type.thinkTime,
        
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

    -- update positions based on velocity
    -- TODO: collision detection with terrain
    enemy[i].position.x = enemy[i].position.x + enemy[i].velocity.x * dt
    enemy[i].position.y = enemy[i].position.y + enemy[i].velocity.y * dt

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

function enemy.draw(i)
    love.graphics.setColor(unpack(enemy[i].color))
    love.graphics.rectangle("fill", enemy[i].position.x, enemy[i].position.y, enemy[i].size, enemy[i].size)
end
function enemy.drawAll()
    for i = 1, #enemy do
        enemy.draw(i)
    end
end
