extends Node2D

func init(text, pos):
	position = pos + Vector2(32,32)
	$RichTextLabel.bbcode_text = '[center]' + text


var fade_timer = 1.5

func _process(delta):
	
	scale = get_parent().get_node('Camera').zoom
	
	modulate.a = min(fade_timer, 1.0)
	
	position.y -= delta*32*scale.y
	fade_timer -= delta
	if fade_timer <= 0:
		queue_free()
