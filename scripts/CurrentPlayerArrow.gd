extends Sprite

onready var target_actor = get_parent()

func set_target(target):
	target_actor = target

func _physics_process(delta):
	position = target_actor.position - Vector2(0,64)
