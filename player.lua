player = {
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
		jumpAgain = true
	},
	slashStats = {
		angle = 0.8,
		length = 150,
		coolDown = 0.2,
		duration = 0.5,
		maxAlpha = 200
	},

	onGround = false,
	toDraw = {
		arcs = {}	--x, y, r, a1, a2, t (time)
	}
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

function player.update(dt)
	player.move(dt)
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
			terrain[i].position.x, terrain[i].position.y, terrain[i].width, terrain[i].width) then

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
			terrain[i].position.x, terrain[i].position.y, terrain[i].width, terrain[i].width) then

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

function player.slash()
	aimAngle = util.cursorAngle(player.position.x, player.position.y, player.width, player.height)

	player.toDraw.arcs[#player.toDraw.arcs + 1] = {
		x = player.position.x + player.width / 2,
		y = player.position.y + player.height / 2,
		r = player.slashStats.length,
		a1 = aimAngle - player.slashStats.angle,
		a2 = aimAngle + player.slashStats.angle,
		t = 0
	}
end

function player.dash()

end

function player.draw()
	for i=#player.toDraw.arcs, 1, -1 do
		player.toDraw.arcs[i].t = player.toDraw.arcs[i].t + deltaTime
		if player.toDraw.arcs[i].t > player.slashStats.duration then
			table.remove(player.toDraw.arcs, i)
			goto continue
		end
		opacity = player.slashStats.maxAlpha - player.slashStats.maxAlpha * (player.toDraw.arcs[i].t) / player.slashStats.duration
		love.graphics.setColor(255, 120, 120, opacity)
		love.graphics.arc("fill", player.toDraw.arcs[i].x, player.toDraw.arcs[i].y,
			player.toDraw.arcs[i].r, player.toDraw.arcs[i].a1, player.toDraw.arcs[i].a2)


		::continue::
	end

	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", player.position.x, player.position.y, player.width, player.height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(player.airJumps.jumps)
end
