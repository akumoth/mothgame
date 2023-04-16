extends Area2D

enum HitboxType {HITSTUN, KNOCKBACK, STAGGER, GRAB}

@export var current_type = HitboxType.HITSTUN
@export var inflicted_hitstun: int
@export var inflicted_damage: int

func set_hitbox_type(type):
	current_type = HitboxType[type]
	
func set_hitstun(amount):
	inflicted_hitstun = amount
	
func set_damage(amount):
	inflicted_damage = amount

func get_hitbox_type():
	return current_type
