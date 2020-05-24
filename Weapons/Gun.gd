extends Node2D
onready var Muzzleflash = preload("res://Weapons/MuzzleFlash.tscn")
onready var Bullet = preload("res://Weapons/Bullet.tscn")

onready var sprite_container = get_node("Sprite Container")
onready var gunshot_sound_player = get_node("GunshotPlayer2d")
onready var rate_of_fire_timer = get_node("RateOfFireTimer")
onready var muzzle = get_node("Sprite Container/Muzzle")

var equipped = false
var gunLogic =  FiniteStateMachine.new()

var trigger_pressed = false

# STATES:	
func enter_state_fire_round():
	var muzzle_flash = Muzzleflash.instance()
	muzzle_flash.position = to_local(muzzle.get_global_position())
	add_child(muzzle_flash)
	
	var bullet = Bullet.instance()
	bullet.position = muzzle.get_global_position()
	bullet.rotation = get_global_rotation()
	get_tree().get_root().add_child(bullet)
	
	rate_of_fire_timer.start()
	gunshot_sound_player.play()
	
	sprite_container.position.x = -2
	
func is_equipped():
	return equipped
	
func is_holding_trigger():
	#if equipped:
	if trigger_pressed:
		return true
	return false
	
func is_finished_firing_round():
	return rate_of_fire_timer.is_stopped()

func _ready():
	equipped = true
	gunLogic.register_state(self, "can_fire", null)
	gunLogic.register_state(self, "fire_round", null, "enter_state_fire_round")
	gunLogic.register_transition(self, "can_fire", "fire_round", "is_holding_trigger")
	gunLogic.register_transition(self, "fire_round", "can_fire", "is_finished_firing_round")
	pass # Replace with function body.

func connect_signals(parent):
	parent.connect("hold_trigger", self, "on_hold_trigger")
	parent.connect("release_trigger", self, "on_release_trigger")
	
func on_hold_trigger():
	trigger_pressed = true
	
func on_release_trigger():
	trigger_pressed = false

func _process(delta):
	sprite_container.position = sprite_container.position.linear_interpolate(position, delta * 10)
	gunLogic.update()
	
	var real_rotation = abs(int(rad2deg(global_rotation)) % 360)

	if(real_rotation > 90 and real_rotation < 270):
		sprite_container.set_scale(Vector2(1, -1))
	else:
		sprite_container.set_scale(Vector2(1, 1))
