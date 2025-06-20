extends CharacterBody2D
class_name PlayerCharacterBody2d

# Enums
enum Direction { RIGHT, LEFT, UP, DOWN }

# Constants
const ProjectileSpell = preload("res://scripts/projectile/Projectile.tscn")
const TargetSpell = preload("res://scripts/target_spell/TargetSpell.tscn")
const DIALOGUE_UI = preload("res://ui/dialogue/dialogue_ui.tscn")

# Node References
@onready var player_animated_sprite_2d: AnimatedSprite2D = $PlayerAnimatedSprite2d
@onready var anim_lock_timer: Timer = $Timer
@onready var character_body_2d: CharacterBody2D = $"."
@onready var camera_2d: Camera2D = $Camera2D
@onready var speed_trail_line_2d: Line2D = $SpeedTrailLine2D
@onready var interaction_ray_cast_2d: RayCast2D = $InteractionRayCast2d

# Player Data and Inventory
var player_inventory: Inventory
var player_data_resource: PlayerDataResource
var stats: Dictionary
var skills: Dictionary

var player_weapon_holding_type = Weapon.ITEM_TYPE.SWORD

var facing = "down"
var is_animating_spell = false
var is_animating_attack = false
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knockback_active: bool = false
var can_strafe = true
@export var strafe_duration: float = 0.1  # How long the strafe lasts (in seconds)
@export var strafe_cooldown: float = 1.0  # Cooldown between strafes (in seconds)

# Spells and Combat
var available_spells = {}
var equipped_spells = {}
var max_equippable_spells = 4
var spell_equip_index = 0
var current_spell: Spell
var current_spell_panel
var weapon_sprite: AnimatedSprite2D
var aim_angle

# Quests and Dialogue
var set_up_new_quests = false
var new_quests: Dictionary
var active_quests: Dictionary
var interacting_npc
var is_talking = false
var current_expression: Sprite2D
var expressions: Array[Sprite2D]

# UI and Menu
var showing_inventory = false
var showing_menu = false

func _init():
	Globals.current_player = self
	
	

func _ready():
	expressions.append(AnimationUtils.load_avatar("res://sprites/player/dummy_avatar.png", Vector2(128,128)))
	set_current_expression(expressions[0])
	speed_trail_line_2d.visible=false
	load_player_data()
	
	player_animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func strafe(direction: Vector2) -> void:
	can_strafe = false
	speed_trail_line_2d.visible=true
	if direction == Vector2.ZERO:
		return

	var strafe_timer = get_tree().create_timer(strafe_duration)
	strafe_timer.timeout.connect(_on_strafe_finished)
	
func _on_strafe_finished() -> void:
	player_animated_sprite_2d.speed_scale = 1
	speed_trail_line_2d.visible = false
	can_strafe = true
	

func load_stats_skills():
	for key in Globals.player_data.stats:
		Globals.current_player.stats[key] =  Globals.player_data.stats[key]
	for key in Globals.player_data.skills:
		Globals.current_player.skills[key] =  Globals.player_data.skills[key]


func load_player_data():
	Globals.player_data.get_player_data()
	for spell_key in Globals.item_resources.master_spell_book:
		var spell = Globals.item_resources.master_spell_book[spell_key]
		if spell.is_unlocked:
			available_spells[spell_key] = spell
	if Globals.player_data:
		load_stats_skills()
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
	for i in range(max_equippable_spells):  # max 4
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
	if current_spell.spell_type == Spell.CAST_TYPES.PROJECTILE:
		# Spawn the projectile at the player's position
		var projectile = ProjectileSpell.instantiate()
		projectile.direction = direction
		#print(direction)
		projectile.projectile_owner_group = self.get_groups()
		projectile.speed = current_spell.spell_speed
		projectile.explosion_duration = current_spell.explosion_dur
		projectile.explosion_radius = current_spell.explosion_radius
		projectile.damage = current_spell.spell_damage + stats["Magic"] * 0.2 + skills["Wizardry"] * 2
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
		

	
func load_inventory():
	player_inventory = Globals.player_data.inventory
	
	for slot in player_inventory.inv_slots:
		var index = Globals.in_game_ui.inventory_item_list.add_item(slot.item_name)
		Globals.in_game_ui.inventory_item_list.set_item_metadata(index, slot) 
	
	
