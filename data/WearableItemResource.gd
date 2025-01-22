extends Resource
class_name WearableItemResources

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

var short_sword: Weapon

var bow: Weapon
func _init():
	# declare all resources and save to file, i guess this is how godot wants data
	short_sword.damage = 10
	short_sword.damage_type = DAMAGE_TYPES.SLASH
	short_sword.description = "pretty good."
	short_sword.is_ranged = false
	short_sword.item_type = ITEM_TYPES.MELEE
	# modifier type, number, if its a percentage
	short_sword.modifiers[0] = Item_Modifier.new(ITEM_MODIFIERS.ATTACK_BOOST, 10, true)
	
	
