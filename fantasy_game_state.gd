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
	Globals.npc_data = NpcResource.new()
	Globals.fantasy_game_state = self
	
func _ready():
	var skeleton: Enemy = Globals.enemy_resources.master_mobs_book["skeleton"]
	skeleton.tilemap = ground
	skeleton.position = Vector2(-200, 300)
	add_child(skeleton)
	
	var piggums: Npc = Globals.npc_data.master_npc_book["piggums_mcdoo"]
	piggums.position = Vector2(300, 300)
	add_child(piggums)
	
