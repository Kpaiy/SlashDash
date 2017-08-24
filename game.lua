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

function game.init()
	love.window.setTitle(game.settings.title)
	love.window.setMode(game.settings.resolution.x, game.settings.resolution.y)
	love.graphics.setDefaultFilter("nearest", "nearest")

	game.resources.graphics.dirt = love.graphics.newImage("resources/graphics/dirt.png")
end
