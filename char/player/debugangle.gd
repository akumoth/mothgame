extends Node2D

# Called when the node enters the scene tree for the first time.
var player: Moth
func _ready():
	await owner.ready
	player = owner as Moth
	assert(player != null)
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	draw_arc(position,50,0,360,32,Color(1.0, 1.0, 1.0),2.0)
	draw_line(
		position,
		Vector2(
			position.x+(clamp((player.velocity.x/10),-30,30)),
			position.y+(clamp((player.velocity.y/10),-30,30))
		),
		Color(1.0, 1.0, 1.0),
		1.0
	)
	pass
	
func _process(delta):
	queue_redraw()

