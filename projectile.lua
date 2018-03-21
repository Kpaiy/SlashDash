projectile = {
    types = {
        normal = {
            speed = 300,
            color = {255, 255, 100},
            size = 6,
        },
        fast = {
            speed = 450,
            color = {100, 255, 255},
            size = 5,
        }
    }
}

function projectile.new(x, y, angle, type)
    -- check for instant collision with terrain
    for j = 1, #terrain do
        if util.intersects(x - type.size/2, y - type.size/2, type.size, type.size,
             terrain[j].position.x, terrain[j].position.y, terrain[j].width, terrain[j].height) then
             return
        end
    end

    projectile[#projectile + 1] = {
        speed = type.speed,
        color = type.color,
        size = type.size,
        x = x,
        y = y,
        angle = angle, -- the direction in which the projectile is moving
    }
end

-- return true if the projectile is to be deleted
function projectile.update(i, dt)
    c = projectile[i]
    c.x = c.x + math.cos(c.angle) * dt * c.speed
    c.y = c.y + math.sin(c.angle) * dt * c.speed

    -- if the projectile is entirely out of map bounds, delete it
    if c.x + c.size/2 < 0 or c.x - c.size/2 > game.settings.resolution.x or
        c.y + c.size/2 < 0 or c.y - c.size/2 > game.settings.resolution.y then
        return true
    end

    -- if it is colliding with the player, damage the player and delete it
    if util.intersects(c.x - c.size/2, c.y - c.size/2, c.size, c.size,
        player.position.x, player.position.y, player.width, player.height) then
        player.damage(1)
        return true
    end

    -- if it is colliding with terrain, delete it
    for j = 1, #terrain do
        if util.intersects(c.x - c.size/2, c.y - c.size/2, c.size, c.size,
             terrain[j].position.x, terrain[j].position.y, terrain[j].width, terrain[j].height) then
            return true
        end
    end
    
    -- if it is colliding with an enemy, delete and damage
    for j = 1, #enemy do
        if util.intersects(c.x - c.size/2, c.y - c.size/2, c.size, c.size,
            enemy[j].position.x, enemy[j].position.y, enemy[j].size, enemy[j].size) then
            enemy.damage(j, 1)
            player.addCombo(game.constants.comboProjectile)
            return true
        end
    end

    return false
end
function projectile.updateAll(dt)
    for i = #projectile, 1, -1 do
        delete = projectile.update(i, dt)
        if delete then
            table.remove(projectile, i)
        end
    end
end

function projectile.draw(i)
    love.graphics.setColor(unpack(projectile[i].color))
    love.graphics.circle("fill", projectile[i].x, projectile[i].y, projectile[i].size)
end
function projectile.drawAll()
    for i = 1, #projectile do
        projectile.draw(i)
    end
end

