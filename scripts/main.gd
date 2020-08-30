extends Node2D

onready var tilemap = get_node("TileMap")

var maxTurnTime = 100

var maxX = 0
var maxY = 0
var astar
var path

var bubbleTextPrefab = preload("res://objects/PopupText.tscn")

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

func createBubbleText(text, pos, disco):
	var bubbleText = bubbleTextPrefab.instance()
	var displayText = ''
	if disco: displayText += '[rainbow freq=0.1][wave amp=256 freq=12]'
	displayText += text
	bubbleText.init(displayText, pos)
	add_child(bubbleText)



var players = []

var enemies = []

var currentPlayer = 0

func _ready():
	astar = generateAStar()
	path = astar.get_point_path(maxX + 2, maxX + 2)	
	for child in $Players.get_children():
		players.append(child)
	for child in $Enemies.get_children():
		enemies.append(child)
	$Camera.warpToPosition(players[currentPlayer].position)
		
var t = 0
var u = 0
var arrived = true

func _physics_process(delta):
	var valid = true
	if arrived:
		if Input.is_action_just_pressed("click"):
			var player = players[currentPlayer]
			var playerpos = (player.position - Vector2(32,32)) / 64
			var mouse = get_global_mouse_position() / 64
			playerpos.x = floor(playerpos.x)
			playerpos.y = floor(playerpos.y)
			mouse.x = floor(mouse.x)
			mouse.y = floor(mouse.y)
			
			var occupied = false
			var tooFar = false
			
			for p in players + enemies:
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
				
			if (len(newpath)-1) * player.walkTime > maxTurnTime:
				tooFar = true
				
			if mouse.x < 0 || mouse.x > maxX:
				valid = false
			
			if valid && !tooFar && !occupied:
				$Cursor.validTile()
				path = newpath
				arrived = false
				t = 0
				u = 0
			else:
				$Cursor.invalidTile(len(newpath)-1, maxTurnTime / player.walkTime, !valid, occupied, tooFar)
			
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
				$Cursor.enableCursor()
				

