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
	width = 30,
	height = 80,

	moveSpeed = 350,
	jumpStrength = 400,
	friction = 10,
	airControl = 2,
	airJumps = {
		maxJumps = 1, --number of jumps the character can do in the air
		jumps = 1, --current air jump counter
		jumpAgain = true
	},

	onGround = false,
}

function player.getInput()
	x = 0
	if love.keyboard.isDown("a") then
		x = x - 1
	end
	if love.keyboard.isDown("d") then
		x = x + 1
	end
	jump = false
	if love.keyboard.isDown("space") then
		jump = true
	end
	return x, jump
end

function player.update(dt)
	player.move(dt)
end

function player.move(dt)
	input, jump = player.getInput()
	if not jump then
		player.airJumps.jumpAgain = true
	end

	if player.onGround then
		player.airJumps.jumps = player.airJumps.maxJumps
		--apply friction
		player.velocity.x = player.velocity.x - player.velocity.x * (player.friction * dt)
		if input ~= 0 then
			if math.abs(player.velocity.x) < player.moveSpeed then
				player.velocity.x = player.velocity.x + input * player.moveSpeed * player.friction * dt
			end
		end

		if jump and player.onGround then
			player.onGround = false
			player.airJumps.jumpAgain = false
			player.velocity.y = -player.jumpStrength
		end
	else
		if (input == 1 and player.velocity.x < player.moveSpeed) or (input == -1 and player.velocity.x > -player.moveSpeed) then
			player.velocity.x = player.velocity.x + input * player.moveSpeed * player.airControl * dt
		end
		if jump and player.airJumps.jumps > 0 and player.airJumps.jumpAgain then
			player.airJumps.jumps = player.airJumps.jumps - 1
			player.airJumps.jumpAgain = false
			player.velocity.y = -player.jumpStrength
			player.velocity.x = player.moveSpeed * input
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

end

function player.draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", player.position.x, player.position.y, player.width, player.height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(player.airJumps.jumps)
end
