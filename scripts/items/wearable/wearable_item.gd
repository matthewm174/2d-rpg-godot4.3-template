extends Inventory_Slot
class_name Wearable_Item 

# this class defines anything that can be in an inventory and equipped
enum UNIQUENESS {
	COMMON,
	MAGIC,
	RARE,
	ANCIENT
}
#var item_type 
var item_graphic: Sprite2D #display graphic inv
var item_uniqueness: UNIQUENESS
var item_modifiers: Array[Item_Modifier]
