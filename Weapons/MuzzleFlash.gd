extends Sprite
onready var destroyTimer = get_node("Destroy Timer")
# Called when the node enters the scene tree for the first time.
func _ready():
	frame = randi() % 2
	destroyTimer.connect("timeout",self,"destroy")

func destroy():
	queue_free()
