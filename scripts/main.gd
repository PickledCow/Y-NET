extends Node2D

onready var tilemap = get_node("TileMap")

var maxX = 0
var maxY = 0
var astar
var path


func generateAStar():
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
	for x in range(1,maxX + 1):
		astar.add_point(x, Vector2(x, 0), 1)
		if tilemap.get_cell(x, 0) in tilemap.floors and tilemap.get_cell(x - 1, 0) in tilemap.floors:
			astar.connect_points(x - 1, x, true)
	
	# Generate rest of rows
	for y in range(1, maxY + 1):
		for x in range(0, maxX + 1):
			astar.add_point(y * (maxX + 1) + x, Vector2(x, y), 1)
			if tilemap.get_cell(x, y) in tilemap.floors:
				if tilemap.get_cell(x, y - 1) in tilemap.floors:
					astar.connect_points((y - 1) * (maxX + 1) + x, y * (maxX + 1) + x, true)
				if tilemap.get_cell(x - 1, y) in tilemap.floors:
					astar.connect_points(y * (maxX + 1) + x - 1, y * (maxX + 1) + x, true)
	
	return astar

var players = []

var currentPlayer = 0

func _ready():
	astar = generateAStar()
	path = astar.get_point_path(maxX + 2, maxX + 2)	
	for child in $Players.get_children():
		players.append(child)
	$Camera.warpToPosition(players[currentPlayer].position)
		
var t = 0
var u = 0
var arrived = true

func _physics_process(delta):
	var valid = true
	if arrived:
		if Input.is_action_just_pressed("click"):
			var playerpos = (players[currentPlayer].position - Vector2(32,32)) / 64
			var mouse = get_global_mouse_position() / 64
			playerpos.x = floor(playerpos.x)
			playerpos.y = floor(playerpos.y)
			mouse.x = floor(mouse.x)
			mouse.y = floor(mouse.y)
			
			if mouse.x < 0 || mouse.x > maxX:
				valid = false
			
			for player in players:
				var ppos = (player.position - Vector2(32,32)) / 64
				ppos.x = floor(ppos.x)
				ppos.y = floor(ppos.y)
				if (mouse == ppos):
					valid = false
					break
				
			
			var newpath = astar.get_point_path(playerpos.y * (maxX + 1) + playerpos.x, mouse.y * (maxX + 1) + mouse.x)
			
			if len(newpath) < 2:
				valid = false
				
			if valid:
				path = newpath
				arrived = false
				t = 0
				u = 0
		
		if Input.is_action_just_pressed("shoot"):
			var player = players[currentPlayer]
			var gunpath = player.get_node("Gunpath")
			gunpath.enabled = true
			
			var playerpos = players[currentPlayer].position
			var mouse = get_global_mouse_position()
			
			var angle = playerpos.angle_to_point(mouse)
			gunpath.position = -Vector2(cos(angle), sin(angle)) * 2
			gunpath.cast_to = (mouse - playerpos - gunpath.position).normalized() * player.shootRange * 64
			
			var laser = player.get_node("LaserSight")
			
			laser.rotation = gunpath.cast_to.angle()
			
			laser.position = gunpath.position
			
			
			if (gunpath.is_colliding()):
				print('target')
			
		
		
	if !arrived:
		$Camera.warpToPosition(players[currentPlayer].position)
		players[currentPlayer].position = (path[u] * 64 ).linear_interpolate(path[u+1] * 64 , t)+ Vector2(32,32)
		t += 0.1
		if t >= 1:
			t -= 1;
			u += 1
			if u == len(path) - 1:
				arrived = true
				currentPlayer = (currentPlayer + 1) % len(players)
				$Camera.warpToPosition(players[currentPlayer].position)
				

