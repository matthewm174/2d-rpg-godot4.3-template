extends Wearable_Item
class_name Weapon
var damage_type
var damage
var is_ranged

enum DAMAGE_TYPES {
	SLASH, PIERCE, BLUNT
}

enum ITEM_MODIFIERS {
	ATTACK_BOOST,
	DEFENSE_BOOST,
	SPEED_BOOST,
	CRITICAL_CHANCE,
	LUCK
}


var weapon_character_sprite
func _init(dmg: float, 
dmg_type: DAMAGE_TYPES, 
is_rang: bool, 
descr: String, 
graphic: Sprite2D, 
uniqueness: Wearable_Item.UNIQUENESS, 
modifiers: Array[Item_Modifier],
wepname: String, 
itmtype: Wearable_Item.ITEM_TYPE, 
equiploc: Wearable_Item.WEARABLE_LOCATION, itemid: String, wep_ch_sprite: AnimatedSprite2D) -> void:

	damage_type = dmg_type
	damage = dmg
	item_graphic = graphic ##inventory graphic
	is_ranged = is_rang
	description = descr
	item_graphic = graphic
	item_uniqueness = uniqueness
	item_modifiers = modifiers
	item_name = wepname
	item_type = itmtype
	item_equip_location = equiploc
	item_id = itemid
	weapon_character_sprite = wep_ch_sprite

	
	
