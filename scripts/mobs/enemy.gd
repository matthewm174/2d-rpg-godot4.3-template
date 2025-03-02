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
var search_points: Array[Vector2]
@export var vision_radius: float = 200.0
@export var attack_range: float = 100.0
@export var cast_range: float = 200.0
@export var attack_cooldown: float = 2.0
@export var spell_cooldown: float = 3.0

# Node References
@onready var agent = NavigationAgent2D.new()
@onready var patrol_change_timer = Timer.new()
#var steering: ContextSteering

var last_player_position = Vector2(0,0)
# Animation and Movement
var enemy_animated_sprite_2d
var is_animating_spell = false
var is_animating_attack = false
var knockback_velocity = Vector2()
var impulse = Vector2.ZERO
var is_knockback_active = false
var direction: Vector2
var movement_direction: Vector2
var facing = "up"

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
var enemy_state
enum ENEMY_STATE {
	DEAD,
	PATROL,
	CHASE,
	ATTACK,
	FLEE,
	SEARCH,
	IDLE
}
var state_timer = Timer.new()
var chase_state_interval: float = 7.0
var state_interval: float = 10.0
var search_state_interval: float = 10.0

var search_timer = Timer.new()


@export var path_update_interval: float = 0.3 
var path_update_timer = Timer.new()



func is_animating() -> bool:
	return is_animating_spell || is_animating_attack
	
func _init(hp: float, spd: float, pat_points: Array[Vector2], animations: AnimatedSprite2D, spells: Array[Spell], weapon: Wearable_Item):
	health = hp
	speed = spd
	patrol_points = pat_points
	enemy_weapon = weapon
	enemy_spells = spells
	caster = not spells.is_empty()
	enemy_animated_sprite_2d = animations
	add_child(enemy_animated_sprite_2d)
	enemy_animated_sprite_2d.animation_finished.connect(_on_animation_finished)

	hitbox = Area2D.new()
	hb_collision = CollisionShape2D.new()
	var hb_shape = RectangleShape2D.new()
	var base_size = enemy_animated_sprite_2d.get_sprite_frames().get_frame_texture("walk_up", 0).get_size()
	hb_shape.size = base_size * (2.0 / 3.0) 
	hb_collision.shape = hb_shape
	
	hitbox.add_child(hb_collision)
	add_child(hitbox)

	var enemy_area_shape = CircleShape2D.new()
	enemy_area_shape.radius = base_size.x / 6
	enemy_area = CollisionShape2D.new()
	enemy_area.shape = enemy_area_shape
	enemy_area.disabled = false
	enemy_area.add_to_group("enemies")
	add_child(enemy_area)
	
	
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

	for nav_region in get_tree().get_nodes_in_group("navigation"):
		nav_region.set_navigation_map(nav_map)
	

	add_child(detection_area)
	add_child(agent)
	setup_agent()
	
	patrol_change_timer.timeout.connect(_on_patrol_change_timer_timeout)
	patrol_change_timer.wait_time = state_interval
	patrol_change_timer.autostart = false
	add_child(patrol_change_timer)
	
	state_timer.wait_time = state_interval
	state_timer.autostart = false
	state_timer.timeout.connect(_update_state)
	add_child(state_timer)
	
	search_timer.wait_time = 3
	search_timer.autostart = false
	search_timer.timeout.connect(_on_search_change_timer_timeout)
	add_child(search_timer)
	
	path_update_timer.wait_time = path_update_interval
	path_update_timer.autostart = false
	path_update_timer.timeout.connect(_update_navigation_path)
	add_child(path_update_timer)
	
	if patrol_points.size() > 0:
		enemy_state = ENEMY_STATE.PATROL
	else:
		enemy_state = ENEMY_STATE.IDLE

func _update_state():
	print("state %s", enemy_state)
	match enemy_state:
		ENEMY_STATE.CHASE:
			enemy_state = ENEMY_STATE.SEARCH
			search_points = Vector2Utils.generate_patrol_points(global_position, 8, 200)
			state_timer.wait_time = search_state_interval
			search_timer.start()
			state_timer.start()
		ENEMY_STATE.SEARCH:
			search_timer.stop()
			enemy_state = ENEMY_STATE.PATROL
			if patrol_change_timer.is_stopped():
				patrol_change_timer.start()


static func duplicate_instance(reference: Enemy, pat_points: Array[Vector2]):
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
		

	
func _on_velocity_computed(safe_velocity):
	if safe_velocity.length() > 0:
		velocity = safe_velocity
		move_and_slide()

func _on_path_changed():
	debug_path = agent.get_current_navigation_path()
	print(debug_path)
	#path_update_timer.start()
	
func set_new_target(pos: Vector2):
	agent.set_target_position(pos)


func setup_agent():
	agent.pathfinding_algorithm = NavigationPathQueryParameters2D.PathfindingAlgorithm.PATHFINDING_ALGORITHM_ASTAR
	
	agent.path_max_distance = 300.0
	agent.neighbor_distance = 100.00
	agent.path_desired_distance = 10.00
	if enemy_area.shape is CircleShape2D:
		agent.radius = enemy_area.shape.radius
	agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED
	agent.debug_enabled = true
	agent.debug_path_custom_line_width = 3.0

	agent.avoidance_enabled = true  
	agent.avoidance_priority = 1.0
	agent.avoidance_layers = 1
	agent.avoidance_mask = 2
	agent.simplify_path = true
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
	enemy_state = ENEMY_STATE.ATTACK
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
	enemy_state = ENEMY_STATE.ATTACK
	if caster and can_cast and player_ref:
		can_cast = false
		is_animating_spell = true
		enemy_animated_sprite_2d.play("cast_"+facing)
		current_spell = enemy_spells[select_spell()]
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
	

func _on_search_change_timer_timeout():
	if is_dead || search_points.is_empty():
		return
	current_target = (current_target + 1) % search_points.size()
	target_position = search_points[current_target]
	agent.target_position = target_position
	search_timer.start()

func _on_patrol_change_timer_timeout():
	# this should return enemy to original patrol point if no longer sees player
	if is_dead || patrol_points.is_empty():
		return
	current_target = (current_target + 1) % patrol_points.size()
	target_position = patrol_points[current_target]
	agent.target_position = target_position
	patrol_change_timer.start()


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

	var should_move = true
	
	if player_in_range:
		if enemy_state != ENEMY_STATE.CHASE:
			enemy_state = ENEMY_STATE.CHASE
			state_timer.wait_time = chase_state_interval
			state_timer.start()
			path_update_timer.start()
			
		var distance = global_position.distance_to(Globals.current_player.character_body_2d.global_position)
		
		if distance <= attack_range:
			try_attack()
			should_move = false
		elif caster and distance <= cast_range:
			try_cast()
			should_move = false
		
	if should_move:
		var move_target = agent.get_next_path_position()
		if global_position.distance_to(move_target) > 1.0:
			movement_direction = (move_target - global_position).normalized()
			velocity = movement_direction * speed
			move_and_slide()
			if velocity.length() > speed * 0.1:
				set_animation_from_direction(movement_direction)

func _update_navigation_path():
	
	if enemy_state != ENEMY_STATE.CHASE:
		return
	var target_pos = Globals.current_player.character_body_2d.global_position
	
	if target_pos.distance_to(last_player_position) > 90.0 and player_in_range:  # Avoid small jittery updates
		agent.target_position = target_pos
		last_player_position = target_pos
