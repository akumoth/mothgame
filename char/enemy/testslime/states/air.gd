extends EnemyState

var query: PhysicsRayQueryParameters2D
var space_state: PhysicsDirectSpaceState2D
var jump_target: Vector2
var jumped: bool
var player: CharacterBody2D

func enter(_msg := {}) -> void:
	var player = get_tree().get_nodes_in_group("Player")[0]
	if !enemy.hostile:
		if enemy.wall_detector[0].has_overlapping_bodies():
			enemy.direction.x = 1
		elif enemy.wall_detector[1].has_overlapping_bodies():
			enemy.direction.x = -1
		else:
			enemy.direction.x = [-1,1][enemy.state_rng.randi() % 2]
	elif enemy.hostile:
		enemy.direction.x = round(enemy.position.direction_to(player.position).x)
		enemy.direction.x = ([-1,1][enemy.state_rng.randi() % 2] if enemy.direction.x == 0 else enemy.direction.x)
	space_state = enemy.get_world_2d().direct_space_state
	if _msg.has("do_jump"):
		jumped = false
	else:
		jumped = true
	pass

func physics_update(delta):
	var player = get_tree().get_nodes_in_group("Player")[0]
	enemy.sprite.scale.x = lerp(enemy.sprite.scale.x,.05*enemy.direction.x,0.2)
	enemy.sprite.scale.y = lerp(enemy.sprite.scale.y,1.8,0.2)
	if (jumped == true and enemy.is_on_floor()):
			state_machine.transition_to('Transform')
	if jumped == false:
		if !enemy.hostile:
			jump_target = enemy.position
			for i in range(400,51,-50):
				var query = PhysicsRayQueryParameters2D.create(
					Vector2(enemy.position.x+(i*enemy.direction.x),
							enemy.position.y), 
					# Do this routine backwards i.e. check if position is valid and if so, jump
					# as opposed to checking every position from the current one to the last possible
					# one 
					Vector2(enemy.position.x+(i)*enemy.direction.x,
							enemy.position.y+(500)))
				var result = space_state.intersect_ray(query)
				if result.has('position'):
					jump_target = Vector2(enemy.position.x+(i*enemy.direction.x),
										result.position.y)
					break
				if i < 51:
					state_machine.transition_to('Idle')
			enemy.velocity = Vector2(
				((clamp(abs(enemy.position.x - jump_target.x - (enemy.position.y - jump_target.y)/100),0,400)*enemy.direction.x)*enemy.gravity)/(2*700),
				-700
			)
		elif enemy.hostile:
			jump_target = player.position
			enemy.velocity = Vector2(
				(((clamp(abs(enemy.position.x - jump_target.x - (enemy.position.y - jump_target.y)/100),0,600))*enemy.gravity)/(2*700)+200)*enemy.direction.x,
				-400
			)
			pass
		jumped = true
		
	

