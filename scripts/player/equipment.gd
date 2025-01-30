extends Node
class_name Equipment
var equipment_slots: Dictionary


func _init():
	equipment_slots[Wearable_Item.WEARABLE_LOCATION.Primary_Hand] = Wearable_Item
	equipment_slots[Wearable_Item.WEARABLE_LOCATION.Secondary_Hand] = Wearable_Item
	equipment_slots[Wearable_Item.WEARABLE_LOCATION.Head] = Wearable_Item
	equipment_slots[Wearable_Item.WEARABLE_LOCATION.Arms] = Wearable_Item
	equipment_slots[Wearable_Item.WEARABLE_LOCATION.Legs] = Wearable_Item
	equipment_slots[Wearable_Item.WEARABLE_LOCATION.Feet] = Wearable_Item
