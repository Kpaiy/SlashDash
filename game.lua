game = {
	settings = {},
	constants = {
		tileWidth = 25,
		gradientTolerance = 1,	-- the max height difference between tiles
		gravity = 1000,
	},
	resources = {
		graphics = {}
	}
}

game.settings.resolution = {
	x = 1600,
	y = 900
}
game.settings.title = "Slash Dash"

function game.init()
	math.randomseed(os.time())

	love.window.setTitle(game.settings.title)
	love.window.setMode(game.settings.resolution.x, game.settings.resolution.y)
	love.graphics.setDefaultFilter("nearest", "nearest")

	game.resources.graphics.dirt = love.graphics.newImage("resources/graphics/dirt.png")
end


function love.keypressed(key)
	player.key(key)
end
