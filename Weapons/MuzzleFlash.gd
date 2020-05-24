extends Sprite
onready var destroy_timer = get_node("Destroy Timer")
# Called when the node enters the scene tree for the first time.
func _ready():
	frame = randi() % 2
	destroy_timer.connect("timeout",self,"destroy")
	
func _process(delta):
	scale.y = destroy_timer.time_left * 32
	
	#modulate.a = destroy_timer.time_left

func destroy():
	queue_free()
