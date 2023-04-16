extends EnemyState

func enter(_msg := {}) -> void:
	if enemy.wall_detector[0].has_overlapping_bodies():
		enemy.direction.x = 1
	elif enemy.wall_detector[1].has_overlapping_bodies():
		enemy.direction.x = -1
	else:
		enemy.direction.x = (-1 if enemy.state_rng.randi_range(0,1) == 0 else 1)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta):
	if !enemy.platform_detector[0].is_colliding():
		enemy.direction.x = 1
		enemy.velocity.x = abs(enemy.velocity.x)
	elif !enemy.platform_detector[1].is_colliding():
		enemy.direction.x = -1 
		enemy.velocity.x = -abs(enemy.velocity.x)
		
	enemy.velocity.x += 7 * enemy.direction.x
	enemy.sprite.scale.y = lerp(enemy.sprite.scale.y,0.333,0.1)
	enemy.sprite.scale.x = lerp(enemy.sprite.scale.x,2 * enemy.direction.x,0.4) 
	enemy.sprite.offset.y = clamp(enemy.sprite.offset.y+2,0.0,50)
	if (abs(enemy.velocity.x) >= 300 or
		(enemy.wall_detector[0].has_overlapping_bodies() and enemy.direction.x < 0)
		or (enemy.wall_detector[1].has_overlapping_bodies() and enemy.direction.x > 0)
		):
		state_machine.transition_to('Transform')
	elif !enemy.is_on_floor():
		state_machine.transition_to('Air')

func exit() -> void:
	enemy.sprite.scale = Vector2(1*enemy.direction.x,1)
	enemy.sprite.offset.y = 0
