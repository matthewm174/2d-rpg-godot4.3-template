extends Node2D

@export var knockback_strength: float = 500.0
@export var max_explosion_radius: float = 100.0
@export var explosion_radius: float = 100.0

@export var explosion_duration: float = 0.5

var timer: Timer

var area: Area2D

var sprite_path
var frame_size
var frame_count
var animation_name
var explosion_position
var animated_sprite_sheet
var is_looping
var pos
var tween: Tween

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

	var tween = create_tween()
	tween.tween_property(circle_shape, "radius", max_explosion_radius, explosion_duration)
	
func _on_animation_finished():
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		apply_knockback(body)

func apply_knockback(body):
	var direction = (body.position - pos).normalized()
	
	var knockback_force = -direction * knockback_strength
	
	if body.has_method("apply_knockback"):
		body.apply_knockback(knockback_force)
