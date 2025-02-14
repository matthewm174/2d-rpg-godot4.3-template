extends CharacterBody2D
class_name Enemy

#var enemy_timer: Timer = $"../enemyTimer"
var enemy_animated_sprite_2d
enum Direction { RIGHT, LEFT, UP, DOWN }
var is_animating_spell = false
var is_animating_attack = false
var impulse = Vector2.ZERO
func is_animating():
	# chain together animation blockers	
	return is_animating_spell || is_animating_attack
var knockback_velocity = Vector2()

@export var health = 10
@export var speed := 50
@export var patrol_points: Array[Vector2]
var isDead = false
var current_target = 0
var caster
var is_knockback_active
var enemy_col = CollisionShape2D.new()
var target_position
var direction
var vision_radius
func _init(hp: float, spd: float, pat_points: Array[Vector2], animations: AnimatedSprite2D, spells: Array[Spell], weapon: Wearable_Item):
	health = hp
	speed = spd
	patrol_points = pat_points
	if spells.is_empty():
		caster = false
	enemy_animated_sprite_2d = animations
	add_child(enemy_animated_sprite_2d)
	enemy_animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if health <= 0 and not isDead:
		play_death()

func kill_enemy():
	enemy_animated_sprite_2d.queue_free()
	enemy_col.queue_free()
	queue_free()

func play_death():
	if not isDead:
		isDead = true
		enemy_animated_sprite_2d.play("death")

func _on_animation_finished():
	if enemy_animated_sprite_2d.animation == "death":  # Check if the finished animation is "death"
		kill_enemy()

func _ready() -> void:

	var col_shape = RectangleShape2D.new()
	col_shape.size = enemy_animated_sprite_2d.get_sprite_frames().get_frame_texture("walk_up", 0).get_size()
	enemy_col.shape = col_shape
	add_child(enemy_col)
	enemy_col.position = Vector2.ZERO
	add_to_group("enemies")

func set_animation_from_direction(direction: Vector2):
	if abs(direction.x) > abs(direction.y):  # More horizontal movement
		if direction.x > 0:
			enemy_animated_sprite_2d.play("walk_right") # Right animation
		else:
			enemy_animated_sprite_2d.play("walk_left") # Left animation
	else:  # More vertical movement
		if direction.y > 0:
			enemy_animated_sprite_2d.play("walk_down") # Down animation
		else:
			enemy_animated_sprite_2d.play("walk_up") # Up animation

func take_damage(damage):
	health -= damage
	print(health)
	
func apply_knockback(knockback_force: Vector2):
	knockback_velocity = knockback_force
	is_knockback_active = true
	

func _physics_process(delta):
	if isDead:
		return
	if patrol_points.is_empty():
		return


	if is_knockback_active:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 100.0 * delta)
		move_and_slide()
		# End knockback when velocity is near zero
		if knockback_velocity.length() < 1.0:
			is_knockback_active = false
		return  # Exit early to skip patrol logic
	else:
		target_position = patrol_points[current_target]
		direction = (target_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		set_animation_from_direction(direction)
	# Switch to next point when close
		if global_position.distance_to(target_position) < 5:
			current_target = (current_target + 1) % patrol_points.size()
