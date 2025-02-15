extends CharacterBody2D
class_name PlayerCharacterBody2d
@onready var player_animated_sprite_2d: AnimatedSprite2D = $PlayerAnimatedSprite2d
@onready var anim_lock_timer: Timer = $Timer
const Projectile = preload("res://scripts/projectile/Projectile.tscn")
#@export var speed = 100
var player_inventory: Inventory
var player_data_resource: PlayerDataResource
@onready var character_body_2d: CharacterBody2D = $"."
@onready var camera_2d: Camera2D = $Camera2D
#const WORLD = preload("res://World.tscn")
var stats: Dictionary

enum Direction { RIGHT, LEFT, UP, DOWN}
var facing_direction = Direction.DOWN
var move_dir = facing_direction
var is_animating_spell = false;
var is_animating_attack = false;
var showing_inventory = false;
var available_spells = {}
var equipped_spells = {}
var showing_menu = false;
var max_equippable_spells = 4;
var spell_equip_index = 0
var current_spell: Spell
var current_spell_panel
var weapon_sprite: AnimatedSprite2D
var aim_angle
var can_strafe = true
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knockback_active: bool = false     

@export var strafe_duration: float = 0.1  # How long the strafe lasts (in seconds)
@export var strafe_cooldown: float = 1.0

func _init():
	Globals.current_player = self
	
	

func _ready():

	load_player_data()
	anim_lock_timer.wait_time = 0.5
	anim_lock_timer.timeout.connect(func(): 
		is_animating_spell = false;
		is_animating_attack = false;
	)


func strafe(direction: Vector2) -> void:
	can_strafe = false
	if direction == Vector2.ZERO:
		return  # Don't strafe if there's no input direction

	var strafe_timer = get_tree().create_timer(strafe_duration)
	strafe_timer.timeout.connect(_on_strafe_finished)
	


func _on_strafe_finished() -> void:
	can_strafe = true



func load_stats():
	for key in Globals.player_data.stats:
		Globals.current_player.stats[key] =  Globals.player_data.stats[key]


func load_player_data():
	Globals.player_data.get_player_data()
	for spell_key in Globals.item_resources.master_spell_book:
		var spell = Globals.item_resources.master_spell_book[spell_key]
		if spell.is_unlocked:
			available_spells[spell_key] = spell
	if Globals.player_data:
		load_stats()
		load_spells()
		load_inventory()

		
func highlight_spell_selection(panel: Panel) -> void:
	for pnl in Globals.in_game_ui.spell_grid_container.get_children():
		if pnl is Panel:
			clear_spell_selection(panel)
	
	current_spell_panel = panel
	current_spell_panel.z_index = 3


func clear_spell_selection(panel: Panel) -> void:
	panel.add_theme_stylebox_override("panel", Globals.in_game_ui.default_stylebox)

func set_current_spell() -> void:
	for child in Globals.in_game_ui.spell_grid_container.get_children():
		if child is Panel:
			clear_spell_selection(child)
	
	# Check which spell key was pressed
	for i in range(4):  # max 4
		if Input.is_action_just_pressed("spell_" + str(i)):
			current_spell = Globals.player_data.equipped_spells[i]
			highlight_spell_selection(Globals.in_game_ui.spell_grid_container.get_children()[i])
			break 
	if(current_spell_panel):
		current_spell_panel.add_theme_stylebox_override("panel", Globals.in_game_ui.selected_stylebox)
	


func create_projectile_for_current_spell():
	
	if current_spell == null:
		return
	# Get the direction to the mouse
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - position).normalized()
	
	# Spawn the projectile at the player's position
	var projectile = Projectile.instantiate()
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

	projectile.sprite_path=current_spell.spell_animation
	projectile.frame_size = Vector2i(64,64)
	projectile.position = position
	var computed_angle = rad_to_deg(direction.angle()) + 180.0
	projectile.rotation_degrees = fposmod(computed_angle, 360.0)
	get_tree().current_scene.add_child(projectile)

	
