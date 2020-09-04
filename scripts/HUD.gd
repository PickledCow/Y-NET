extends CanvasLayer

onready var time_bar = get_node("TimeBar")
onready var time_text = get_node("TimeText")

onready var skip_button = get_node("SkipTurnButton")

func update_time_bar(time, max_time):
	time_bar.max_value = max_time
	time_bar.value = time
	
	time_text.bbcode_text = str(time) + ' / ' + str(max_time)

func disable_UI():
	skip_button.disabled = true
	
func enable_UI():
	skip_button.disabled = false
	
