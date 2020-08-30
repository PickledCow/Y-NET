extends Sprite

var redFadeTimer = 0
var redFadeTime = 1

var canUpdate = true

func _process(delta):
	if canUpdate:
		var mouse = get_global_mouse_position() / 64
		mouse.x = floor(mouse.x)
		mouse.y = floor(mouse.y)
		position = mouse * 64
		
		if get_parent().tilemap.get_cell(mouse.x, mouse.y) in get_parent().tilemap.floors:
			modulate = Color(1,1,1,1)
		else:
			modulate = Color(1,0,0,1)
			
		if redFadeTimer > 0:
			modulate = Color(1, (redFadeTime-redFadeTimer)/redFadeTime, (redFadeTime-redFadeTimer)/redFadeTime, 1)
			redFadeTimer -= delta
			if redFadeTimer < 0:
				modulate = Color(1,1,1,1)
		

func invalidTile():
	redFadeTimer = redFadeTime

func validTile():
	canUpdate = false
	modulate = Color(0,1,0,1)

func enableCursor():
	canUpdate = true
