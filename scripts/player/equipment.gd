extends Node
class_name Equipment
var equipment_slots: Dictionary


func _init():
	equipment_slots[Globals.WEARABLE_LOCATIONS.Primary_Hand] = Wearable_Item
	equipment_slots[Globals.WEARABLE_LOCATIONS.Secondary_Hand] = Wearable_Item
	equipment_slots[Globals.WEARABLE_LOCATIONS.Head] = Wearable_Item
	equipment_slots[Globals.WEARABLE_LOCATIONS.Arms] = Wearable_Item
	equipment_slots[Globals.WEARABLE_LOCATIONS.Legs] = Wearable_Item
	equipment_slots[Globals.WEARABLE_LOCATIONS.Feet] = Wearable_Item
