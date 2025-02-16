extends Node2D


@export var distance: float = 200.0
@export var damage: float = 10.0
@export var spell_magnitude: float = 1.0
var initial_position: Vector2
var direction: Vector2
@onready var target_spell_area_2d: Area2D = $TargetSpellArea2D
@onready var target_spell_collision_shape_2d: CollisionShape2D = $TargetSpellArea2D/TargetSpellCollisionShape2D


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
var target_effects: Array[Spell.TARGET_EFFECT]


func _ready():
	animated_sprite_sheet = AnimationUtils.load_spritesheet(sprite_path, frame_size, frame_count, animation_name, Vector2.ZERO, true)
	add_child(animated_sprite_sheet)
	target_spell_area_2d.body_entered.connect(_on_body_entered)

func _process(delta):
	position = initial_position

	if Spell.TARGET_EFFECT.EXPLOSION:
		detonate()
	if Spell.TARGET_EFFECT.TELEPORT:
		TeleportEffect.teleport(Globals.current_player, position)
	
	queue_free()  # Delete the projectile



func _on_body_entered(body):
	if body.is_in_group("enemies"):
		last_pos = position
		body.take_damage(damage) 
		if explodes:
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
