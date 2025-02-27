extends CharacterBody2D
class_name Enemy

# Enums
enum Direction { RIGHT, LEFT, UP, DOWN }

# Constants
const ProjectileSpell = preload("res://scripts/projectile/Projectile.tscn")
const TargetSpell = preload("res://scripts/target_spell/TargetSpell.tscn")

# Exported Variables
@export var tilemap: TileMapLayer
@export var health := 10
@export var speed := 50
@export var patrol_points: Array[Vector2]
@export var vision_radius: float = 200.0
@export var attack_range: float = 100.0
@export var cast_range: float = 200.0
@export var attack_cooldown: float = 2.0
@export var spell_cooldown: float = 3.0

# Node References
@onready var agent = NavigationAgent2D.new()
@onready var path_change_timer = Timer.new()

# Animation and Movement
var enemy_animated_sprite_2d
var is_animating_spell = false
var is_animating_attack = false
var knockback_velocity = Vector2()
var impulse = Vector2.ZERO
var is_knockback_active = false
var direction: Vector2
var facing = "up"
var is_patrolling = true

# Combat and Spells
var caster = false
var can_attack: bool = true
var can_cast: bool = true
var current_spell: Spell
var enemy_spells: Array[Spell]
var enemy_weapon: Wearable_Item

# Player Interaction
var player_ref: CharacterBody2D = null
var player_in_range: bool = false
var last_player_position: Vector2 = Vector2.ZERO
var target_position: Vector2

# Pathfinding and Patrol
var debug_path: PackedVector2Array = []
var current_target = 0
var return_to_patrol_time = 3.0

# Hitbox and Area
var hb_collision
var hitbox
var enemy_area

# State Management
var is_dead: bool = false

# Helper Functions
func is_animating() -> bool:
	return is_animating_spell || is_animating_attack
	
func _init(hp: float, spd: float, pat_points: Array[Vector2], animations: AnimatedSprite2D, spells: Array[Spell], weapon: Wearable_Item):
	health = hp
	speed = spd
	patrol_points = pat_points
	enemy_weapon = weapon
	enemy_spells = spells
	if spells.is_empty():
		caster = false
	else:
		caster = true
	enemy_animated_sprite_2d = animations
	add_child(enemy_animated_sprite_2d)
	enemy_animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	hitbox = Area2D.new()
	var hb_shape = RectangleShape2D.new()
	var base_size = enemy_animated_sprite_2d.get_sprite_frames().get_frame_texture("walk_up", 0).get_size()
	hb_collision = CollisionShape2D.new()
	hb_shape.size = base_size - base_size/3
	hb_collision.shape = hb_shape
	hb_collision
	hitbox.add_child(hb_collision)
	add_child(hitbox)
	enemy_area = CollisionShape2D.new()
	enemy_area.add_to_group("enemies")
	enemy_area.disabled = false
	enemy_area.shape = hb_shape
	add_child(enemy_area)
	
static func duplicate_instance(reference: Enemy, pat_points: Array[Vector2]):
	print(reference.enemy_weapon.get_class())

	var new_enemy = Enemy.new(
		reference.health,
		reference.speed,
		pat_points,
		reference.enemy_animated_sprite_2d.duplicate(),
		reference.enemy_spells.duplicate(),
		reference.enemy_weapon
	)
	return new_enemy

	

func _process(delta: float) -> void:
	if is_knockback_active:
		return
		
	if agent.is_navigation_finished() and not is_patrolling:
		is_patrolling = true
		path_change_timer.wait_time = return_to_patrol_time
		path_change_timer.start()
		return

	var desired_velocity = (agent.get_next_path_position() - global_position).normalized() * 100
	agent.set_velocity(desired_velocity)
	if health <= 0 and not is_dead:
		play_death()



func kill_enemy():
	enemy_animated_sprite_2d.queue_free()
	queue_free()

func play_death():
	if not is_dead:
		is_dead = true
		enemy_animated_sprite_2d.play("death")

func _on_body_entered(body: Node):
	print(body.get_groups())
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_body_exited(body: Node):
	print()
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = false
		player_ref = null



func _on_animation_finished():
	if enemy_animated_sprite_2d.animation == "death":
		kill_enemy()
	var cast_regex = RegEx.new()
	cast_regex.compile("^attack_.*")

	if cast_regex.search(enemy_animated_sprite_2d.animation):
		is_animating_attack = false
		can_attack = true
	
	cast_regex.compile("^cast_.*")
	
	if cast_regex.search(enemy_animated_sprite_2d.animation):
		is_animating_spell = false
		can_cast = true
		
func _ready() -> void:
	self.add_to_group("enemies")
	var detection_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = vision_radius
	detection_area.add_child(collision_shape)
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	if not tilemap:
		self.tilemap = Globals.fantasy_game_state.ground
	var nav_map = tilemap.get_navigation_map()
	agent.set_navigation_map(nav_map)
	path_change_timer.timeout.connect(_on_path_change_timer_timeout)
	add_child(detection_area)
	add_child(agent)
	setup_agent()
	add_child(path_change_timer)

	
func _on_velocity_computed(safe_velocity):
	if safe_velocity.length() > 0:
		velocity = safe_velocity
		move_and_slide()

