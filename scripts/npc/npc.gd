# Npc.gd
extends Node2D
class_name Npc

var speed: float = 50.0
var direction: Vector2 = Vector2.ZERO
var is_moving: bool = true
var npc_id
var npc_name

var dialogue_trigger_area: Area2D
var npc_pat_points
var npc_animated_sprite_2d_idle
var npc_animated_sprite_2d_walk
var npc_avatar_normal
var npc_avatar_sad
var npc_avatar_angry
var npc_avatar_normal2
var facing = "up"
var current_target_index: int = 0
@export var wait_time: float = 3.0
var timer: Timer
const ACTIONABLE = preload("res://ui/actionable/actionable.tscn")
var actionable_instance 
var npc_dialogue: DialogueResource
var npc_quest_state: Dictionary
var is_talking = false

func _init(walk_animations: AnimatedSprite2D, idle_animations: AnimatedSprite2D, pat_points: Array[Vector2], npcname, id, dialogue_resource: DialogueResource):
	npc_animated_sprite_2d_walk = walk_animations
	npc_animated_sprite_2d_idle = idle_animations
	npc_animated_sprite_2d_walk.visible = false
	npc_animated_sprite_2d_idle.visible = false
	npc_pat_points = pat_points
	npc_dialogue = dialogue_resource
	npc_name = npcname
	npc_id = id

func _on_timer_timeout():
	start_moving_to_next_point()

func add_dialogue_actionable_collision():
	var hitbox = Area2D.new()
	var hb_shape = RectangleShape2D.new()
	var base_size = npc_animated_sprite_2d_idle.get_sprite_frames().get_frame_texture("up", 0).get_size()
	var hb_collision = CollisionShape2D.new()
	hb_shape.size = base_size
	hb_collision.shape = hb_shape
	hb_collision.position = global_position - Vector2(0, 10)
	hitbox.add_child(hb_collision)
	actionable_instance.add_child(hitbox)
	

func _ready():
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	# Initialize the dialogue trigger area
	dialogue_trigger_area = Area2D.new()
	dialogue_trigger_area.set_collision_layer_value(5, true)
	dialogue_trigger_area.set_meta("npc", true)
	shape.radius = 50.0
	collision_shape.shape = shape
	dialogue_trigger_area.add_child(collision_shape)
	
	dialogue_trigger_area.body_entered.connect(_on_body_entered)
	actionable_instance = ACTIONABLE.instantiate()
	add_child(actionable_instance)
	
	add_child(dialogue_trigger_area)
	add_child(npc_animated_sprite_2d_walk)
	add_child(npc_animated_sprite_2d_idle)
	
	timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	if npc_pat_points.size() > 0:
		start_moving_to_next_point()
		
	add_dialogue_actionable_collision()

func get_direction():
	direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()

func start_moving_to_next_point():
	is_moving = true
	current_target_index = wrapi(current_target_index, 0, npc_pat_points.size())
	set_animation_from_direction(direction)
	


func stop_moving():
	is_moving = false

func _process(delta):

	if is_moving:
		npc_animated_sprite_2d_walk.play(facing)
		npc_animated_sprite_2d_idle.visible = false
		npc_animated_sprite_2d_walk.visible = true
		position += direction * speed * delta
	else:
		npc_animated_sprite_2d_idle.play(facing)
		npc_animated_sprite_2d_idle.visible = true
		npc_animated_sprite_2d_walk.visible = false

func set_animation_from_direction(direction: Vector2):
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			facing = "right"
		else:
			facing = "left"
	else:
		if direction.y > 0:
			facing = "down"
		else:
			facing = "up"

func _on_body_entered(body):
	if(is_talking):
		return
	
	if body is CharacterBody2D:
		if body.is_in_group("player"): 
			stop_moving()
			#start_dialogue()
			


func _on_dialogue_ended():
	Globals.in_game_ui.hide_dialogue_ui()
	start_moving_to_next_point()
