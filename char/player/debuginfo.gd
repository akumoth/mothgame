extends CanvasLayer

var player: Moth
@onready var state_machine = get_node("../StateMachine")

func _ready():
	await owner.ready
	player = owner as Moth
	assert(player != null)
	pass 


func _process(delta):
	set_text_movement_info()
	pass
	
func set_text_movement_info():
	var movement_info = "Velocity: %10.4f, %10.4f\nPosition: %10.4f, %10.4f\nState: %s"
	$CharInfo.text = movement_info % [player.velocity.x, player.velocity.y, player.position.x, player.position.y, state_machine.state.name]
	pass