func load_spells():

	for i in range(max_equippable_spells):
		var spell_panels = Globals.in_game_ui.spell_grid_container.get_children() #spells panels
		if Globals.player_data.equipped_spells[i]:
			var texture_rect = TextureRect.new()
			texture_rect.texture = Globals.player_data.equipped_spells[i].item_graphic.texture
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
		player_weapon_holding_type = item_meta.ITEM_TYPE.SWORD
		weapon_sprite = item_meta.weapon_character_sprite
		weapon_sprite.position = player_animated_sprite_2d.position
		weapon_sprite.z_index = 2
		weapon_sprite.animation_finished.connect(_on_wep_animation_finished)
		add_child(weapon_sprite)
		item_to_equip = Globals.item_resources.master_weapon_book[item_meta.item_id]
	if item_meta.item_type == item_meta.ITEM_TYPE.BOW and not weapon_sprite:
		player_weapon_holding_type = item_meta.ITEM_TYPE.BOW
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

func handle_menu():
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

func get_input():
	
	handle_menu()
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var base_speed = stats["Speed"] * 20
	
	
	if Input.is_action_pressed("sprint"):
		player_animated_sprite_2d.speed_scale = 1
		base_speed *= 1.5
	elif Input.is_action_just_released("sprint"):
		player_animated_sprite_2d.speed_scale = 1
	if Input.is_action_just_pressed("strafe") and can_strafe and velocity.length() > 0:
		strafe(input_direction)
	if not can_strafe:
		player_animated_sprite_2d.speed_scale = 1
		base_speed *= 6.0
	velocity = input_direction * base_speed
	

func handle_spell():
	player_animated_sprite_2d.play("man_cast_"+facing)
func _on_wep_animation_finished():
	weapon_sprite.visible = false
	
func _on_animation_finished():
	is_animating_spell = false;
	is_animating_attack = false;
	


func handle_attack():
	weapon_sprite.visible = true
	player_animated_sprite_2d.speed_scale = 1
	if(weapon_sprite):
		weapon_sprite.play(facing)
		if player_weapon_holding_type == Weapon.ITEM_TYPE.SWORD:
			player_animated_sprite_2d.play("man_attack_"+facing)
		if player_weapon_holding_type == Weapon.ITEM_TYPE.BOW:
			player_animated_sprite_2d.play("man_bow_"+facing)
	

func is_animating():
	# chain together animation blockers
	return is_animating_spell || is_animating_attack

func set_animation():

		
	if Input.is_action_pressed("spell_attack"):
		is_animating_spell = true;
		#anim_lock_timer.start(1.0)
	elif Input.is_action_pressed("wep_attack"):
		is_animating_attack = true;
		#anim_lock_timer.start(1.0)

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
			#match facing:
				#"right":
				player_animated_sprite_2d.play("man_walk_"+facing)
				#Direction.UP:
					#player_animated_sprite_2d.play("man_walk_up")
				#Direction.LEFT:
					#player_animated_sprite_2d.play("man_walk_left")
				#Direction.DOWN:
					#player_animated_sprite_2d.play("man_walk_down")
		else:
			# play idle animation based on move_dir
			player_animated_sprite_2d.play("man_idle_"+facing)
				

func apply_knockback(direction: Vector2):
	#dummy vars, make configurable
	var knockback_strength: float = 500.0
	var knockback_duration: float = 0.2 
	direction = direction.normalized()
	knockback_velocity = direction * knockback_strength
	
	is_knockback_active = true
	await get_tree().create_timer(knockback_duration).timeout
	is_knockback_active = false

func check_interaction_collision():
	if interaction_ray_cast_2d.is_colliding():
		var hit_object = interaction_ray_cast_2d.get_collider()
		if hit_object is Area2D and hit_object.has_meta("npc"):
			interacting_npc = hit_object.get_parent()
		else:
			interacting_npc = null
	else:
		interacting_npc = null

	if interacting_npc and Input.is_action_just_pressed("interact"):
		if not is_talking:
			is_talking = true
			start_dialogue(interacting_npc)

