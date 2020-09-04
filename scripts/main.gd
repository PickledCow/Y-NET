extends Node2D


onready var tilemap = get_node("TileMap")
onready var mapoutline = get_node("Outline")

var max_turn_time = 100
var current_turn_time = 100

onready var HUD_node = get_node("HUD")
onready var cursor = get_node("Cursor")
onready var camera = get_node("Camera")
onready var arrow_cursor = get_node("CurrentPlayerArrow")

# -------------------Initialisation Functions--------------------------------- #

var maxX = 0
var maxY = 0
var astar
var path

# Find bounds of the map, generate AStar, and create outline of the world
func initialise_board():
	# Find bounds first
	maxX = 0
	maxY = 0
	for tile in tilemap.get_used_cells():
		maxX = max(maxX, tile.x)
		maxY = max(maxY, tile.y)
		
	# Create new AStar
	var astar = AStar2D.new()
	
	# Generate first row
	astar.add_point(0, Vector2(0, 0), 1)
	if tilemap.get_cell(0, 0) in tilemap.walls:
		mapoutline.set_cell(0, 0, 0)
	for x in range(1,maxX + 1):
		astar.add_point(x, Vector2(x, 0), 1)
		if tilemap.get_cell(x, 0) in tilemap.floors and tilemap.get_cell(x - 1, 0) in tilemap.floors:
			astar.connect_points(x - 1, x, true)
		elif tilemap.get_cell(x, 0) in tilemap.walls:
			mapoutline.set_cell(x, 0, 0)
	
	# Generate rest of rows
	for y in range(1, maxY + 1):
		for x in range(0, maxX + 1):
			astar.add_point(y * (maxX + 1) + x, Vector2(x, y), 1)
			if tilemap.get_cell(x, y) in tilemap.floors:
				if tilemap.get_cell(x, y - 1) in tilemap.floors:
					astar.connect_points((y - 1) * (maxX + 1) + x, y * (maxX + 1) + x, true)
				if tilemap.get_cell(x - 1, y) in tilemap.floors:
					astar.connect_points(y * (maxX + 1) + x - 1, y * (maxX + 1) + x, true)
			elif tilemap.get_cell(x, y) in tilemap.walls:
				mapoutline.set_cell(x, y, 0)
	
	return astar

var players = []
var current_player = 0

var enemies = []
var current_enemy = -1


func _ready():
	astar = initialise_board()
	for child in $Players.get_children():
		players.append(child)
	for child in $Enemies.get_children():
		enemies.append(child)
		
	camera.set_target(players[current_player])
	arrow_cursor.set_target(players[current_player])

# ---------------------------Tool Functions----------------------------------- #

# Check if tile isn't obstructed, the master tile check function, call this
# function most of the time but feel free to call the others if required
func is_tile_free(x, y):
	var valid = true
	if !is_tile_in_bound(x, y):
		valid = false
	if !is_tile_floor(x, y):
		valid = false
	if is_tile_occupied(x, y):
		valid = false
	return valid


func is_tile_in_bound(x, y):
	var valid = true
	if x < 0 || x > maxX:
		valid = false
	if y < 0 || y > maxY:
		valid = false
	return valid

func is_tile_floor(x, y):
	return tilemap.get_cell(x, y) in tilemap.floors

func is_tile_wall(x, y):
	return tilemap.get_cell(x, y) in tilemap.walls

func is_tile_occupied(x, y):
	var valid = false
	
	for i in players + enemies:
		var pos = (i.position - Vector2(32,32)) / 64
		pos.x = floor(pos.x)
		pos.y = floor(pos.y)
		if (Vector2(x, y) == pos):
			valid = true
			break
	return valid

func is_path_valid(path, walk_time):
	var valid = true
	
	if len(path) < 2:
		valid = false
	elif len(path) > current_turn_time / walk_time:
		valid = false
	elif !is_tile_floor(path[-1].x, path[-1].y):
		valid = false
	for e in players + enemies:	
		if ((e.position - Vector2(32,32)) / 64) == path[-1]:
			valid = false
			break
	return valid
	
	
# ---------------------------Object Spawning Functions------------------------ #

# Popup text prefab
var bubble_text_prefab = preload("res://objects/PopupText.tscn")


# text: the text of the text (lel); pos: where to spawn the text; disco: optional, makes the text go crazy
func create_bubble_text(text, pos, disco=false):
	var bubble_text = bubble_text_prefab.instance()
	var display_text = ''
	if disco: display_text += '[rainbow freq=0.1][wave amp=256 freq=12]'
	display_text += text
	bubble_text.init(display_text, pos)
	add_child(bubble_text)


# ---------------------------Main Functions----------------------------------- #

var action = CONSTS.ACTION.IDLE # Current action being performed, refer to enums in Constants above

var turn_end = false # If the player or enemy has declared that they have made their final move
var is_player_turn = true
var all_players_dead = false
var all_enemies_dead = false


# Main loop
func _physics_process(delta):
	if !all_players_dead && !all_enemies_dead:
		if is_player_turn:
			match action:
				CONSTS.ACTION.WALKING:
					move_actor(players[current_player])
		elif !is_player_turn:
			match action:
				CONSTS.ACTION.IDLE:
					current_enemy_move()
				CONSTS.ACTION.WALKING:
					move_actor(enemies[current_enemy])

