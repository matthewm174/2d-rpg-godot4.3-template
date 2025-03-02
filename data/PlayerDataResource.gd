extends Resource
class_name PlayerDataResource
var save_path = "res://player_data.tres"
var name: String
var level
var skill_points_available
var stat_points_available
var skill_points_used
var unlocked_spells


## Stats
var stats := {
	"Strength": 5,
	"Wisdom": 5,
	"Magic": 5,
	"Dexterity": 5,
	"Luck": 5,
	"Speed": 5
}

## Skills
var skills := {
	"Fist": 1,
	"Cooking": 1,
	"Wizardry": 1,
	"Athletics": 1,
	"Sword": 1,
	"Bow": 1,
	"Pike": 1,
	"Prayer": 1
}


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
		Globals.player_data.name = "Domo Origami"
		Globals.player_data.level = 2
		Globals.player_data.skill_points_available = 1
		Globals.player_data.stat_points_available = 5
		Globals.player_data.skill_points_used = 1
		Globals.player_data.unlocked_spells = ['fire_ball', 'teleport']
		

		Globals.player_data.equipped_spells = { 0: null, 1: null, 2: null, 3: null }
		if testing:
			Globals.player_data.inventory.inv_slots.append(Globals.item_resources.master_spell_book["fire_ball"])
			Globals.player_data.inventory.inv_slots.append(Globals.item_resources.master_spell_book["teleport"])
			Globals.player_data.inventory.inv_slots.append(Globals.item_resources.master_weapon_book["short_sword"])
			Globals.player_data.inventory.inv_slots.append(Globals.item_resources.master_weapon_book["cedar_bow"])
			
		

	else:
		print("LOAD SAVE CALLED.")
		Globals.player_data = data
