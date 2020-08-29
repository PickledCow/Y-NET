extends Node2D

onready var tilemap = get_node("TileMap")


var maxX = 0
var maxY = 0

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
		if tilemap.get_cell(x, 0) == -1 and tilemap.get_cell(x - 1, 0) == -1:
			astar.connect_points(x - 1, x, true)
	
	# Generate rest of rows
	for y in range(1, maxY + 1):
		for x in range(0, maxX + 1):
			astar.add_point(y * (maxX + 1) + x, Vector2(x, y), 1)
			if tilemap.get_cell(x, y) == -1:
				if tilemap.get_cell(x, y - 1) == -1:
					astar.connect_points((y - 1) * (maxX + 1) + x, y * (maxX + 1) + x, true)
				if tilemap.get_cell(x - 1, y) == -1:
					astar.connect_points(y * (maxX + 1) + x - 1, y * (maxX + 1) + x, true)
	
	return astar

var astar
var path

func _ready():
	astar = generateAStar()
	path = astar.get_point_path(maxX + 2, maxX + 2)
		
var t = 0
var u = 0
var arrived = true

var clicked = false

func _physics_process(delta):
	if Input.is_action_just_pressed("click") && !clicked:
		clicked = true
		var player = ($Player.position - Vector2(32,32)) / 64
		var mouse = get_global_mouse_position() / 64
		mouse.x = floor(mouse.x)
		mouse.y = floor(mouse.y)
		player.x = floor(player.x)
		player.y = floor(player.y)
		var newpath = astar.get_point_path(player.y * (maxX + 1) + player.x, mouse.y * (maxX + 1) + mouse.x)
		if len(newpath) > 0:
			path = newpath
			arrived = false
			t = 0
			u = 0
	elif Input.is_action_just_released("click"):
		clicked = false
		
	if !arrived:
		$Player.position = (path[u] * 64 ).linear_interpolate(path[u+1] * 64 , t)+ Vector2(32,32)
		t += 0.1
		if t >= 1:
			t -= 1;
			u += 1
			if u == len(path) - 1:
				arrived = true
