extends Camera2D

const CAMERA_CENTRE_OFFSET = Vector2(-200,0)

var free_move = true
var target_actor
var target_reached = true

var mouse_last_position = Vector2()

func _process(delta):
	$AmbientLight.scale = zoom
	$AmbientLight.position = offset
	if free_move:
		var move = Vector2()
		if Input.is_action_pressed("cameraUp"): move.y -= 1
		if Input.is_action_pressed("cameraDown"): move.y += 1
		if Input.is_action_pressed("cameraLeft"): move.x -= 1
		if Input.is_action_pressed("cameraRight"): move.x += 1
		move = move.normalized()
		
		position += move * 1000 * delta * sqrt(zoom.x)
		
		if Input.is_action_just_pressed("cameraDrag") || (get_parent().player_action == CONSTS.ACTION.IDLE && Input.is_action_just_pressed("click")):
			mouse_last_position = get_viewport().get_mouse_position()
		
		if Input.is_action_pressed("cameraDrag") || (get_parent().player_action == CONSTS.ACTION.IDLE && Input.is_action_pressed("click")):
			position += (mouse_last_position - get_viewport().get_mouse_position()) * zoom.x
			mouse_last_position = get_viewport().get_mouse_position()
		
		position = Vector2(clamp(position.x, -offset.x - CAMERA_CENTRE_OFFSET.x, get_parent().maxX*64 - offset.x - CAMERA_CENTRE_OFFSET.x),clamp(position.y, -offset.y - CAMERA_CENTRE_OFFSET.y, get_parent().maxY*64 - offset.y - CAMERA_CENTRE_OFFSET.y))
	
	if !target_reached:
		position = position.linear_interpolate(target_actor.position, exp(-88 * delta))
		if target_set:
			target_set = false
		elif position.distance_squared_to(target_actor.position) < 100:
			position = target_actor.position
			target_reached = true
			free_move = true

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


var target_set = false

func set_target(target):
	target_set = true
	target_actor = target
	target_reached = false
	self.position += offset
	offset = Vector2(0, 0)
	free_move = false


