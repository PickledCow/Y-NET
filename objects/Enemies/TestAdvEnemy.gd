extends "res://scripts/BasicEnemy.gd"

func _ready():
	walkTime = 0.001

func chooseMove(root):
	var validSpot = false
	var pos = (position - Vector2(32,32)) / 64
	pos.x = floor(pos.x)
	pos.y = floor(pos.y)
	var closestPlayer = 0
	var closestPosition = 0
	for p in root.players:
		var distance = position.distance_squared_to(p.position)
		if closestPosition == 0 || distance <= closestPosition:
			closestPosition = distance
			closestPlayer = p
	var playerPos = (closestPlayer.position - Vector2(32,32)) / 64
	var x = floor(playerPos.x) + sign(pos.x - playerPos.x)
	var y = floor(playerPos.y) + sign(pos.y - playerPos.y)
	var path = root.astar.get_point_path(pos.y * (root.maxX + 1) + pos.x, y * (root.maxX + 1) + x)
	if len(path) >= 2 && len(path) <= root.currentTurnTime / walkTime + 1 && root.isTileFree(x, y):
		return ["move", path, true]
	root.createBubbleText("[center][shake rate=25 level=30]I'm lost :(", position, false)
	return ['hate', null, true]
