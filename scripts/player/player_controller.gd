extends CharacterBody2D
@onready var player_animated_sprite_2d: AnimatedSprite2D = $PlayerAnimatedSprite2d
@onready var anim_lock_timer: Timer = $Timer

@export var speed = 100
var player_inventory: Inventory
var player_data_resource: PlayerDataResource


enum Direction { RIGHT, LEFT, UP, DOWN }
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
func _init():
	Globals.current_player = self
	
	

func _ready():
	load_player_data()
	anim_lock_timer.wait_time = 0.5
	anim_lock_timer.timeout.connect(func(): 
		is_animating_spell = false;
		is_animating_attack = false;
	)
	#spell_equip_index = Globals.player_data.equipped_spells.size()
	
	
func load_player_data():
	Globals.player_data.get_player_data()
	for spell_key in Globals.item_resources.master_spell_book:
		var spell = Globals.item_resources.master_spell_book[spell_key]
		# Check if the spell is unlocked
		if spell.is_unlocked:
			available_spells[spell_key] = spell
	if Globals.player_data:
		load_spells()
		load_inventory()


	
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
			spell_panels[i].add_child(texture_rect)
			spell_equip_index+=1

func equip_inv_item(item_metadata: Wearable_Item):
	add_item_to_equipment_panel(item_metadata)

func append_to_spells(value):
	Globals.player_data.equipped_spells[spell_equip_index] = value
	spell_equip_index = (spell_equip_index + 1) % 4
	load_spells()

func add_item_to_equipment_panel(item_meta: Wearable_Item):
	var item_to_equip
	if item_meta.item_type == Wearable_Item.ITEM_TYPE.SPELL:
		item_to_equip = Globals.item_resources.master_spell_book[item_meta.item_id]
	elif item_meta.item_type == Wearable_Item.ITEM_TYPE.MELEE:
		item_to_equip = Globals.item_resources.master_weapon_book[item_meta.item_id]
	else:
		item_to_equip = Globals.item_resources.master_weapon_book[item_meta.item_id]
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
	velocity = input_direction * speed

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

func handle_attack():
	match move_dir:
		Direction.UP:
			player_animated_sprite_2d.play("man_attack_up")
		Direction.DOWN:
			player_animated_sprite_2d.play("man_attack_down")
		Direction.LEFT:
			player_animated_sprite_2d.play("man_attack_left")
		Direction.RIGHT:
			player_animated_sprite_2d.play("man_attack_right")

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
	if is_animating_attack:
		handle_attack()
		return
		
	
	if not is_animating() and Input.is_action_pressed("move_left"):
		player_animated_sprite_2d.play("man_walk_left")
		move_dir = Direction.LEFT
	elif Input.is_action_pressed("move_right"):
		player_animated_sprite_2d.play("man_walk_right")
		move_dir = Direction.RIGHT
	elif Input.is_action_pressed("move_down"):
		player_animated_sprite_2d.play("man_walk_down")
		move_dir = Direction.DOWN
	elif Input.is_action_pressed("move_up"):
		player_animated_sprite_2d.play("man_walk_up")
		move_dir = Direction.UP
	else:
		#if no action pressed, idle
		match move_dir:
			Direction.UP:
				player_animated_sprite_2d.play("man_idle_up")
			Direction.DOWN:
				player_animated_sprite_2d.play("man_idle_down")
			Direction.LEFT:
				player_animated_sprite_2d.play("man_idle_left")
			Direction.RIGHT:
				player_animated_sprite_2d.play("man_idle_right")

func _physics_process(delta):
	if not is_animating():
		get_input()
		move_and_slide()

func _process(delta):
	set_animation()
