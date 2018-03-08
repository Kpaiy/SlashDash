player = {
    health = 5,

	position = {
		x = 0,
		y = 0
	},
	velocity = {
		x = 0,
		y = 0
	},
	health = 100,
	width = 35,
	height = 70,

	moveSpeed = 350,
	jumpStrength = 400,
	friction = 10,
	airControl = 2.5,
	airJumps = {
		maxJumps = 2, --number of jumps the character can do in the air
		jumps = 2, --current air jump counter
	},
	slashStats = {
		angle = 1,
		length = 150,
		coolDown = 0.2,
		duration = 0.25,
		maxAlpha = 200,
        damage = 1
	},
	dashStats = {
		maxCharges = 3,
		length = 500,
		coolDown = 3,
		duration = 0.25,
		maxAlpha = 200,
		lineThickness = 5,
		playerAlpha = -50,
		alphaRecovery = 1500,

        hitDistance = 60, -- maximum perpendicular distance from dash-line to hit
        damage = 1
	},
    invulnStats = {
        coolDown = 1,
        jitter = 2,
        alphaHit = 200,
    },

	onGround = false,
	toDraw = {
		slash = {},	--x, y, r, a1, a2, t (time)
		dash = {} --x1, y1, x2, x2, a2, t (time)
	},
	coolDowns = {
		slash = 0,
		dash = 3,
        invuln = 0
	},
	dashes = 3,
	alpha = 255,
	aiming = false

}

function player.getInput()
	x = 0
	if love.keyboard.isDown("a") then
		x = x - 1
	end
	if love.keyboard.isDown("d") then
		x = x + 1
	end
	return x
end

function player.key(key)
	if key == "space" then
		player.jump()
	end
end

function player.damage(dmg)
    -- if player is invulnerable, end
    if player.coolDowns.invuln > 0 then
        return
    end

    player.health = player.health - dmg
    player.coolDowns.invuln = player.invulnStats.coolDown
    player.alpha = player.alpha - player.invulnStats.alphaHit

    love.graphics.setColor(255, 0, 0, 100)
    love.graphics.rectangle("fill", 0, 0, game.settings.resolution.x, game.settings.resolution.y)

    if player.health <= 0 then
        -- TODO: implement lose condition
    end
end

function player.update(dt)
	player.coolDown(dt)

	player.move(dt)

	if not love.mouse.isDown(2) then
		if player.aiming == true then
			player.dash()
		end
		player.aiming = false
	end
end

function player.move(dt)
	input = player.getInput()

	if player.onGround then
		player.airJumps.jumps = player.airJumps.maxJumps
		--apply friction
		player.velocity.x = player.velocity.x - player.velocity.x * (player.friction * dt)
		if input ~= 0 then
			if math.abs(player.velocity.x) < player.moveSpeed then
				player.velocity.x = player.velocity.x + input * player.moveSpeed * player.friction * dt
			end
		end
	else
		if (input == 1 and player.velocity.x < player.moveSpeed) or (input == -1 and player.velocity.x > -player.moveSpeed) then
			player.velocity.x = player.velocity.x + input * player.moveSpeed * player.airControl * dt
		end
	end

	--apply gravity
	player.velocity.y = player.velocity.y + game.constants.gravity * dt

	--translate the player by the given velocity and collision check
	player.position.x = player.position.x + player.velocity.x * dt
	for i = 1, #terrain do
		if util.intersects(player.position.x, player.position.y, player.width, player.height,
			terrain[i].position.x, terrain[i].position.y, terrain[i].width, terrain[i].height) then

			if player.velocity.x >= 0 then
				overlap = terrain[i].position.x - (player.position.x + player.width)
			else
				overlap = terrain[i].position.x + terrain[i].width - player.position.x
			end
			player.position.x = player.position.x + overlap
			player.velocity.x = 0
		end
	end

	player.position.y = player.position.y + player.velocity.y * dt
	player.onGround = false
	for i = 1, #terrain do
		if util.intersects(player.position.x, player.position.y, player.width, player.height,
			terrain[i].position.x, terrain[i].position.y, terrain[i].width, terrain[i].height) then

			if player.velocity.y >= 0 then
				overlap = terrain[i].position.y - (player.position.y + player.height)
			else
				overlap = terrain[i].position.y + terrain[i].width - player.position.y
			end
			player.position.y = player.position.y + overlap
			player.velocity.y = 0
			player.onGround = true
		end
	end

	player.clamp()
