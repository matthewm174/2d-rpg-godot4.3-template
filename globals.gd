extends Node

var current_player
var player_data: PlayerDataResource = PlayerDataResource.new()
var item_resources: ItemResources = ItemResources.new()
var wearables: Dictionary
var in_game_ui: In_Game_Ui

enum WEARABLE_LOCATIONS {
	Primary_Hand = 0,
	Secondary_Hand = 1,
	Head = 2, 
	Arms = 3,
	Legs = 4,
	Feet = 5
}
