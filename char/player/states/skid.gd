extends PlayerState

var initial_dir: int
var grace_period := Timer.new()

func _ready() -> void:
	super()
	add_child(grace_period)
	grace_period.one_shot = true
	grace_period.connect('timeout', self._on_grace_timeout)
	pass

func enter(_msg := {}) -> void:
	grace_period.wait_time = 0.45
	grace_period.start()
	initial_dir = player.sprite.scale.x
	pass 

func physics_update(_delta):
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.15)
	if !player.is_on_floor():
		state_machine.transition_to("Air")
	if player.velocity.x == 0.0:
		state_machine.transition_to("Idle")
	pass
	
func _on_grace_timeout():
	player.velocity.x = 0.0
	pass
