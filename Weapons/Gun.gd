extends Node2D
onready var Muzzleflash = preload("res://Weapons/MuzzleFlash.tscn")
onready var Bullet = preload("res://Weapons/Bullet.tscn")

onready var sprite_container = get_node("Sprite Container")
onready var gunshot_sound_player = get_node("GunshotPlayer2d")
onready var rate_of_fire_timer = get_node("RateOfFireTimer")
onready var muzzle = get_node("Sprite Container/Muzzle")

onready var collisionshape = get_node("CollisionShape2D")

var equipped = false

var trigger_pressed = false

# STATES:	
func fire_round():
	var muzzle_flash = Muzzleflash.instance()
	muzzle_flash.position = to_local(muzzle.get_global_position())
	add_child(muzzle_flash)
	
	var bullet = Bullet.instance()
	bullet.position = muzzle.get_global_position()
	
	bullet.rotation = self.global_rotation #get_global_rotation()
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
	on_equip()

func connect_signals(parent):
	parent.connect("hold_trigger", self, "on_hold_trigger")
	parent.connect("release_trigger", self, "on_release_trigger")
	
	parent.connect("drop_item", self, "on_drop")
	parent.connect("equip_item", self, "on_equip")
	print("Attached signals.")
	
func on_hold_trigger():
	trigger_pressed = true
	
func on_release_trigger():
	trigger_pressed = false

func on_equip():
	self.mode = RigidBody2D.MODE_STATIC
	equipped = true
	collisionshape.disabled = true
	
func on_drop():
	#detach all signals.
	#enable collision with world
	
	#re-parent to root
	#preserve position
	var current_position = self.global_position
	var new_parent = get_tree().get_root()
	self.get_parent().remove_child(self)
	new_parent.add_child(self)
	self.position = current_position
	collisionshape.disabled = false
	
	self.mode = RigidBody2D.MODE_RIGID
	equipped = false

func _process(delta):
	if equipped:
		sprite_container.position = sprite_container.position.linear_interpolate(position, delta * 10)
		
		var real_rotation = abs(int(rad2deg(global_rotation)) % 360)
	
		if(real_rotation > 90 and real_rotation < 270):
			sprite_container.set_scale(Vector2(1, -1))
		else:
			sprite_container.set_scale(Vector2(1, 1))
