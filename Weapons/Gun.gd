extends Node2D
onready var spriteContainer = get_node("Sprite Container")
onready var gunSprite = get_node("Sprite Container/Gun Sprite")
onready var gunOutline = get_node("Sprite Container/Gun Outline")
onready var gunshotSoundPlayer = get_node("GunshotPlayer2d")
onready var hitScanner = get_node("Sprite Container/HitScanner")
onready var rateOfFireTimer = get_node("RateOfFireTimer")
onready var Muzzleflash = preload("res://Weapons/MuzzleFlash.tscn")
onready var BulletHit = preload("res://Weapons/BulletHit.tscn")
var equipped = false
var gunLogic =  FiniteStateMachine.new()

# STATES:	
func enter_state_fire_round():
	var mf = Muzzleflash.instance()
	mf.position.x = 24
	add_child(mf)
	rateOfFireTimer.start()
	gunshotSoundPlayer.play()
	#Enable the hitscanner
	hitScanner.enabled = true
	
func is_equipped():
	return equipped
	
func is_holding_trigger():
	if(Input.is_action_pressed("ui_click")):
		return true
	return false
	
func is_finished_firing_round():
	return rateOfFireTimer.is_stopped()


func _ready():
	equipped = true
	gunLogic.register_state(self, "can_fire", null)
	gunLogic.register_state(self, "fire_round", null, "enter_state_fire_round")
	gunLogic.register_transition(self, "can_fire", "fire_round", "is_holding_trigger")
	gunLogic.register_transition(self, "fire_round", "can_fire", "is_finished_firing_round")
	pass # Replace with function body.


func _process(delta):
	if(hitScanner.enabled):
		if(hitScanner.is_colliding()):
			var bulletHit = BulletHit.instance()
			bulletHit.position = hitScanner.get_collision_point()
			var direction = Vector2( cos(get_global_rotation()), sin(get_global_rotation()) )
			bulletHit.set_muzzle_position(get_global_position() + (direction * 24) )
			
			get_tree().get_root().add_child(bulletHit)
	hitScanner.enabled = false
			
	gunLogic.update()
	look_at(get_global_mouse_position())
	var real_rotation = abs(int(rad2deg(global_rotation)) % 360)

	if(real_rotation > 90 and real_rotation < 270):
		gunSprite.set_flip_v(true)
		gunOutline.set_flip_v(true)
		spriteContainer.position.y = -1
	else:
		gunSprite.set_flip_v(false)
		gunOutline.set_flip_v(false)
		spriteContainer.position.y = 1
