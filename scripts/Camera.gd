extends Camera2D

var freeMove = true

func _process(delta):
	if freeMove:
		var move = Vector2()
		if Input.is_action_pressed("cameraUp"): move.y -= 1
		if Input.is_action_pressed("cameraDown"): move.y += 1
		if Input.is_action_pressed("cameraLeft"): move.x -= 1
		if Input.is_action_pressed("cameraRight"): move.x += 1
		move = move.normalized()
		
		position += move * 1000*delta
		position = Vector2(clamp(position.x, 0, get_parent().maxX*64),clamp(position.y, 0, get_parent().maxY*64))
		
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom -= Vector2(1,1) * 0.1
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom += Vector2(1,1) * 0.1

func warpToPosition(position):
	position = position
	freeMove = false
