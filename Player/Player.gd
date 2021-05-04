extends "res://Actor/Actor.gd"

func _ready():
	#equip(get_node("Arm/Hand/Gun"))
	pass
	
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
		
	if Input.is_action_just_pressed("pickup_item"):
		if equipped_item:
			drop()
		else:
			var pickupable = get_pickupable_items()
			if pickupable.size() > 0:
				equip(pickupable[0])
