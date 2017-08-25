util = {}

--determines if two rectangles are overlapping
function util.intersects(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end

--gets angle between center of a rectangle and the cursor
function util.cursorAngle(x, y, w, h)
	cx, cy = love.mouse.getPosition()
	rx = x + w / 2
	ry = y + h / 2
	--atan(dy/dx)
	return math.atan2(cy - ry, cx - rx)
end

function util.toCartesian(angle, modulus)
	x = math.cos(angle) * modulus
	y = math.sin(angle) * modulus
	return x, y
end
