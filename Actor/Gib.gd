extends RigidBody2D
export var gravity = 800
onready var sprite = get_node("Sprite")
var velocity = Vector2(0,0)


func _ready():
	pass

func initialize(parent_global_position, frames, scale_, area, texture_, direction_, speed_, flip_h):
	var gibSprite = get_node("Sprite")
	var collisionShape = get_node("CollisionShape2D")
	gibSprite.texture = texture_
	gibSprite.flip_h = flip_h
	gibSprite.hframes = frames.x
	gibSprite.vframes = frames.y
	gibSprite.frame = rand_range(0, (frames.x * frames.y) - 1)
	gibSprite.scale = scale_
	collisionShape.scale = scale_
	position.x = parent_global_position.x + (area.x * randf()) - area.x/2
	position.y = parent_global_position.y + (area.y * randf()) - area.y/2
	direction_.x += rand_range(-1, 1)
	direction_.y += rand_range(-1, 1)
	direction_ = direction_.normalized()
	apply_impulse(Vector2(0,0), direction_ * speed_)
	gibSprite.modulate = gibSprite.modulate.darkened(rand_range(0, .7))

func _process(dt):
	sprite.modulate.a -= dt * .25
	if sprite.modulate.a <= 0:
		get_parent().remove_child(self)