func _on_path_changed():
	debug_path = agent.get_current_navigation_path()
	
func set_new_target(pos: Vector2):
	agent.set_target_position(pos)


func setup_agent():
	agent.pathfinding_algorithm = NavigationPathQueryParameters2D.PathfindingAlgorithm.PATHFINDING_ALGORITHM_ASTAR
	agent.path_max_distance = 300.0
	#agent.target_desired_distance = 100.0/
	agent.path_desired_distance = 200.00
	if enemy_area.shape is RectangleShape2D:
		var width = enemy_area.shape.extents.x * 2
		var height = enemy_area.shape.extents.y * 2
		var radius = min(width, height) / 2.0
		agent.radius = radius
	agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED
	agent.debug_enabled = true
	agent.debug_path_custom_line_width = 3.0
	agent.avoidance_enabled = true  
	agent.avoidance_priority = 1.0  # Higher priority means it avoids obstacles first
	if not tilemap:
		push_error("TileMap not found or navigation layer not set up!")
	
	agent.avoidance_enabled = true
	agent.velocity_computed.connect(_on_velocity_computed)
	agent.path_changed.connect(_on_path_changed)
	

func create_projectile_for_current_spell():
	
	if current_spell == null:
		return
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - position).normalized()
	if current_spell.spell_type == Spell.CAST_TYPES.PROJECTILE:
		var projectile = ProjectileSpell.instantiate()
		projectile.direction = direction
		print(direction)
		projectile.speed = current_spell.spell_speed
		projectile.explosion_duration = current_spell.explosion_dur
		projectile.explosion_radius = current_spell.explosion_radius
		projectile.damage = current_spell.spell_damage
		projectile.explosion_sprite_path = current_spell.explode_animation
		projectile.animation_name="missle"
		projectile.distance = current_spell.spell_range
		projectile.frame_count=7
		projectile.explodes = current_spell.explodes
		projectile.sprite_path=current_spell.spell_animation
		projectile.frame_size = Vector2i(64,64)
		projectile.position = position
		var computed_angle = rad_to_deg(direction.angle()) + 180.0
		projectile.rotation_degrees = fposmod(computed_angle, 360.0)
		get_tree().current_scene.add_child(projectile)
	if current_spell.spell_type == Spell.CAST_TYPES.TARGET:
		var target_spell = TargetSpell.instantiate()
		target_spell.damage = current_spell.spell_damage
		target_spell.animation_name = "missle"
		target_spell.frame_size = Vector2i(64,64)
		target_spell.sprite_path = current_spell.spell_animation
		target_spell.frame_count=7
		target_spell.position = mouse_position
		target_spell.explosion_duration = current_spell.explosion_dur
		target_spell.explosion_radius = current_spell.explosion_radius
		target_spell.initial_position = mouse_position
		target_spell.explosion_sprite_path = current_spell.explode_animation
		target_spell.explodes = current_spell.explodes
		target_spell.target_effects = current_spell.target_effects
		get_tree().current_scene.add_child(target_spell)
		



func try_attack():
	if can_attack and player_ref:
		can_attack = false
		is_animating_attack = true
		enemy_animated_sprite_2d.play("attack_"+facing)

#TODO: make this more intelligent
func select_spell():
	
	if enemy_spells.is_empty():
		return -1
	
	return randi() % enemy_spells.size()

func try_cast():
	if caster and can_cast and player_ref:
		can_cast = false
		is_animating_spell = true
		enemy_animated_sprite_2d.play("cast_"+facing)
		select_spell()
		create_projectile_for_current_spell()


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
			
	enemy_animated_sprite_2d.play("walk_"+facing)

func take_damage(damage):
	health -= damage
	print(health)
	
func apply_knockback(knockback_force: Vector2):
	knockback_velocity = knockback_force
	is_knockback_active = true
	

func _on_path_change_timer_timeout():
	# this should return enemy to original patrol point if no longer sees player
	if is_dead || patrol_points.is_empty():
		return
	current_target = (current_target + 1) % patrol_points.size()
	target_position = patrol_points[current_target]
	agent.target_position = target_position
	path_change_timer.start()


func _physics_process(delta):
	
	if is_dead || patrol_points.is_empty() || NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return

	if is_knockback_active:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 100.0 * delta)
		move_and_slide()
		if knockback_velocity.length() < 1.0:
			is_knockback_active = false
		return

	var target_pos = Globals.current_player.character_body_2d.global_position
	if player_in_range and target_pos:
		is_patrolling = false
		var distance = global_position.distance_to(target_pos)
		if target_pos.distance_to(last_player_position) > 5.0:
			agent.target_position = target_pos
			last_player_position = target_pos
		
		if distance <= attack_range:
			try_attack()
			velocity = Vector2.ZERO
		elif caster and distance <= cast_range:
			try_cast()
			velocity = Vector2.ZERO


	if agent.is_navigation_finished():
		return

	var next_path_pos = agent.get_next_path_position()
	direction = (next_path_pos - global_position).normalized()

	if not is_animating():
		move_and_slide()
		set_animation_from_direction(direction)
