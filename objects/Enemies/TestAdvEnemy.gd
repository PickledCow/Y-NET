extends "res://scripts/BasicEnemy.gd"

func _ready():
	walk_time = 10

func choose_move(root):
	var valid_spot = false
	var pos = (position - Vector2(32,32)) / 64
	pos.x = floor(pos.x)
	pos.y = floor(pos.y)
	var closest_player
	var closest_position = 0
	for p in root.players:
		var distance = position.distance_squared_to(p.position)
		if closest_position == 0 || distance <= closest_position:
			closest_position = distance
			closest_player = p
	var player_pos = (closest_player.position - Vector2(32,32)) / 64
	var x = floor(player_pos.x) + sign(pos.x - player_pos.x)
	var y = floor(player_pos.y) + sign(pos.y - player_pos.y)
	var path = root.astar.get_point_path(pos.y * (root.maxX + 1) + pos.x, y * (root.maxX + 1) + x)
	if len(path) >= 2 && len(path) <= root.current_turn_time / walk_time + 1 && root.is_tile_free(x, y):
		return [CONSTS.ENEMY_ACTION.WALK, path, true]
	root.create_bubble_text("[center][shake rate=25 level=30]I'm lost :(", position, false)
	return [null, null, true]

