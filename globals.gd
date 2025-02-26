extends Node

var fantasy_game_state
var current_player: PlayerCharacterBody2d
var item_resources: ItemResources
var player_data: PlayerDataResource
var npc_data: NpcResource
var enemy_resources: MobResource
var wearables: Dictionary
var in_game_ui: In_Game_Ui
 
enum CollisionLayers {
	PLAYER = 1,
	ENEMY = 2,
	PROJECTILE = 4,
	WALL = 8,
}