func load_inventory():
	player_inventory = Globals.player_data.inventory
	
	for slot in player_inventory.inv_slots:
		var index = Globals.in_game_ui.inventory_item_list.add_item(slot.item_name)
		Globals.in_game_ui.inventory_item_list.set_item_metadata(index, slot) 
	
	
func load_spells():

	for i in range(max_equippable_spells):
		var spell_panels = Globals.in_game_ui.spell_grid_container.get_children() #spells panels
		if Globals.player_data.equipped_spells[i]:
			print(Globals.player_data.equipped_spells[i].spell_type)
			print(Globals.player_data.equipped_spells[i].spell_range)
			print(Globals.player_data.equipped_spells[i].spell_magnitude)
			print(Globals.player_data.equipped_spells[i].spell_cast_time)
			print(Globals.player_data.equipped_spells[i].is_unlocked)
			print(Globals.player_data.equipped_spells[i].item_uniqueness)
			print(Globals.player_data.equipped_spells[i].item_graphic)
			print(spell_panels[i])
			var texture_rect = TextureRect.new()
			texture_rect.texture = Globals.item_resources.master_spell_book["fire_ball"].item_graphic.texture
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.z_index = -1
			spell_panels[i].add_child(texture_rect)
			spell_equip_index+=1

func equip_inv_item(item_metadata: Wearable_Item):
	add_item_to_equipment_panel(item_metadata)
	add_item_to_player_body(item_metadata)

func add_item_to_player_body(item_meta: Wearable_Item):
	var item_to_equip
	if item_meta.item_type == item_meta.ITEM_TYPE.SWORD and not weapon_sprite:
		weapon_sprite = item_meta.weapon_character_sprite
		weapon_sprite.position = player_animated_sprite_2d.position
		weapon_sprite.z_index = 2
		weapon_sprite.animation_finished.connect(_on_wep_animation_finished)
		add_child(weapon_sprite)
		item_to_equip = Globals.item_resources.master_weapon_book[item_meta.item_id]

	if item_meta.item_type == Wearable_Item.ITEM_TYPE.SPELL:
		item_to_equip = Globals.item_resources.master_spell_book[item_meta.item_id]

	else:
		item_to_equip = Globals.item_resources.master_weapon_book[item_meta.item_id]

func append_to_spells(value):
	Globals.player_data.equipped_spells[spell_equip_index] = value
	spell_equip_index = (spell_equip_index + 1) % 4
	load_spells()

func add_item_to_equipment_panel(item_meta: Wearable_Item):

	var texture_rect = TextureRect.new()
	texture_rect.texture = item_meta.item_graphic.texture
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	match item_meta.item_equip_location:
		Wearable_Item.WEARABLE_LOCATION.Primary_Hand:
			Globals.in_game_ui.primary_panel.add_child(texture_rect)
		Wearable_Item.WEARABLE_LOCATION.Secondary_Hand:
			Globals.in_game_ui.secondary_panel.add_child(texture_rect)
		Wearable_Item.WEARABLE_LOCATION.Arms:
			Globals.in_game_ui.arms_panel.add_child(texture_rect)
		Wearable_Item.WEARABLE_LOCATION.Feet:
			pass
		Wearable_Item.WEARABLE_LOCATION.Head:
			Globals.in_game_ui.head_panel.add_child(texture_rect)
		Wearable_Item.WEARABLE_LOCATION.Legs:
			Globals.in_game_ui.legs_panel.add_child(texture_rect)
		Wearable_Item.WEARABLE_LOCATION.Spells:
			append_to_spells(item_meta)

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var base_speed = stats["Speed"] * 20
	player_animated_sprite_2d.speed_scale = 1
	
	
	
	if Input.is_action_pressed("sprint"):
		player_animated_sprite_2d.speed_scale = 2
		base_speed *= 1.5
	if Input.is_action_just_pressed("strafe") and can_strafe:
		player_animated_sprite_2d.speed_scale = 3
		
		strafe(input_direction)
	if not can_strafe:
		base_speed *= 6.0
	velocity = input_direction * base_speed

