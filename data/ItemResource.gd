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
	#example weapon
	# declare all resources and save to file, i guess this is how godot wants data
	var short_sword: Weapon = Weapon.new(10.0, Weapon.DAMAGE_TYPES.SLASH, false, "a bad weapon", 
	load_sprite_with_texture("res://sprites/inventory/weapons/short_sword_inventory.png"), Wearable_Item.UNIQUENESS.COMMON, [], "Short Sword")
	var sp_fire_ball: Spell = Spell.new(Spell.SPELL_TYPES.FIRE, 5.0, 10.0, 1.0, 2.0, true, 
	load_sprite_with_texture("res://sprites/inventory/spells/fire_ball_inventory.png"), "Fire Ball")
	
	master_spell_book["fire_ball"] = sp_fire_ball
	master_weapon_book["short_sword"] = short_sword
