extends Node2D

var knockedOut = false
var dead = false

var health = 5

var shootRange = 20
var walkTime = 4

# Dummy AI
# If you submit an invalid move, the enemy will skip their turn
# Useful variables:
# maxX, maxY: size of world, 0 and maxX/maxY on the board will basically always be a wall

func chooseMove(root):
	var validSpot = false
	var pos = (position - Vector2(32,32)) / 64
	pos.x = floor(pos.x)
	pos.y = floor(pos.y)
	# We try 10 times and if we fail we just give up
	for i in range(0):
		var distance = randi() % (root.currentTurnTime / walkTime - 1) + 1
		var x = ((randi()%2)*2-1) * (randi() % distance)
		var y = ((randi()%2)*2-1) * (distance - abs(x))
		var path = root.astar.get_point_path(pos.y * (root.maxX + 1) + pos.x, (pos.y + y) * (root.maxX + 1) + (pos.x + x))
		if len(path) >= 2 && len(path) <= root.currentTurnTime / walkTime + 1 && root.isTileFree(pos.x + x, pos.y + y):
			return ["move", path, true]
	root.createBubbleText("[center][shake rate=25 level=30]I'm lost :(", position, false)
	return ['hate', null, true]
			
# Moves
# [<action>, <parameter>, <turnEnd>]
# Action: What you want to do
# Parameters: How will you do that action
# TurnEnd: Skip any remaining time
# Actions + parameter
# move: Vector2 position
# 

