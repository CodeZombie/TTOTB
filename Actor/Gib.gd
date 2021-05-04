extends RigidBody2D
export var gravity = 800

onready var sprite = get_node("Sprite")
var spriteTexture = null
var chunkIndex = 0
var velocity = Vector2(0,0)
func _ready():
	sprite.texture = spriteTexture
	sprite.frame = chunkIndex
	pass

func initialize(chunkIndex_, texture_, velocity_):
	spriteTexture = texture_
	chunkIndex = chunkIndex_
	velocity = velocity_
	apply_impulse(Vector2(0,0), velocity_)

func _process(dt):
	sprite.modulate.a -= dt * .25
	if sprite.modulate.a <= 0:
		get_parent().remove_child(self)
