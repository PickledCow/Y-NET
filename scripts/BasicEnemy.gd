extends Node2D

enum {WALK, RUN, SHOOT, CROUCH}

var knocked_out = false
var dead = false

var health = 5

var shoot_range = 20
var walk_time = 4

# Dummy AI
# If you submit an invalid move, the enemy will skip their turn
# Useful variables:
# maxX, maxY: size of world, 0 and maxX/maxY on the board will basically always be a wall

func choose_move(root):
	var valid_spot = false
	var pos = (position - Vector2(32,32)) / 64
	pos.x = floor(pos.x)
	pos.y = floor(pos.y)
	# We try 10 times and if we fail we just give up
	for i in range(10):
		var distance = randi() % (root.current_turn_time / walk_time - 1) + 1
		var x = ((randi()%2)*2-1) * (randi() % distance)
		var y = ((randi()%2)*2-1) * (distance - abs(x))
		var path = root.astar.get_point_path(pos.y * (root.maxX + 1) + pos.x, (pos.y + y) * (root.maxX + 1) + (pos.x + x))
		if len(path) >= 2 && len(path) <= root.current_turn_time / walk_time + 1 && root.is_tile_free(pos.x + x, pos.y + y):
			return [WALK, path, true]
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

