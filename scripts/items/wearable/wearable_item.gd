extends Inventory_Slot
class_name Wearable_Item 

# this class defines anything that can be in an inventory and equipped
enum UNIQUENESS {
	COMMON,
	MAGIC,
	RARE,
	ANCIENT
}
enum WEARABLE_LOCATION {
	Primary_Hand = 0,
	Secondary_Hand = 1,
	Head = 2, 
	Arms = 3,
	Legs = 4,
	Feet = 5,
	Spells = 6,
}
enum ITEM_TYPE {
	SPELL,
	MELEE,
	ARM_ARMOR,
	HEAD_ARMOR,
	SHIELD
}




var item_equip_location: WEARABLE_LOCATION
var item_type: ITEM_TYPE
var item_graphic: Sprite2D #display graphic inv
var item_uniqueness: UNIQUENESS
var item_modifiers: Array[Item_Modifier]
