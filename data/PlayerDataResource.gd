extends Resource
class_name PlayerDataResource
var save_path = "res://player_data.tres"
var name: String
#Stats
var strength
var wisdom
var magic
var dexterity
var luck
var speed

#Skills
var fighting
var cooking
var wizardry
var running
var inventory: Inventory = Inventory.new()
var equipment: Equipment = Equipment.new()
var spells: Array[Spell]
var data
var equipped_spells: Dictionary = {}

var testing = true

func _init():
	var data = load("res://player_data.tres") as PlayerDataResource

func save_player_data():
	ResourceSaver.save(Globals.player_data, save_path)
	pass
	
func get_player_data():
	if not data:
		print("NEW GAME CALLED.")
		Globals.player_data.name = ""

		#skills
		Globals.player_data.cooking = 1
		Globals.player_data.running = 1
		Globals.player_data.wizardry = 1
		Globals.player_data.fighting = 1
		
		#stats
		Globals.player_data.dexterity = 5
		Globals.player_data.magic = 5
		Globals.player_data.luck = 5
		Globals.player_data.wisdom = 5
		Globals.player_data.strength = 5
		Globals.player_data.speed = 5
		Globals.player_data.equipped_spells = { 0: null, 1: null, 2: null, 3: null }
		if testing:
			Globals.player_data.equipped_spells[0] = Globals.item_resources.master_spell_book["fire_ball"]
			Globals.player_data.inventory.inv_slots.append(Globals.item_resources.master_spell_book["fire_ball"])
			Globals.player_data.inventory.inv_slots.append(Globals.item_resources.master_weapon_book["short_sword"])
			#Globals.player_data.equipment.equipment_slots[Wearable_Item.WEARABLE_LOCATION.Primary_Hand] = Globals.item_resources.master_weapon_book["short_sword"]
		

	else:
		print("LOAD SAVE CALLED.")
		Globals.player_data = data
		#load save
