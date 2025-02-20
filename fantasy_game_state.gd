extends Node2D
@onready var world: Node2D = $"."

var enemies
@onready var ground: TileMapLayer = $Ground
@onready var below_ground: TileMapLayer = $BelowGround
@onready var second_level: TileMapLayer = $BackBufferCopy/SecondLevel

func _init() -> void:
	Globals.item_resources = ItemResources.new()
	Globals.enemy_resources = MobResource.new()
	Globals.player_data =  PlayerDataResource.new()

	
func _ready():
	var skeleton: Enemy = Globals.enemy_resources.master_mobs_book["skeleton"]
	skeleton.tilemap = ground
	add_child(skeleton)
	#skeleton.z_index = 0
	
