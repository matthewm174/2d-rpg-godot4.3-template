extends ItemList


var context_menu: PopupMenu
var selected_item_index: int = -1
enum RIGHT_CLICK_MENU_INVENTORY {
	Equip = 0,
	ThrowOut = 1,
}

func _ready():
	context_menu = PopupMenu.new()
	add_child(context_menu)
	context_menu.add_item("Equip", RIGHT_CLICK_MENU_INVENTORY.Equip)
	context_menu.add_item("Throw out", RIGHT_CLICK_MENU_INVENTORY.ThrowOut)
	context_menu.id_pressed.connect(_on_menu_id_pressed)
	connect("item_clicked", _on_inventory_item_list_item_clicked)


func _on_inventory_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		selected_item_index = index  # Store the clicked item index
		context_menu.position = get_global_mouse_position()
		context_menu.popup()

func _on_menu_id_pressed(id: int):
	if selected_item_index == -1 or selected_item_index >= item_count:
		return
	var item_meta_data = get_item_metadata(selected_item_index)
	print("Selected item: ", item_meta_data)
	match id:
		RIGHT_CLICK_MENU_INVENTORY.Equip:
			Globals.current_player.equip_inv_item(item_meta_data)
			remove_item(selected_item_index)
		RIGHT_CLICK_MENU_INVENTORY.ThrowOut:
			remove_item(selected_item_index)
	selected_item_index = -1
