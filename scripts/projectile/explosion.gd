extends Node2D

# Knockback strength
@export var knockback_strength: float = 500.0

# Explosion radius
@export var explosion_radius: float = 100.0

# Timer duration (how long the explosion lasts)
@export var explosion_duration: float = 0.5

# Reference to the Timer
var timer: Timer

# Reference to the Area2D
var area: Area2D

var sprite_path
var frame_size
var frame_count
var animation_name
var explosion_position
var animated_sprite_sheet
var is_looping
var pos

func _ready():
	animated_sprite_sheet = AnimationUtils.load_spritesheet(sprite_path, frame_size, frame_count, animation_name, pos, is_looping)
	add_child(animated_sprite_sheet)
	
	if animated_sprite_sheet is AnimatedSprite2D:
		animated_sprite_sheet.animation_finished.connect(_on_animation_finished)
	else:
		printerr("animated_sprite_sheet is not an AnimatedSprite2D!")
	
	area = Area2D.new()
	area.position = pos
	add_child(area)

	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = explosion_radius
	collision_shape.shape = circle_shape
	area.call_deferred("add_child", collision_shape) 
	area.connect("body_entered", _on_Area2D_body_entered)

	
func _on_animation_finished():
	queue_free()

func _on_Area2D_body_entered(body):
	# Check if the body is in the "enemies" group (or any other group you want to apply knockback to)
	if body.is_in_group("enemies"):
		apply_knockback(body)

func apply_knockback(body):
	var distance = body.global_position.distance_to(global_position)
	var strength = knockback_strength * (40.0 - distance / explosion_radius)
	var direction = (body.global_position - global_position).normalized()
	if body.has_method("apply_knockback"):
		body.apply_knockback(direction * strength)