end

function player.clamp()
	--prevents the player from leaving the bounds of the screen
	if player.position.x < 0 then
		player.position.x = 0
	end
	if player.position.y < 0 then
		player.position.y = 0
	end

	if player.position.x + player.width > game.settings.resolution.x then
		player.position.x = game.settings.resolution.x - player.width
	end
	if player.position.y + player.height > game.settings.resolution.y then
		player.position.y = game.settings.resolution.y - player.height
	end
end

function player.jump()
	if player.onGround then
		player.velocity.y = -player.jumpStrength
		player.onGround = false
	else
		if player.airJumps.jumps > 0 then
			player.velocity.y = -player.jumpStrength
			player.velocity.x = player.getInput() * player.moveSpeed
			player.airJumps.jumps = player.airJumps.jumps - 1
		end
	end
end

function player.coolDown(dt)
	if player.coolDowns.slash > 0 then
		player.coolDowns.slash = player.coolDowns.slash - dt
	end

	if player.coolDowns.dash > 0 and player.dashes < player.dashStats.maxCharges then
		player.coolDowns.dash = player.coolDowns.dash - dt
	end
	if player.coolDowns.dash == player.dashStats.maxCharges then
		player.coolDowns.dash = player.dashStats.coolDown
	end
	if player.coolDowns.dash <= 0 then
		if player.dashes < player.dashStats.maxCharges then
			player.dashes = player.dashes + 1
			player.coolDowns.dash = player.dashStats.coolDown
		end
	end

	if player.alpha < 255 then
		player.alpha = player.alpha + player.dashStats.alphaRecovery * dt
	end
	if player.alpha > 255 then
		player.alpha = 255
	end

    if player.coolDowns.invuln > 0 then
        player.coolDowns.invuln = player.coolDowns.invuln - dt
    end
end

