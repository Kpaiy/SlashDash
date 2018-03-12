terrain = {}

--[[
	terrain elements have the following properties:
		- position -> (x,y)
		- dimensions -> (w,h)
		- texture
		- quad
]]

function terrain.new(x, y, w, h, tex)
	texWidth, texHeight = tex:getDimensions()
	terrain[#terrain + 1] = {
		position = {
			x = x,
			y = y
		},
		width = w,
		height = h,
		texture = tex,
		quad = love.graphics.newQuad(0, 0, w, h, texWidth, texHeight)
	}

	terrain[#terrain].texture:setWrap("repeat")
end

function terrain.draw(i)
	love.graphics.draw(terrain[i].texture, terrain[i].quad, terrain[i].position.x, terrain[i].position.y)
end
function terrain.drawAll()
	--NOTE: upper boundary is inclusive
	for i = 1, #terrain do
		terrain.draw(i)
	end
end

function terrain.generateLevel()
	maxHeight = math.floor(game.settings.resolution.y / game.constants.tileWidth)
	curHeight = math.floor(maxHeight / 3)
	prev1 = 0
	prev2 = 0
	for i = 0, math.floor(game.settings.resolution.x / game.constants.tileWidth) do
		prev2 = prev1
		prev1 = curHeight
		curHeight = curHeight + math.random(-game.constants.gradientTolerance, game.constants.gradientTolerance)
		while curHeight == prev2 do
			curHeight = prev1
			curHeight = curHeight + math.random(-game.constants.gradientTolerance, game.constants.gradientTolerance)
		end

		if curHeight < 1 then
			curHeight = 1
		end

		if curHeight > math.floor(maxHeight / 3) then
			curHeight = math.floor(maxHeight / 3)
		end

		terrain.new(i * game.constants.tileWidth, (maxHeight - curHeight) * game.constants.tileWidth, game.constants.tileWidth, game.constants.tileWidth * (curHeight), game.resources.graphics.dirt)
	end

    -- place player in center of map, on ground
    x = game.settings.resolution.x/2
    y = game.settings.resolution.y - 1

    for i = 1, #terrain do
        if util.intersects(x, y, player.width, player.height, terrain[i].position.x,
            terrain[i].position.y, terrain[i].width, terrain[i].height) then
            y = terrain[i].position.y - player.height
        end
    end
    player.position.x = x
    player.position.y = y
end
