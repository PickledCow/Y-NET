extends CanvasLayer

onready var timeBar = get_node("TimeBar")
onready var timeText = get_node("TimeText")

onready var skipButton = get_node("SkipTurnButton")

func updateTimeBar(time, maxTime):
	timeBar.max_value = maxTime
	timeBar.value = time
	
	timeText.bbcode_text = str(time) + ' / ' + str(maxTime)

func disableUI():
	skipButton.disabled = true
	
func enableUI():
	skipButton.disabled = false
	
