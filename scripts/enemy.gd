extends CharacterBody2D
@onready var enemy_timer: Timer = $"../enemyTimer"
@onready var enemy_animated_sprite_2d: AnimatedSprite2D = $EnemyAnimatedSprite2d
enum Direction { RIGHT, LEFT, UP, DOWN }
var is_animating_spell = false
var is_animating_attack = false
var impulse = Vector2.ZERO
func is_animating():
	# chain together animation blockers	
	return is_animating_spell || is_animating_attack


@export var speed := 50
@export var patrol_points: Array[Vector2]

var current_target = 0

func set_animation_from_direction(direction: Vector2):
	if abs(direction.x) > abs(direction.y):  # More horizontal movement
		if direction.x > 0:
			enemy_animated_sprite_2d.play("skele_walk_right") # Right animation
		else:
			enemy_animated_sprite_2d.play("skele_walk_left") # Left animation
	else:  # More vertical movement
		if direction.y > 0:
			enemy_animated_sprite_2d.play("skele_walk_down") # Down animation
		else:
			enemy_animated_sprite_2d.play("skele_walk_up") # Up animation


func _physics_process(delta):
	if patrol_points.is_empty():
		return

	var target_position = patrol_points[current_target]
	var direction = (target_position - global_position).normalized()

	velocity = direction * speed
	move_and_slide()
	set_animation_from_direction(direction)

	# Switch to next point when close
	if global_position.distance_to(target_position) < 5:
		current_target = (current_target + 1) % patrol_points.size()
