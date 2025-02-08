extends Resource
class_name ItemResources


var master_spell_book: Dictionary
var master_weapon_book: Dictionary
var master_usables_book: Dictionary
#var short_sword: Weapon = Weapon.new()
#var bow: Weapon  = Weapon.new()
#var sp_fire_ball: Spell = Spell.new()

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
	Wearable_Item.ITEM_TYPE.MELEE, 
	Wearable_Item.WEARABLE_LOCATION.Primary_Hand, "short_sword")
	
	var sp_fire_ball: Spell = Spell.new(4.0, 30.0, 80.0, Spell.SPELL_TYPES.FIRE, 5.0, 200.0, 1.0, 2.0, 
	true, load_sprite_with_texture("res://sprites/inventory/spells/fire_ball_inventory.png"), 
	"Fire Ball", Wearable_Item.ITEM_TYPE.SPELL, Wearable_Item.WEARABLE_LOCATION.Spells, 
	"fire_ball", "res://sprites/spells/fireball_0.png", "res://sprites/explosions/explosion_dummy.png")
	
	
	master_spell_book["fire_ball"] = sp_fire_ball
	master_weapon_book["short_sword"] = short_sword
