extends Sprite

var red_fade_timer = 0
var red_fade_time = 1

var can_update = true

func _process(delta):
	if can_update:
		if CONSTS.CURSOR_RANGE.has_point(get_viewport().get_mouse_position()):
			var mouse = get_global_mouse_position() / 64
			mouse.x = floor(mouse.x)
			mouse.y = floor(mouse.y)
			position = mouse * 64
			
			if get_parent().tilemap.get_cell(mouse.x, mouse.y) in get_parent().tilemap.floors:
				modulate = Color(1,1,1,1)
			else:
				modulate = Color(1,0,0,1)
				
			if red_fade_timer > 0:
				modulate = Color(1, (red_fade_time-red_fade_timer)/red_fade_time, (red_fade_time-red_fade_timer)/red_fade_time, 1)
				red_fade_timer -= delta
				if red_fade_timer < 0:
					modulate = Color(1,1,1,1)
			

func invalid_tile(dist, maxDist, invalid, occupied, tooFar):
	red_fade_timer = red_fade_time
	var text = "You can't go there"
	if invalid:
		pass
	elif tooFar:
		text = 'Tile too far away.\nCurrent: ' + str(dist) + "; Max: " + str(maxDist)
	elif occupied:
		text = 'Tile is already occupied'
	get_parent().create_bubble_text(text, position, randi()%20 == 0)

func valid_tile():
	can_update = false
	modulate = Color(0,1,0,1)

func enable_cursor():
	can_update = true
	modulate = Color(1,1,1,1)

func disable_cursor():
	can_update = false
	modulate = Color(1,1,1,0)
