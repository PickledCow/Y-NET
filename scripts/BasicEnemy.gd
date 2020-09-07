extends Node2D

var knocked_out = false
var dead = false
var crouching = false

var health = 5

var shoot_range = 20

var crawl_time = 16
var walk_time = 10
var run_time = 5

# Dummy AI
# If you submit an invalid move, the enemy will skip their turn
# While we will check your movement path, we will trust that you won't try to pull any other tricks
# You could probably get away with secretely crouching but please don't as it may break the game / your AI
# Useful variables:
# maxX, maxY: size of world, 0 and maxX/maxY on the board will basically always be a wall

func choose_move(root):
	var valid_spot = false
	var pos = (position - Vector2(32,32)) / 64
	pos.x = floor(pos.x)
	pos.y = floor(pos.y)
	# We try 10 times and if we fail we just give up
	for i in range(10):
		var distance = 0
		if root.current_turn_time / walk_time - 1 == 0:
			distance = 1
		else:
			distance = randi() % (root.current_turn_time / walk_time - 1) + 1
		var x = ((randi()%2)*2-1) * (randi() % distance)
		var y = ((randi()%2)*2-1) * (distance - abs(x))
		var path = root.get_AStar_path(pos, Vector2(x,y))
		if len(path) >= 2 && len(path) <= root.current_turn_time / walk_time + 1 && root.is_tile_free(pos.x + x, pos.y + y):
			return [CONSTS.ENEMY_ACTION.WALK, path, false]
	root.create_bubble_text("[center][shake rate=25 level=30]I'm lost :(", position, false)
	return [null, null, true]
			
# Moves
# [<action>, <parameter>, <turnEnd>]
# Action: What you want to do
# Parameters: How will you do that action
# TurnEnd: Skip any remaining time
# Actions + parameter
# move: path path
# 

