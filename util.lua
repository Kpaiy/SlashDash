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

function util.angleFromTo(fx, fy, tx, ty)
    return math.atan2(ty - fy, tx - fx)
end

function util.toCartesian(angle, modulus)
	x = math.cos(angle) * modulus
	y = math.sin(angle) * modulus
	return x, y
end

function util.clamp(x, y, w, h)
	if x < 0 then x = 0 end
	if y < 0 then y = 0 end
	if x + w > game.settings.resolution.x then
		x = game.settings.resolution.x - w
	end
	if y + h > game.settings.resolution.y then
		y = game.settings.resolution.y - h
	end

	return x, y
end

-- returns the distance between two points
function util.distance(x1, y1, x2, y2)
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end

-- returns the center of a rectangle
function util.center(x, y, w, h)
    return x + w/2, y + h/2
end

-- perpendicular distance from a point to a line segment
function util.perpendicularDistance(x0, y0, x1, y1, x2, y2)
    pd = math.abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1) / math.sqrt(math.pow(y2 - y1, 2) + math.pow(x2 - x1, 2))

    -- if in bounds, return distance
    cx = y0 - y1 + x1 * (y2 - y1)/(x2 - x1) + x0 * (x2 - x1)/(y2 - y1)
	lx = cx / ((math.pow(y2 - y1, 2) + math.pow(x2 - x1, 2))/((x2 - x1) * (y2 - y1)))
	ly = y0 - (x2 - x1)/(y2 - y1) * (lx - x0)

	if x1 < x2 then
		if lx < x1 or lx > x2 then
			return -1
		end
	else
		if lx > x1 or lx < x2 then
			return -1
		end
	end
	if y1 < y2 then
		if ly < y1 or ly > y2 then
			return -1
		end
	else
		if ly > y1 or ly < y2 then
			return -1
		end
	end

    return pd
end
