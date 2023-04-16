extends Enemy

var max_hp: int
var hp: int
var hostile: bool

var speed = Vector2(200.0,-400.0)
var direction = Vector2.ZERO

@onready var state_machine = get_node("StateMachine")
@onready var sprite = $Sprite2D
@onready var platform_detector = [$LeftPlatformDetector,$RightPlatformDetector]
@onready var wall_detector = [$LeftWallDetector,$RightWallDetector]
	
func _physics_process(_delta):	
	super(_delta)
	if direction.x != 0:
		if direction.x > 0:
			sprite.scale.x = 1
		elif direction.x < 0:
			sprite.scale.x = -1
	if !get_tree().get_nodes_in_group("Player").is_empty() and ScreenNotifier.is_on_screen() and !hostile:
		var player = get_tree().get_nodes_in_group("Player")[0]
		if _visible_position_to_node(player).has('collider') and _visible_position_to_node(player)['collider'] == player:
			hostile = true
	
func _visible_position_to_node(node):
	var angle_to_node = self.position.angle_to_point(Vector2(node.position.x,node.position.y+30))
	var dir_to_node = round(self.position.direction_to(node.position).x)
	if  dir_to_node == direction.x or dir_to_node == round(sprite.scale.x):
		# check 90° wide cone in current direction to see if node is there
		if (
			((abs(angle_to_node) < (PI/4)) or 
			(abs(angle_to_node) > (3*PI/4)))
			) and self.position.distance_to(node.position) < 1000:
			# raycast to see if something in the way
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(self.position, Vector2(node.position.x,node.position.y+30)))
			return result
	return {}

