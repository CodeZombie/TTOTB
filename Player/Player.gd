extends "res://Actor/Actor.gd"
onready var path_checker = get_node("PathChecker")

func _ready():
	get_node("Arm/Hand/Gun").connect_signals(self)

func _process(delta):
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
