extends Node2D

func init(text, pos):
	position = pos + Vector2(32,32)
	$RichTextLabel.bbcode_text = '[center]' + text


var fadeTimer = 1.5

func _process(delta):
	
	scale = get_parent().get_node('Camera').zoom
	
	modulate.a = min(fadeTimer, 1.0)
	
	position.y -= delta*32*scale.y
	fadeTimer -= delta
	if fadeTimer <= 0:
		queue_free()
