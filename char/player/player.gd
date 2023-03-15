extends CharacterBody2D
class_name Moth

const SNAP_LENGTH = 16.0

# defining our character's traits (speed and such)

var _speed = Vector2(250, 500)
var gravity = 1200
var direction = Vector2.ZERO
var _hop_accel = 13

var flip_sprite = true
# extending subnodes for easier use
@onready var sprite = $Sprite2D
@onready var platform_detector = $PlatformDetector
@onready var wall_detector = [$LeftWallDetector,$RightWallDetector]

func _physics_process(_delta):	
	
	# set the current direction depending on input, this will be used in the
	# player's different states
	direction = get_direction()
	
	# check if the player is currently colliding with a platform, to be used
	# for snapping to moving platforms
	var _is_on_platform = platform_detector.is_colliding()
	
	# move depending on the velocity set via the player's state scripts
	move_and_slide()
	# flip sprite if facing left
	if direction.x != 0 and flip_sprite == true:
		if direction.x > 0:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
	
func get_direction():
	# set direction based on current keyboard input
	## (todo: set input keys to something that actually makes sense)
	direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("ui_up") else 0
	)
	# cancel out direction if the player is about to move towards a wall
	if wall_detector[0].is_colliding():
		direction.x += Input.get_action_strength("ui_left")
	elif wall_detector[1].is_colliding():
		direction.x -= Input.get_action_strength("ui_right")
	
	return direction
	
func calculate_move_velocity():
	# calculates the player's current horizontal velocity based on the 
	# direction given by get_direction(), and this script's _speed var.
	if abs(velocity.x) <= 150 and direction.x == 0.0 and is_on_floor():
		velocity.x = 0.0 # snap horizontal velocity if it's low enough
	else:
		# lerp for the sake of smoothly accelerating to peak velocity,
		# enabling bunnyhops + creating fake friction on the floor
		velocity.x = lerp(velocity.x, (_speed.x * direction.x), (0.1 if is_on_floor() else 0.05))
	return velocity