function player.slash()
	if player.coolDowns.slash > 0 then
		return
	end

	player.coolDowns.slash = player.slashStats.coolDown

	aimAngle = util.cursorAngle(player.position.x, player.position.y, player.width, player.height)

	player.toDraw.slash[#player.toDraw.slash + 1] = {
		x = player.position.x + player.width / 2,
		y = player.position.y + player.height / 2,
		r = player.slashStats.length,
		a1 = aimAngle - player.slashStats.angle,
		a2 = aimAngle + player.slashStats.angle,
		t = 0
	}

    -- check for enemies in range to damage
    for i = 1, #enemy do
        -- get distance from centre of arc to enemy
        if util.distance(player.toDraw.slash[#player.toDraw.slash].x, player.toDraw.slash[#player.toDraw.slash].y, enemy[i].position.x + enemy[i].size/2, enemy[i].position.y + enemy[i].size/2) <= player.toDraw.slash[#player.toDraw.slash].r then
            -- get angle from centre of arc to enemy
            angle = util.angleFromTo(player.toDraw.slash[#player.toDraw.slash].x, player.toDraw.slash[#player.toDraw.slash].y, enemy[i].position.x + enemy[i].size/2, enemy[i].position.y + enemy[i].size/2)
            if angle > player.toDraw.slash[#player.toDraw.slash].a1 and angle < player.toDraw.slash[#player.toDraw.slash].a2 then
                enemy.damage(i, player.slashStats.damage)
            end
        end
    end
end

function player.dash()
	if player.dashes <= 0 then
		return
	end

	angle = util.cursorAngle(player.position.x, player.position.y, player.width, player.height)
	x, y = util.toCartesian(angle, player.dashStats.length)

	if player.position.x + x < 0 or player.position.x + x + player.width > game.settings.resolution.x or player.position.y + y < 0 or player.position.y + y + player.height > game.settings.resolution.y then
		return
	end

	oldX, oldY = player.position.x, player.position.y
	player.position.x = oldX + x
	player.position.y = oldY + y

	player.clamp()

	for i = 1, #terrain do
		if util.intersects(player.position.x, player.position.y, player.width, player.height,
			terrain[i].position.x, terrain[i].position.y, terrain[i].width, terrain[i].height) then

			player.position.x = oldX
			player.position.y = oldY
			return
		end
	end

	player.onGround = false

	player.dashes = player.dashes - 1
	-- player.coolDowns.dash = player.dashStats.coolDown

	player.velocity.x = 0
	player.velocity.y = 0
	player.airJumps.jumps = player.airJumps.maxJumps

	player.alpha = player.dashStats.playerAlpha

	player.toDraw.dash[#player.toDraw.dash + 1] = {
		x1 = player.position.x + player.width / 2,
		y1 = player.position.y + player.height / 2,
		x2 = oldX + player.width / 2,
		y2 = oldY + player.height / 2,
		t = 0
	}

    -- check for collisions with enemies
    for i = 1, #enemy do
        pd = util.perpendicularDistance(enemy[i].position.x + enemy[i].size/2, enemy[i].position.y + enemy[i].size/2, player.position.x + player.width/2, player.position.y + player.height/2, oldX + player.width/2, oldY + player.height/2)
        print(pd)
        if pd <= player.dashStats.hitDistance and pd ~= -1 then
            -- damage the enemy
            enemy.damage(i, player.dashStats.damage)
        end
    end           

end

function player.draw()
	for i=#player.toDraw.slash, 1, -1 do
		player.toDraw.slash[i].t = player.toDraw.slash[i].t + deltaTime
		if player.toDraw.slash[i].t > player.slashStats.duration then
			table.remove(player.toDraw.slash, i)
			goto continue
		end
		opacity = player.slashStats.maxAlpha - player.slashStats.maxAlpha * (player.toDraw.slash[i].t) / player.slashStats.duration
		love.graphics.setColor(255, 120, 120, opacity)
		love.graphics.arc("fill", player.toDraw.slash[i].x, player.toDraw.slash[i].y,
			player.toDraw.slash[i].r, player.toDraw.slash[i].a1, player.toDraw.slash[i].a2)

		::continue::
	end

	love.graphics.setLineWidth(player.dashStats.lineThickness)
	for i=#player.toDraw.dash, 1, -1 do
		player.toDraw.dash[i].t = player.toDraw.dash[i].t + deltaTime
		if player.toDraw.dash[i].t > player.dashStats.duration then
			table.remove(player.toDraw.dash, i)
			goto continue2
		end
		opacity = player.dashStats.maxAlpha - player.dashStats.maxAlpha * (player.toDraw.dash[i].t) / player.dashStats.duration
		love.graphics.setColor(255, 120, 120, opacity)
		love.graphics.line(player.toDraw.dash[i].x1, player.toDraw.dash[i].y1, player.toDraw.dash[i].x2, player.toDraw.dash[i].y2)

		::continue2::
	end

	if player.aiming and player.dashes ~= 0 then
		angle = util.cursorAngle(player.position.x, player.position.y, player.width, player.height)
		x, y = util.toCartesian(angle, player.dashStats.length)
		-- x, y = util.clamp(player.position.x + x, player.position.y + y, player.width, player.height)
		x = player.position.x + x
		y = player.position.y + y
		if x < 0 or x + player.width > game.settings.resolution.x or y < 0 or y + player.height > game.settings.resolution.y then
		else
			love.graphics.setColor(255, 0, 0, 127)
			love.graphics.rectangle("line", x, y, player.width, player.height)
		end
	end

    -- calculate player jitter upon taking damage
    jitterX = 0
    jitterY = 0
    if player.coolDowns.invuln > 0 then
        jitterX = math.random(-player.invulnStats.jitter, player.invulnStats.jitter)
        jitterY = math.random(-player.invulnStats.jitter, player.invulnStats.jitter)
    end

	love.graphics.setColor(255, 0, 0, player.alpha)
	love.graphics.rectangle("fill", player.position.x + jitterX, player.position.y + jitterY, player.width, player.height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(player.dashes .. "\n" .. player.coolDowns.dash, 0, 0, 0, 2)

	-- draw damage flash if hurt
	if player.coolDowns.invuln == player.invulnStats.coolDown then
		love.graphics.setColor(255, 0, 0, 100)
	    love.graphics.rectangle("fill", 0, 0, game.settings.resolution.x, game.settings.resolution.y)
	end
end
