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
