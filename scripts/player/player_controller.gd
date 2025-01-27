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

func _init():
	Globals.current_player = self
	

func _ready():
	load_player_data()
	anim_lock_timer.wait_time = 0.5
	anim_lock_timer.timeout.connect(func(): 
		is_animating_spell = false;
		is_animating_attack = false;
	)
	
	
func load_player_data():
	Globals.player_data.get_player_data()
	if Globals.player_data:
		load_spells()
		load_equip()
		load_inventory()


	
func load_inventory():
	player_inventory = Globals.player_data.inventory
	
	for slot in player_inventory.inv_slots:
		Globals.in_game_ui.inventory_item_list.add_item(slot.item_name)
	
	
func load_equip():
	
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
			#var testing1 = Globals.item_resources.master_spell_book["fire_ball"]
			texture_rect.texture = Globals.item_resources.master_spell_book["fire_ball"].item_graphic.texture  # Set the texture
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # Adjust the stretch mode
			spell_panels[i].add_child(texture_rect)

	
func load_spells():
	# find spells that are unlocked
	
	# player_data_resource.spells.append()
	for spell_key in Globals.item_resources.master_spell_book:
		var spell = Globals.item_resources.master_spell_book[spell_key]
		# Check if the spell is unlocked
		if spell.is_unlocked:
			available_spells[spell_key] = spell


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
