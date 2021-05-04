extends Node2D
onready var destroy_timer = get_node("Destroy Timer")
onready var shot_line = get_node("Shot Line")
onready var hit_scanner = get_node("Hit Scanner")

func _ready():
	destroy_timer.connect("timeout",self,"queue_free")
	hit_scanner.force_raycast_update()
	if(hit_scanner.is_colliding()):
		shot_line.set_point_position(1, to_local(hit_scanner.get_collision_point()) )
		var other = hit_scanner.get_collider()
		if other.has_method("shot"):
			other.shot(global_position)
	
func _process(delta):
	shot_line.width = destroy_timer.time_left * 3
	shot_line.modulate.a = destroy_timer.time_left
