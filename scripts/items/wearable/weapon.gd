extends Wearable_Item
class_name Weapon
var damage_type
var damage
var is_ranged
var description

enum DAMAGE_TYPES {
	SLASH, PIERCE, BLUNT
}
enum ITEM_TYPES {
	MAGIC, MELEE, PROJECTILE
}
enum ITEM_MODIFIERS {
	ATTACK_BOOST,
	DEFENSE_BOOST,
	SPEED_BOOST,
	CRITICAL_CHANCE,
	LUCK
}



func _init(dmg: float, dmg_type: DAMAGE_TYPES, is_rang: bool, descr: String, graphic: Sprite2D, uniqueness: UNIQUENESS, modifiers: Array[Item_Modifier], wepname: String) -> void:
	damage_type = dmg_type
	damage = dmg
	item_graphic = graphic
	is_ranged = is_rang
	description = descr
	item_graphic = graphic
	item_uniqueness = uniqueness
	item_modifiers = modifiers
	item_name = wepname
	
