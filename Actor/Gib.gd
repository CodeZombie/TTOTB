extends RigidBody2D
export var gravity = 800
onready var sprite = get_node("Sprite")
var velocity = Vector2(0,0)


func _ready():
	pass

func initialize(parent_global_position, hframes, vframes, scale_, chunkIndex_, texture_, direction_, speed_, flip_h):
	var gibSprite = get_node("Sprite")
	var collisionShape = get_node("CollisionShape2D")
	gibSprite.texture = texture_
	gibSprite.frame = chunkIndex_
	gibSprite.hframes = hframes
	gibSprite.vframes = vframes
	gibSprite.scale.x = scale_
	gibSprite.scale.y = scale_
	gibSprite.flip_h = flip_h
	collisionShape.scale.x = scale_
	collisionShape.scale.y = scale_
	var gibTextureWidth = texture_.get_width()
	var gibTextureHeight = texture_.get_height()
	position.x = (parent_global_position.x - gibTextureWidth/2) + (chunkIndex_ % hframes * ((gibTextureWidth * scale_)/hframes))
	position.y = (parent_global_position.y - gibTextureHeight/2) + (floor(chunkIndex_ / hframes) * ((gibTextureHeight * scale_)/vframes))
	direction_.x += rand_range(-1, 1)
	direction_.y += rand_range(-1, 1)
	direction_ = direction_.normalized()
	apply_impulse(Vector2(0,0), direction_ * speed_)

func _process(dt):
	sprite.modulate.a -= dt * .25
	if sprite.modulate.a <= 0:
		get_parent().remove_child(self)
