game = {
	settings = {},
	constants = {}
}

game.settings.resolution = {
	x = 1600,
	y = 900
}
game.settings.title = "Slash Dash"

function game.init()
	love.window.setTitle(game.settings.title)
	love.window.setMode(game.settings.resolution.x, game.settings.resolution.y)
end
