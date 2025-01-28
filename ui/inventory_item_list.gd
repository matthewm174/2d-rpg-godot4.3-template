extends ItemList


var context_menu: PopupMenu
var selected_item_index: int = -1

func _ready():
  # Create the context menu
	context_menu = PopupMenu.new()
	add_child(context_menu)
	context_menu.add_item("Delete", 0)
	context_menu.add_item("Edit", 1)
	context_menu.id_pressed.connect(_on_menu_id_pressed)
  
  # Connect ItemList signals
	connect("item_clicked", _on_inventory_item_list_item_clicked)


func _on_inventory_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		selected_item_index = index
		context_menu.position = get_global_mouse_position()
		context_menu.popup()
#func _on_item_rmb_clicked(index: int, position: Vector2):

func _on_menu_id_pressed(id: int):
	match id:
		0: # Delete
			remove_item(selected_item_index)
		1: # Edit
			print("Editing item:", selected_item_index)
