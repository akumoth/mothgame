extends EnemyState

var scale_diff: float
var initial_diff = 1.3
var initial_dir = 0
var cur_orientation = 'v'

func enter(_msg := {}) -> void:
	enemy.sprite.scale = Vector2.ONE
	enemy.sprite.offset.y = 0
	enemy.velocity = Vector2.ZERO
	initial_dir = enemy.direction.x
	enemy.sprite.scale.x *= initial_dir
	enemy.direction.x = 0
	scale_diff = initial_diff
	pass
	
func physics_update(_delta):
	enemy.sprite.scale.y += (scale_diff/8 if cur_orientation == 'v' else -(scale_diff/8))
	enemy.sprite.scale.x += (scale_diff/8 if cur_orientation == 'h' else -(scale_diff/8)) * initial_dir
	enemy.sprite.offset.y += (-1.75 if cur_orientation == 'v' else 1.75)
	if scale_diff <= .70:
		state_machine.transition_to('Idle')
	if (
		enemy.sprite.scale.y-.3 
		if cur_orientation == 'v' 
		else abs(enemy.sprite.scale.x)-.3
		) >= scale_diff:
		cur_orientation = ('h' if cur_orientation == 'v' else 'v')
	if enemy.sprite.scale.y == abs(enemy.sprite.scale.x):
		enemy.sprite.scale *= 0.99
		scale_diff -= .12 
	pass

func exit() -> void:
	enemy.sprite.scale = Vector2(1*initial_dir,1)
	enemy.sprite.offset.y = 0
