projectile = {
    types = {
        normal = {
            speed = 200,
            color = {255, 255, 100},
            size = 10,
        }
    }
}

function projectile.new(x, y, angle, type)
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

