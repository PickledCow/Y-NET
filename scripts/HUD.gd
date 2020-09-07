extends CanvasLayer

onready var time_bar = get_node("TimeBar")
onready var time_text = get_node("TimeText")

onready var idle = get_node("Idle")
onready var walk = get_node("Walk")
onready var run = get_node("Run")
onready var shoot = get_node("Shoot")
onready var crouch = get_node("Crouch")
onready var guard = get_node("Guard")


onready var skip_button = get_node("SkipTurnButton")

func update_time_bar(time, max_time):
	time_bar.max_value = max_time
	time_bar.value = time
	
	time_text.bbcode_text = str(time) + ' / ' + str(max_time)

func disable_UI():
	skip_button.disabled = true
	idle.disabled = true
	walk.disabled = true
	run.disabled = true
	shoot.disabled = true
	crouch.disabled = true
	guard.disabled = true
	
func enable_UI():
	skip_button.disabled = false
	idle.disabled = false
	walk.disabled = false
	run.disabled = crouch.pressed
	shoot.disabled = false
	crouch.disabled = false
	guard.disabled = false

func reset_UI():
	enable_UI()
	idle.pressed = true
	crouch.pressed = get_parent().players[get_parent().current_player].crouching
	guard.pressed = false


func crouch_pressed(button_pressed):
	if run.pressed && button_pressed:
		walk.pressed = true
	run.disabled = button_pressed
