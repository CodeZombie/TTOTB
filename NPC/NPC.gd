extends "res://Actor/Actor.gd"
onready var state_machine =  FiniteStateMachine.new()

var wander_direction = 1

func state_wander() -> void:
	if(randf() > 0.98):
		wander_direction = round((randi() % 3) - 1)
	if(randf() > 0.99):
		if(is_on_floor()):
			jump()
	walk(wander_direction)
	
	if(wander_direction == -1):
		arm.set_rotation(-3.14159)
	elif(wander_direction == 1):
		arm.set_rotation(0)
		
	if(randf() > 0.985):
		emit_signal("hold_trigger")
	if(randf() > .5):
		emit_signal("release_trigger")


func _ready():
	get_node("Arm/Hand/Gun").connect_signals(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state_wander()
