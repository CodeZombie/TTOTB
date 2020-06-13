extends Node2D
onready var right_ray_cast = get_node("RightRayCast")
onready var left_ray_cast = get_node("LeftRayCast")

#up right ray: checks to make sure there is enough clearance for the NPC to fit inside of.


func _ready():
	pass

func _process(delta):
	pass
	
	
func can_move_right():
	#check the down_right ray.
	#if the down_right ray returns a location that requires jumping:
	#	move the origin of the up_right ray to the down_right location.
	#	check the up right ray. make sure there is no collision.
	#
	pass
func set_enabled(val):
	right_ray_cast.enabled = val
	left_ray_cast.enabled = val
	
#returns the coordinates the actor will land if they move to the right.
func get_travel_right_global_position():
	return right_ray_cast.get_collision_point()
		
func get_travel_left_global_position():
	return left_ray_cast.get_collision_point()
