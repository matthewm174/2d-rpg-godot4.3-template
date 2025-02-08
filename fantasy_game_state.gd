extends Node2D

var enemies

func _init() -> void:
	Globals.item_resources = ItemResources.new()
	Globals.enemy_resources = MobResource.new()
	Globals.player_data =  PlayerDataResource.new()
	var skeleton = Globals.enemy_resources.master_mobs_book["skeleton"]
	add_child(skeleton)
