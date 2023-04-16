extends EnemyState

func enter(_msg := {}) -> void:
	enemy.velocity.x = 0
	enemy.velocity.y = 0
	enemy.hostile = false
	pass
	
func _ready() -> void:
	super()
	await owner.ready
	enemy.ScreenNotifier.connect('screen_entered', self._on_camera_enter)

func _on_camera_enter() -> void:
	state_machine.transition_to('Idle')
