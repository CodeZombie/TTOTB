extends "res://Actor/Actor.gd"

func _ready():
	get_node("Arm/Hand/Gun").connect_signals(self)
	pass # Replace with function body.

func _process(delta):
	arm.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("ui_up"):
		jump()
		
	if Input.is_action_pressed("ui_left"):
		walk(-1)
	elif Input.is_action_pressed("ui_right"):
		walk(1)
	else:
		walk(0)
		
		
	if Input.is_action_just_pressed("ui_click"):
		emit_signal("hold_trigger")
		
	if Input.is_action_just_released("ui_click"):
		emit_signal("release_trigger")
