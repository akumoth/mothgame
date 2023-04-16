extends PlayerState

var initial_dir: int
var initial_vel: int
var grace_period := Timer.new()
var can_transition: bool
var space_state: PhysicsDirectSpaceState2D
var result: Dictionary

func _ready() -> void:
	super()
	add_child(grace_period)
	grace_period.one_shot = true
	grace_period.connect('timeout', self._on_grace_timeout)
	grace_period.process_callback = 0
	pass

func enter(_msg := {}) -> void:
	player.anim.set('parameters/dashing/transition_request', 'dash')
	grace_period.wait_time = 0.6
	grace_period.start()
	initial_dir = player.direction.x
	if abs(player.velocity.x) < player.dash_speed:
		initial_vel = player.dash_speed
	else:
		initial_vel = abs(player.velocity.x)
	can_transition = true
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta):
	var space_state = player.get_world_2d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(player.position, Vector2(player.position.x,player.position.y-500)))

	can_transition = !player.ceil_detector.is_colliding()
	if Input.is_action_just_pressed("ui_up") and can_transition:
		state_machine.transition_to("Air", {do_jump = true})
	
	if not player.is_on_floor():
		player.velocity.y += _delta * (2*player.gravity)/3
		return
	player.velocity.x = initial_vel * (player.direction.x if player.direction.x != 0.0 else player.sprite.scale.x)
	
	if player.direction.x != 0:
		if player.direction.x > 0:
			player.sprite.scale.x = 1
			player.hurtbox.scale.x = 1
			player.hitbox.scale.x = 1
		elif player.direction.x < 0:
			player.sprite.scale.x = -1
			player.hurtbox.scale.x = -1
			player.hitbox.scale.x = -1
	pass

func _on_grace_timeout():
	if can_transition:
		if !player.is_on_floor():
			state_machine.transition_to("Air")
		elif (player.direction.x != 0.0 and Input.is_action_pressed("run")):
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Walk")
	else:
		grace_period.wait_time = clamp(grace_period.get_time_left(),0.5,0.6)
		grace_period.start()
		

func exit() -> void:
	grace_period.stop()
	player.anim.set('parameters/dashing/transition_request', 'idle')
	pass

