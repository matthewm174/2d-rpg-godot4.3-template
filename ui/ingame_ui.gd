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
@onready var skill_stat_allocator: SkillStatAllocator = $PlayerUi/SkillStatAllocator




var default_stylebox
var selected_stylebox
enum MENU_OPTIONS { SAVE=0, QUIT=1 }

func _init():
	Globals.in_game_ui = self

func show_main_menu():
	main_menu_item_list.visible = true

func hide_main_menu():
	main_menu_item_list.visible = false

func _ready() -> void:
	player_ui.set_tab_title(0, "Equipment")
	player_ui.set_tab_title(1, "Skills")
	player_ui.set_tab_title(2, "Stats")
	
	
	
	default_stylebox = StyleBoxFlat.new()
	default_stylebox.bg_color = Color(0.2, 0.2, 0.2, 0.3) 
	default_stylebox.border_color = Color(0.5, 0.5, 0.5, 1.0) 
	default_stylebox.border_width_left = 2
	default_stylebox.border_width_right = 2
	default_stylebox.border_width_top = 2
	default_stylebox.border_width_bottom = 2
	
	selected_stylebox = StyleBoxFlat.new()
	selected_stylebox.bg_color = Color(0.1, 0.5, 0.8, 0.3) 
	selected_stylebox.border_color = Color(0.8, 0.8, 0.8, 1.0)  
	selected_stylebox.border_width_left = 2
	selected_stylebox.border_width_right = 2
	selected_stylebox.border_width_top = 2
	selected_stylebox.border_width_bottom = 2
	player_ui_root.visible = true
	player_ui.visible = false
	create_spell_panels()


func create_spell_panels():
	for i in range(Globals.current_player.max_equippable_spells):
		var panel = Panel.new()
		panel.name = "spell_%d" % [i]
		panel.add_theme_stylebox_override("panel", default_stylebox)
		panel.set_custom_minimum_size(Vector2(64, 64))
		panel.z_index = 1
		spell_grid_container.add_child(panel)
		

func hide_hud():
	spell_grid_container.visible = false

func show_hud():
	spell_grid_container.visible = true


func show_inventory():
	hide_hud()
	player_ui.visible = true

func hide_inventory():
	show_hud()
	player_ui.visible = false

func _on_inventory_item_list_item_selected(index: int) -> void:
	var item = inventory_item_list.get_item_metadata(index)
	if not item:
		print('ITEM DOESNT HAVE METADATA, SOMETHING IS WRONG.')
		return
	update_description_panel(item)

func update_description_panel(item):
	description.text = item.description
	item_image.texture = item.item_graphic
	
	
func _on_main_menu_item_list_item_selected(index: int) -> void:
	print("Selected Item Index:", index)
	match index:
		MENU_OPTIONS.SAVE:
			Globals.player_data.save_player_data()
		MENU_OPTIONS.QUIT:
			get_tree().quit()
			
