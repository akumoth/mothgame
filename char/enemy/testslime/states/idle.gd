extends EnemyState

# Cooldowns and timers for the different state changes
var walk_period := Timer.new()
var jump_startup_period := Timer.new()

func _ready() -> void:
	super()
	add_child(walk_period)
	add_child(jump_startup_period)
	walk_period.wait_time = 0.4
	walk_period.one_shot = true
	jump_startup_period.wait_time = 0.2
	jump_startup_period.one_shot = true
	walk_period.connect('timeout',self._on_walk_period_over)
	pass

func enter(_msg := {}) -> void:
	walk_period.start()
	enemy.ScreenNotifier.connect('screen_exited', self._on_camera_exit)
	pass
	
func physics_update(_delta) -> void:
	if !enemy.is_on_floor():
		state_machine.transition_to('Air')
		
func _on_walk_period_over() -> void:
	walk_period.wait_time = enemy.state_rng.randf_range(0.2,0.3)
	if enemy.hostile:
		state_machine.transition_to('Air', {do_jump = true})
	elif enemy.state_rng.randi_range(0,3) == 3:
		state_machine.transition_to('Air', {do_jump = true})
	else:
		state_machine.transition_to('Walk')
		
func _on_camera_exit() -> void:
	state_machine.transition_to('Sleep')