func handle_spell():
	match move_dir:
		Direction.UP:
			player_animated_sprite_2d.play("man_cast_up")
		Direction.DOWN:
			player_animated_sprite_2d.play("man_cast_down")
		Direction.LEFT:
			player_animated_sprite_2d.play("man_cast_left")
		Direction.RIGHT:
			player_animated_sprite_2d.play("man_cast_right")


func _on_wep_animation_finished():
	weapon_sprite.visible = false
	
func handle_attack():
	weapon_sprite.visible = true
	weapon_sprite.speed_scale = 2
	player_animated_sprite_2d.speed_scale = 2
	match move_dir:
		Direction.UP:
			if(weapon_sprite):
				weapon_sprite.play("up")
			player_animated_sprite_2d.play("man_attack_up")
		Direction.DOWN:
			if(weapon_sprite):
				weapon_sprite.play("down")
			player_animated_sprite_2d.play("man_attack_down")
		Direction.LEFT:
			if(weapon_sprite):
				weapon_sprite.play("left")
			player_animated_sprite_2d.play("man_attack_left")
		Direction.RIGHT:
			if(weapon_sprite):
				weapon_sprite.play("right")
			player_animated_sprite_2d.play("man_attack_right")
	player_animated_sprite_2d.speed_scale = 1

func is_animating():
	# chain together animation blockers
	return is_animating_spell || is_animating_attack

func set_animation():
	if Input.is_action_just_pressed("inventory"):
		if not showing_inventory:
			Globals.in_game_ui.show_inventory()
			showing_inventory = true
		else:
			Globals.in_game_ui.hide_inventory()
			showing_inventory = false

	if Input.is_action_just_pressed("menu"):
		if not showing_menu:
			Globals.in_game_ui.show_main_menu()
			showing_menu = true
		else:
			Globals.in_game_ui.hide_main_menu()
			showing_menu = false
		
	if Input.is_action_pressed("spell_attack"):
		is_animating_spell = true;
		anim_lock_timer.start(1.0)
	elif Input.is_action_pressed("wep_attack"):
		is_animating_attack = true;
		anim_lock_timer.start(1.0)

	if is_animating_spell:
		handle_spell()
		return
	if is_animating_attack and weapon_sprite:
		
		handle_attack()
		return
		
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	
	# calculate the angle in degrees
	var angle = rad_to_deg(direction.angle())
	if not is_animating():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
			match move_dir:
				Direction.RIGHT:
					player_animated_sprite_2d.play("man_walk_right")
				Direction.UP:
					player_animated_sprite_2d.play("man_walk_up")
				Direction.LEFT:
					player_animated_sprite_2d.play("man_walk_left")
				Direction.DOWN:
					player_animated_sprite_2d.play("man_walk_down")
		else:
			# play idle animation based on move_dir
			match move_dir:
				Direction.RIGHT:
					player_animated_sprite_2d.play("man_idle_right")
				Direction.UP:
					player_animated_sprite_2d.play("man_idle_up")
				Direction.LEFT:
					player_animated_sprite_2d.play("man_idle_left")
				Direction.DOWN:
					player_animated_sprite_2d.play("man_idle_down")
				

func apply_knockback(direction: Vector2):
	#dummy vars, make configurable
	var knockback_strength: float = 500.0
	var knockback_duration: float = 0.2 
	direction = direction.normalized()
	knockback_velocity = direction * knockback_strength
	
	is_knockback_active = true
	await get_tree().create_timer(knockback_duration).timeout
	is_knockback_active = false


func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	if is_knockback_active:
		velocity = knockback_velocity
	
	if not is_animating():
		get_input()
		move_and_slide()

func _process(delta):
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	
	var direction_local = direction.rotated(-rotation)
	aim_angle = rad_to_deg(direction_local.angle())
	
	
	
	if aim_angle >= -45 and aim_angle < 45:
		move_dir = Direction.RIGHT  # Right
	elif aim_angle >= 45 and aim_angle < 135:
		move_dir = Direction.DOWN # Up
	elif aim_angle >= 135 or aim_angle < -135:
		move_dir = Direction.LEFT  # Left
	else:
		move_dir = Direction.UP # Down
	set_animation()
	set_current_spell()