# Player input
func _input(event):
	# Check if we are allowed to click (not acting, player still alive, plyer turn, cursor in range)
	if action == CONSTS.ACTION.IDLE && !all_players_dead && is_player_turn && CONSTS.CURSOR_RANGE.has_point(get_viewport().get_mouse_position()):
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				BUTTON_LEFT:
					choose_dest_current_player()

func choose_dest_current_player():
	var valid = true
	var player = players[current_player]
	var playerpos = (player.position - Vector2(32,32)) / 64
	var mouse = get_global_mouse_position() / 64
	playerpos.x = floor(playerpos.x)
	playerpos.y = floor(playerpos.y)
	mouse.x = floor(mouse.x)
	mouse.y = floor(mouse.y)
	
	var occupied = false
	var too_far = false
	
	for p in players:
		var ppos = (p.position - Vector2(32,32)) / 64
		ppos.x = floor(ppos.x)
		ppos.y = floor(ppos.y)
		if (mouse == ppos):
			occupied = true
			break
	for p in enemies:
		var ppos = (p.position - Vector2(32,32)) / 64
		ppos.x = floor(ppos.x)
		ppos.y = floor(ppos.y)
		if (mouse == ppos):
			valid = false
			break
		
	
	var newpath = astar.get_point_path(playerpos.y * (maxX + 1) + playerpos.x, mouse.y * (maxX + 1) + mouse.x)
	
	if len(newpath) < 2:
		valid = false
		
	if (len(newpath)-1) * player.walk_time > current_turn_time:
		too_far = true
		
	if mouse.x < 0 || mouse.x > maxX:
		valid = false
	
	if valid && !too_far && !occupied:
		cursor.valid_tile()
		path = newpath
		action = CONSTS.ACTION.WALKING
		current_turn_time -= (len(newpath)-1) * player.walk_time
		HUD_node.update_time_bar(current_turn_time, max_turn_time)
		start_move(players[current_player])
	else:
		cursor.invalid_tile(len(newpath)-1, current_turn_time / player.walk_time, !valid, occupied, too_far)
		
func shoot_current_player():
	if Input.is_action_just_pressed("shoot"):
		var player = players[current_player]
		var gunpath = player.get_node("Gunpath")
		gunpath.enabled = true
		
		var playerpos = players[current_player].position
		var mouse = get_global_mouse_position()
		
		var angle = playerpos.angle_to_point(mouse)
		gunpath.position = -Vector2(cos(angle), sin(angle)) * 2
		gunpath.cast_to = (mouse - playerpos - gunpath.position).normalized() * player.shoot_range * 64
		
		var laser = player.get_node("LaserSight")
		
		laser.rotation = gunpath.cast_to.angle()
		
		laser.position = gunpath.position

var t = 0 # Timer walking between the tiles (micro scope) [0 <= t <= 1]
var u = 0 # Timer walking through the tiles (macro scope) [0 <= u]

func start_move(actor):
	t = 0
	u = 0
	HUD_node.disable_UI()
	if is_player_turn:
		camera.set_target(actor)
		arrow_cursor.set_target(actor)

func move_actor(actor):
	actor.position = (path[u] * 64).linear_interpolate(path[u+1] * 64 , t) + Vector2(32,32)
	t += 0.1
	if t >= 1:
		t -= 1;
		u += 1
		if u == len(path) - 1:
			end_turn()
	
func end_turn():
	action = CONSTS.ACTION.IDLE
	
	if current_turn_time == 0:
		turn_end = true
	
	if turn_end:
		if is_player_turn:
			var starting_enemy = current_enemy
			current_enemy = (current_enemy + 1) % len(enemies)
			while enemies[current_enemy].dead:
				current_enemy = (current_enemy + 1) % len(enemies)
				if current_enemy == starting_enemy:
					all_enemies_dead = true
					print("ct win")
					break
			
			#$Camera.warpToPosition(enemies[currentEnemy].position)
			cursor.disable_cursor()
			arrow_cursor.hide()
			HUD_node.disable_UI()
		
		else:
			
			var starting_player = current_player
			current_player = (current_player + 1) % len(players)
			while players[current_player].dead:
				current_player = (current_player + 1) % len(players)
				if current_player == starting_player:
					all_players_dead = true
					print("gameover")
					break
	
			camera.set_target(players[current_player])
			
		is_player_turn = !is_player_turn
		current_turn_time = max_turn_time
		turn_end = false
		
	if is_player_turn:
		cursor.enable_cursor()
		arrow_cursor.set_target(players[current_player])
		arrow_cursor.show()
		HUD_node.enable_UI()
		HUD_node.update_time_bar(current_turn_time, max_turn_time)

func current_enemy_move():
	var valid_move = false
	
	var enemy = enemies[current_enemy]
	var move = enemy.choose_move(self)
	turn_end = move[2]
	match move[0]:
		CONSTS.ENEMY_ACTION.WALK:
			if is_path_valid(move[1], current_turn_time / enemies[current_enemy].walk_time):
				valid_move = true
				path = move[1]
				current_turn_time -= enemies[current_enemy].walk_time * (len(path) - 1)
				action = CONSTS.ACTION.WALKING
				start_move(enemies[current_enemy])
			
			
	if !valid_move:
		turn_end = true
		action = CONSTS.ACTION.IDLE
		end_turn()


func skip_turn_pressed():
	if is_player_turn && action == CONSTS.ACTION.IDLE:
		turn_end = true
		end_turn()
