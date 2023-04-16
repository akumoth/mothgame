class_name Enemy
extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state_rng = RandomNumberGenerator.new()

@onready var ScreenNotifier = $ScreenNotifier

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
