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

function projectile.update(i, dt)
    c = projectile[i]
    c.x = c.x + math.cos(c.angle) * dt * c.speed
    c.y = c.y + math.sin(c.angle) * dt * c.speed
end
function projectile.updateAll(dt)
    for i = 1, #projectile do
        projectile.update(i, dt)
    end
end

function projectile.draw(i)
    love.graphics.setColor(unpack(projectile[i].color))
    love.graphics.circle("fill", projectile[i].x + projectile[i].size/2, projectile[i].y + projectile[i].size/2, projectile[i].size)
end
function projectile.drawAll()
    for i = 1, #projectile do
        projectile.draw(i)
    end
end

