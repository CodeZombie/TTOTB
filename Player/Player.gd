extends "res://Actor/Actor.gd"

func _ready():
	get_node("Arm/Hand/Gun").connect_signals(self)
	get_node("Arm/Hand/Gun").on_equip()

func _process(delta):
	print(global_position.y)
	#if(path_checker.can_travel_right()):
	#	print(path_checker.get_travel_right_global_position())
	arm.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("ui_up"):
		jump()
	if Input.is_action_just_released("ui_up"):
		halt_jump()
	
	if Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("run"):
			run(-1)
		else:
			walk(-1)
	elif Input.is_action_pressed("ui_right"):
		if Input.is_action_pressed("run"):
			run(1)
		else:
			walk(1)
	else:
		walk(0)
		
		
	if Input.is_action_just_pressed("ui_click"):
		emit_signal("hold_trigger")
		
	if Input.is_action_just_released("ui_click"):
		emit_signal("release_trigger")
		
	if Input.is_action_just_pressed("drop_item"):
		emit_signal("drop_item")
