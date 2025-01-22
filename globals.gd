extends Node

var current_player
var player_data
var spells: Dictionary
var wearables: Dictionary
var in_game_ui: In_Game_Ui

func _init():
	player_data = PlayerDataResource.new()

enum SPELL_TYPES {
	WATER = 0, FIRE = 1, EARTH = 2, AIR = 3
}

enum WEARABLE_LOCATIONS {
	Primary_Hand = 0,
	Secondary_Hand = 1,
	Head = 2, 
	Arms = 3,
	Legs = 4,
	Feet = 5
}