#figure out a way to make this more flexible
func start_dialogue(npc: Npc):
	var dlg = DIALOGUE_UI.instantiate()
	add_child(dlg)
	dlg.visible = true
	
	var current_quest = QuestState.get_next_incomplete_quest(QuestState.master_quest_book, npc.npc_id)
	var current_quest_data = current_quest.data
	
	QuestState.current_quest_QUEST_ORDER = current_quest.data[QuestState.QUEST_META.QUEST_ORDER]
	QuestState.current_quest_QUEST_COMPLETED = current_quest.data[QuestState.QUEST_META.QUEST_COMPLETED]
	QuestState.current_quest_QUEST_STARTED = current_quest.data[QuestState.QUEST_META.QUEST_STARTED]
	QuestState.current_quest_QUEST_SPAWN = current_quest.data[QuestState.QUEST_META.QUEST_SPAWN]
	QuestState.current_quest_QUEST_LOCATION = current_quest.data[QuestState.QUEST_META.QUEST_LOCATION]
	QuestState.current_quest_QUEST_REQUIREMENTS = current_quest.data[QuestState.QUEST_META.QUEST_REQUIREMENTS]
	
	dlg.start(
		npc.npc_dialogue,
		current_quest.name,
		{ 
			npc.npc_name: npc.npc_avatar_normal,
			"You": current_expression
		},
	)

func set_current_expression(sprite: Sprite2D):
	current_expression = sprite

func find_and_create_new_quests():
	for quest in new_quests:
		print(quest)
	
	active_quests.merge(new_quests, false)

func handle_new_quest_notification(quest_requirements: String):

	var notification = Panel.new()
	notification.custom_minimum_size = Vector2(300, 150)
	notification.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	notification.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.7, 0.6, 0.2)
	notification.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(280, 130)
	vbox.size_flags_horizontal = Control.SIZE_FILL
	vbox.size_flags_vertical = Control.SIZE_FILL
	vbox.position = Vector2(10, 10)

	var title = Label.new()
	title.text = "New Quest!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	title.add_theme_font_size_override("font_size", 24)

	var requirements_label = Label.new()
	requirements_label.text = quest_requirements
	requirements_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	requirements_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	requirements_label.custom_minimum_size = Vector2(260, 0)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	
	var button = Button.new()
	button.text = "Accept"
	button.custom_minimum_size = Vector2(100, 30)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.focus_mode = Control.FOCUS_NONE
	
	vbox.add_child(title)
	vbox.add_child(spacer)
	vbox.add_child(requirements_label)
	vbox.add_child(button)
	
	notification.add_child(vbox)
	
	notification.position = Vector2(300, notification.custom_minimum_size.y)

	Globals.in_game_ui.add_child(notification)
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(notification, "position:y", 50, 0.5)
	

	button.pressed.connect(func():
		var dismiss_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		dismiss_tween.tween_property(notification, "position:y", -150, 0.3)
		dismiss_tween.tween_callback(notification.queue_free)
	)

	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(notification) and notification.is_inside_tree():
		var timeout_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		timeout_tween.tween_property(notification, "position:y", -150, 0.3)
		timeout_tween.tween_callback(notification.queue_free)

func _physics_process(delta):
	var velocity = Vector2.ZERO
	if is_knockback_active:
		velocity = knockback_velocity
	if not is_animating():
		get_input()
		move_and_slide()

func _process(delta):
	
	if set_up_new_quests:
		find_and_create_new_quests()
		set_up_new_quests = false
		
	
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	
	var direction_local = direction.rotated(-rotation)
	aim_angle = rad_to_deg(direction_local.angle())
	
	check_interaction_collision()
	if aim_angle >= -45 and aim_angle < 45:
		facing = "right"
		interaction_ray_cast_2d.rotation_degrees = 90
	elif aim_angle >= 45 and aim_angle < 135:
		facing = "down"
		interaction_ray_cast_2d.rotation_degrees = 180
	elif aim_angle >= 135 or aim_angle < -135:
		facing = "left"
		interaction_ray_cast_2d.rotation_degrees = 270
	else:
		facing = "up"
		interaction_ray_cast_2d.rotation_degrees = 0
	set_animation()
	set_current_spell()
