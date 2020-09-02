extends Node2D

onready var tilemap = get_node("TileMap")
onready var mapoutline = get_node("Outline")

var maxTurnTime = 100
var currentTurnTime = 100

var maxX = 0
var maxY = 0
var astar
var path

# Popup text prefab
var bubbleTextPrefab = preload("res://objects/PopupText.tscn")

func generateAStarAndOutline():
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

# text: the text of the text (lel); pos: where to spawn the text; disco: optional, makes the text go crazy
func createBubbleText(text, pos, disco=false):
	var bubbleText = bubbleTextPrefab.instance()
	var displayText = ''
	if disco: displayText += '[rainbow freq=0.1][wave amp=256 freq=12]'
	displayText += text
	bubbleText.init(displayText, pos)
	add_child(bubbleText)



var players = []
var currentPlayer = 0

var enemies = []
var currentEnemy = 0


func _ready():
	astar = generateAStarAndOutline()
	for child in $Players.get_children():
		players.append(child)
	for child in $Enemies.get_children():
		enemies.append(child)
		
	$Camera.warpToPosition(players[currentPlayer].position)

# Check if tile isn't obstructed, the master tile check function, 
# call this function most of the time but feel free to call the others as well
func isTileFree(x, y):
	var valid = true
	if !isTileInBound(x, y):
		valid = false
	if !isTileFloor(x, y):
		valid = false
	if isTileOccupied(x, y):
		valid = false
	return valid

func isTileInBound(x, y):
	var valid = true
	if x < 0 || x > maxX:
		valid = false
	if y < 0 || y > maxY:
		valid = false
	return valid

func isTileFloor(x, y):
	return tilemap.get_cell(x, y) in tilemap.floors

func isTileWall(x, y):
	return tilemap.get_cell(x, y) in tilemap.walls

func isTileOccupied(x, y):
	var valid = false
	
	for i in players + enemies:
		var pos = (i.position - Vector2(32,32)) / 64
		pos.x = floor(pos.x)
		pos.y = floor(pos.y)
		if (Vector2(x, y) == pos):
			valid = true
			break
	return valid

# TODO, actually verify path
func isPathValid(path):
	return true

var acting = false
var isPlayerTurn = true
var allPlayersDead = false
var allEnemiesDead = false

var enemyWalking = false

func _physics_process(delta):
	if !allPlayersDead:
		if isPlayerTurn:
			if !acting:
				choose_dest_current_player()
				shoot_current_player()
			else:
				move_actor(players[currentPlayer])
		else:
			if !acting:
				current_enemy_move()
			elif enemyWalking:
				move_actor(enemies[currentEnemy])

func choose_dest_current_player():
	var valid = true
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
			
		if (len(newpath)-1) * player.walkTime > maxTurnTime:
			tooFar = true
			
		if mouse.x < 0 || mouse.x > maxX:
			valid = false
		
		if valid && !tooFar && !occupied:
			$Cursor.validTile()
			path = newpath
			acting = true
			t = 0
			u = 0
		else:
			$Cursor.invalidTile(len(newpath)-1, maxTurnTime / player.walkTime, !valid, occupied, tooFar)
		
func shoot_current_player():
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

var t = 0 # Timer walking between the tiles (micro scope)
var u = 0 # Tiemr walking through the tiles (macro scope)
	
func move_actor(actor):
	$Camera.warpToPosition(actor.position)
	actor.position = (path[u] * 64 ).linear_interpolate(path[u+1] * 64 , t) + Vector2(32,32)
	t += 0.1
	if t >= 1:
		t -= 1;
		u += 1
		if u == len(path) - 1:
			endTurn()
	
func endTurn():
	acting = false

	if !isPlayerTurn:
		var startingPlayer = currentPlayer
		currentPlayer = (currentPlayer + 1) % len(players)
		while players[currentPlayer].dead:
			currentPlayer = (currentPlayer + 1) % len(players)
			if currentPlayer == startingPlayer:
				allPlayersDead = true
				print("gameover")
				break

		$Camera.warpToPosition(players[currentPlayer].position)
		$Cursor.enableCursor()
	else:
		enemyWalking = false
		
		var startingEnemy = currentEnemy
		currentEnemy = (currentEnemy + 1) % len(enemies)
		while enemies[currentEnemy].dead:
			currentEnemy = (currentEnemy + 1) % len(enemies)
			if currentEnemy == startingEnemy:
				allEnemiesDead = true
				print("ct win")
				break
				
		$Camera.warpToPosition(enemies[currentEnemy].position)
		$Cursor.disableCursor()
	
	isPlayerTurn = !isPlayerTurn
	
	t = 0
	u = 0

func current_enemy_move():
	var enemy = enemies[currentEnemy]
	var endOfTurn = false
	while !endOfTurn:
		var move = enemy.chooseMove(self)
		endOfTurn = move[2]
		match move[0]:
			"move":
				if isPathValid(move):
					path = move[1]
					acting = true
					enemyWalking = true
			_:
				endOfTurn = true
				endTurn()
	

	
	
