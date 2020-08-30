extends Camera2D

var freeMove = true
var targetPosition = Vector2()
var targetReached = true

var mouseLastPosition = Vector2()

func _process(delta):
	$AmbientLight.scale = zoom
	$AmbientLight.position = offset
	if freeMove:
		var move = Vector2()
		if Input.is_action_pressed("cameraUp"): move.y -= 1
		if Input.is_action_pressed("cameraDown"): move.y += 1
		if Input.is_action_pressed("cameraLeft"): move.x -= 1
		if Input.is_action_pressed("cameraRight"): move.x += 1
		move = move.normalized()
		
		position += move * 1000 * delta * sqrt(zoom.x)
		
		if Input.is_action_just_pressed("cameraDrag"):
			mouseLastPosition = get_viewport().get_mouse_position()
		
		if Input.is_action_pressed("cameraDrag"):
			position += (mouseLastPosition - get_viewport().get_mouse_position()) * zoom.x
			mouseLastPosition = get_viewport().get_mouse_position()
		
		position = Vector2(clamp(position.x, -offset.x, get_parent().maxX*64 - offset.x),clamp(position.y, -offset.y, get_parent().maxY*64 - offset.y))
	
	if !targetReached:
		position = position.linear_interpolate(targetPosition, exp(-88 * delta))
		
		if position.distance_squared_to(targetPosition) < 100:
			position = targetPosition
			targetReached = true
			freeMove = true

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			var mousePos = get_global_mouse_position()
			offset += position - mousePos
			offset *= 0.9
			position = mousePos
			zoom *= 0.9
			if zoom.x < 0.25:
				var multiplier = 0.25 / zoom.x
				zoom *= multiplier
				offset *= multiplier
		if event.button_index == BUTTON_WHEEL_DOWN:
			var mousePos = get_global_mouse_position()
			offset += position - mousePos
			offset *= 1.1
			position = mousePos
			zoom *= 1.1
			if zoom.x > 5:
				var multiplier = 5 / zoom.x
				zoom *= multiplier
				offset *= multiplier


func warpToPosition(position):
	targetPosition = position
	targetReached = false
	self.position += offset
	offset = Vector2(0, 0)
	freeMove = false
