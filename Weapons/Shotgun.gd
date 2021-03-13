extends "res://Weapons/Gun.gd"

func fire_round():
	create_muzzleflash()
	create_bullet(rand_range(-.1, .1))
	create_bullet(rand_range(-.1, .1))
	create_bullet(rand_range(-.1, .1))
	rate_of_fire_wait(1)
	gunshot_sound_player.play()
	self.position.x -= 12
