extends "res://Weapons/Gun.gd"

func fire_round():
	create_muzzleflash()
	create_bullet()
	rate_of_fire_wait(.1 + rand_range(-0.05, .05))
	gunshot_sound_player.play()
	self.position.x -= 3
