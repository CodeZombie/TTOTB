extends Node2D
onready var shotLine = get_node("ShotLine")
onready var hitParticle = get_node("HitParticle")
onready var destroyTimer = get_node("Destroy Timer")
var muzzlePosition = Vector2(0,0)

func _ready():
	shotLine.set_point_position(0, muzzlePosition - get_global_position())
	hitParticle.look_at(muzzlePosition - get_global_position())
	destroyTimer.connect("timeout",self,"destroy")
	pass # Replace with function body.

func _process(delta):
	shotLine.modulate.a -= 0.3
	pass

func set_muzzle_position(mp):
	muzzlePosition = mp
	pass

func destroy():
	queue_free()
