extends Resource
class_name ItemResources


var master_spell_book: Dictionary
var master_weapon_book: Dictionary
var master_usables_book: Dictionary
var master_clothing_book: Dictionary

func load_sprite_with_texture(texture_path: String) -> Sprite2D:
	var new_sprite = Sprite2D.new()
	new_sprite.texture = load(texture_path)
	return new_sprite

func _init():
	#example weaponfunc _init(
	# declare all resources and save to file, i guess this is how godot wants data
	var short_sword: Weapon = Weapon.new(10.0, 
	Weapon.DAMAGE_TYPES.SLASH, 
	false, 
	"a bad weapon", 
	load_sprite_with_texture("res://sprites/inventory/weapons/short_sword_inventory.png"), 
	Wearable_Item.UNIQUENESS.COMMON, 
	[], 
	"Short Sword", 
	Wearable_Item.ITEM_TYPE.SWORD, 
	Wearable_Item.WEARABLE_LOCATION.Primary_Hand, "short_sword", 
	AnimationUtils.load_equipment_animation_sheet("res://equipment/slash/WEAPON_dagger.png", Vector2i(64,64)))
	master_weapon_book["short_sword"] = short_sword
	
	var cedar_bow: Weapon = Weapon.new(10.0, 
	Weapon.DAMAGE_TYPES.PIERCE, 
	false, 
	"Simple but elegant", 
	load_sprite_with_texture("res://sprites/inventory/weapons/cedar_bow_inventory.png"), 
	Wearable_Item.UNIQUENESS.COMMON, 
	[], 
	"Cedar Bow", 
	Wearable_Item.ITEM_TYPE.BOW, 
	Wearable_Item.WEARABLE_LOCATION.Primary_Hand, "cedar_bow", 
	AnimationUtils.load_equipment_animation_sheet("res://equipment/bow/WEAPON_bow.png", 
	Vector2i(64,64)))
	master_weapon_book["cedar_bow"] = cedar_bow

	var bastard_sword: Weapon = Weapon.new(10.0, 
	Weapon.DAMAGE_TYPES.SLASH, 
	false, 
	"Sword for Bastards", 
	load_sprite_with_texture("res://sprites/inventory/weapons/short_sword_inventory.png"), 
	Wearable_Item.UNIQUENESS.COMMON, 
	[], 
	"Bastard Sword", 
	Wearable_Item.ITEM_TYPE.SWORD, 
	Wearable_Item.WEARABLE_LOCATION.Primary_Hand, "bastard_sword", 
	AnimationUtils.load_equipment_animation_sheet("res://equipment/slash/WEAPON_dagger.png", 
	Vector2i(64,64)))
	master_weapon_book["bastard_sword"] = bastard_sword
	
	#var iron_pauldron: Weapon = Weapon.new(10.0, 
	#Weapon.DAMAGE_TYPES.SLASH, 
	#false, 
	#"Sword for Bastards", 
	#load_sprite_with_texture("res://sprites/inventory/weapons/iron_pauldron_inventory.png"), 
	#Wearable_Item.UNIQUENESS.COMMON, 
	#[], 
	#"Bastard Sword", 
	#Wearable_Item.ITEM_TYPE.SWORD, 
	#Wearable_Item.WEARABLE_LOCATION.Primary_Hand, "bastard_sword", 
	#AnimationUtils.load_equipment_animation_sheet("res://equipment/slash/WEAPON_dagger.png", 
	#Vector2i(64,64)))
	#master_weapon_book["bastard_sword"] = bastard_sword
	
	#explode_dur, explode_rad, speed, 
	#stype, sdmg, srng, 
	#sct, smag, iu, 
	#graphic, spname, itmtype: Wearable_Item.ITEM_TYPE,
	#equiploc: Wearable_Item.WEARABLE_LOCATION, 
	#itemid: String, spell_anim: String, explode_anim: String
	var sp_fire_ball: Spell = Spell.new(
		1.0, 
		30.0, 
		180.0, 
		Spell.CAST_TYPES.PROJECTILE,
		5.0, 
		200.0, 
		1.0, 
		2.0, 
	true, 
	load_sprite_with_texture("res://sprites/inventory/spells/fire_ball_inventory.png"), 
	"Fire Ball",
	 Wearable_Item.ITEM_TYPE.SPELL, 
	Wearable_Item.WEARABLE_LOCATION.Spells, 
	"fire_ball", 
	"res://sprites/spells/fireball_0.png", 
	"res://sprites/explosions/explosion_dummy.png", 
	true, 
	[Spell.TARGET_EFFECT.EXPLOSION]
	)
	master_spell_book["fire_ball"] = sp_fire_ball
	

	
	var sp_teleport: Spell = Spell.new(
		0.0, #explode dur
		0.0, #explode Radius
		1000.0, #Speed
		Spell.CAST_TYPES.TARGET, #Casting Type
		0.0, #base damage
		9999.0, #range
		0.3, #cast time
		0.0, #Magnitude (unused...)
		true, #unlocked
		load_sprite_with_texture("res://sprites/inventory/spells/teleport_inventory.png"), #Inventory display
		"Teleport", # Proper name
		Wearable_Item.ITEM_TYPE.SPELL, # For validation
		Wearable_Item.WEARABLE_LOCATION.Spells, #For validation
		"teleport", #lookup name (ID)
		"res://sprites/spells/icicle_0.png", # Sprite Sheet for animation
		"", #explosion sprites
		false,
		[Spell.TARGET_EFFECT.TELEPORT] #effects
		) #if it explodes, will probably refactor this
	master_spell_book["teleport"] = sp_teleport
