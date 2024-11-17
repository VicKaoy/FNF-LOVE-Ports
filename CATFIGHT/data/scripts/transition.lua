local trans = require "transition"

game.discardTransition()
game.getState().transIn = trans()
game.getState().transOut = trans()
