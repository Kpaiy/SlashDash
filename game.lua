game = {
	settings = {},
	constants = {},
	resources = {
		graphics = {}
	}
}

game.settings.resolution = {
	x = 1600,
	y = 900
}
game.settings.title = "Slash Dash"

game.constants.tileWidth = 25
game.constants.gradientTolerance = 1	-- the max height difference between tiles

function game.init()
	math.randomseed(os.time())

	love.window.setTitle(game.settings.title)
	love.window.setMode(game.settings.resolution.x, game.settings.resolution.y)
	love.graphics.setDefaultFilter("nearest", "nearest")

	game.resources.graphics.dirt = love.graphics.newImage("resources/graphics/dirt.png")
end
