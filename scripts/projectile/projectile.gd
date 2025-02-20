extends Node2D

# Speed of the projectile
@export var speed: float = 200.0
@export var distance: float = 200.0
@export var damage: float = 10.0
@export var projectile_type: Wearable_Item.ITEM_TYPE
@export var spell_magnitude: float = 1.0
var initial_position: Vector2
var direction: Vector2


@onready var projectile_area_2d: Area2D = $ProjectileArea2D
@onready var collision_shape_2d: CollisionShape2D = $ProjectileArea2D/CollisionShape2D


const Explosion = preload("res://scripts/spells/effect/Explosion.tscn")

var sprite_path
var frame_size: Vector2i
var frame_count
var animation_name
var explosion_sprite_path
var explosion_radius
var explosion_duration
var animated_sprite_sheet
var angle
var explodes
var last_pos

func _ready():
	print(self.z_index)
	print("Projectile Position (Global): ", position)
	animated_sprite_sheet = AnimationUtils.load_spritesheet(sprite_path, frame_size, frame_count, animation_name, Vector2.ZERO, true)
	print("AnimatedSprite2D Position (Local): ", animated_sprite_sheet.position)

	initial_position = global_position
	add_child(animated_sprite_sheet)

	projectile_area_2d.body_entered.connect(_on_projectile_area_2d_body_entered)

func _process(delta):
	position += direction * speed * delta
	if position.distance_to(initial_position) >= distance:
		last_pos = position
		detonate()
		queue_free()



func detonate():
	var explosion = Explosion.instantiate()
	explosion.animation_name = "explode"
	explosion.explosion_duration = explosion_duration
	explosion.explosion_radius = explosion_radius
	explosion.frame_count = frame_count
	explosion.frame_size = frame_size
	explosion.sprite_path = explosion_sprite_path
	explosion.pos = position
	explosion.is_looping = false
	print("explosion : ", position)
	
	get_tree().current_scene.add_child(explosion)


func _on_projectile_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		last_pos = position
		body.take_damage(damage)
		if explodes:
			detonate()
		
		queue_free()
