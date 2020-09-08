extends CanvasLayer

onready var time_bar = get_node("TimeBar")
onready var time_text = get_node("TimeText")

onready var idle = get_node("Idle")
onready var walk = get_node("Walk")
onready var run = get_node("Run")
onready var shoot = get_node("Shoot")
onready var crouch = get_node("Crouch")
onready var guard = get_node("Guard")
onready var next_enemy = get_node("NextEnemy")
onready var prev_enemy = get_node("PreviousEnemy")


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
	next_enemy.disabled = true
	prev_enemy.disabled = true
	
func enable_UI():
	skip_button.disabled = false
	idle.disabled = false
	walk.disabled = false
	run.disabled = crouch.pressed
	shoot.disabled = false
	crouch.disabled = false
	guard.disabled = false
	next_enemy.disabled = false
	prev_enemy.disabled = false

func reset_UI():
	enable_UI()
	match get_parent().player_action:
		CONSTS.ACTION.IDLE:
			idle.pressed = true
		CONSTS.ACTION.RUNNING:
			run.pressed = true
		CONSTS.ACTION.WALKING:
			walk.pressed = true
		CONSTS.ACTION.SHOOTING:
			shoot.pressed = true
	crouch.pressed = get_parent().players[get_parent().current_player].crouching
	guard.pressed = false


func crouch_pressed(button_pressed):
	if run.pressed && button_pressed:
		walk.pressed = true
	run.disabled = button_pressed
