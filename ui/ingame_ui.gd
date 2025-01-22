extends Control
class_name In_Game_Ui
@onready var player_ui_root: Control = $"."
@onready var player_ui: TabContainer = $PlayerUi
@onready var items_h_split_container: HSplitContainer = $PlayerUi/ItemsHSplitContainer
@onready var desc_equip_v_split_container: VSplitContainer = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer
@onready var description: RichTextLabel = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/Description
@onready var image_equip_h_split_container: HSplitContainer = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/ImageEquipHSplitContainer
@onready var item_image: TextureRect = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/ImageEquipHSplitContainer/ItemImage
@onready var equip_panel: Panel = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/ImageEquipHSplitContainer/EquipPanel
@onready var arms_panel: Panel = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/ImageEquipHSplitContainer/EquipPanel/ArmsPanel
@onready var head_panel: Panel = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/ImageEquipHSplitContainer/EquipPanel/HeadPanel
@onready var legs_panel: Panel = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/ImageEquipHSplitContainer/EquipPanel/LegsPanel
@onready var primary_panel: Panel = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/ImageEquipHSplitContainer/EquipPanel/PrimaryPanel
@onready var secondary_panel: Panel = $PlayerUi/ItemsHSplitContainer/DescEquipVSplitContainer/ImageEquipHSplitContainer/EquipPanel/SecondaryPanel
@onready var inventory_item_list: ItemList = $PlayerUi/ItemsHSplitContainer/InventoryItemList
@onready var main_menu_item_list: ItemList = $MainMenuItemList
@onready var spell_grid_container: GridContainer = $SpellGridContainer

enum MENU_OPTIONS { SAVE=0, QUIT=1 }

func _init():
	Globals.in_game_ui = self

func show_main_menu():
	main_menu_item_list.visible = true

func hide_main_menu():
	main_menu_item_list.visible = false

func _ready() -> void:
	player_ui_root.visible = true
	create_spell_panels()

func create_spell_panels():
	for i in range(Globals.current_player.equipped_spells):
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1)
		var panel = Panel.new()
		panel.add_theme_stylebox_override("panel", style)
		panel.set_custom_minimum_size(Vector2(40, 40))
		spell_grid_container.add_child(panel)

func show_inventory():
	player_ui.visible = true

func hide_inventory():
	player_ui.visible = false

func _on_inventory_item_list_item_selected(index: int) -> void:
	update_description_panel()
	pass # Replace with function body.

func update_description_panel():
	## dummy code, delete
	var image := Image.create(30, 30, false, Image.FORMAT_RGBA8)
	image.fill(Color.ALICE_BLUE)
	var texture := ImageTexture.create_from_image(image)
	##
	
	description.text = "test description1232123"
	item_image.texture = texture
	
func _on_main_menu_item_list_item_selected(index: int) -> void:
	print("Selected Item Index:", index)
	match index:
		MENU_OPTIONS.SAVE:
			Globals.player_data.save_player_data()
		MENU_OPTIONS.QUIT:
			get_tree().quit()
			
	pass # Replace with function body.
