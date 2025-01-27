extends Wearable_Item
class_name Spell

var spell_type: SPELL_TYPES
var spell_damage: int
var spell_range: float
var spell_cast_time: float
var spell_magnitude: float
var is_unlocked: bool

enum SPELL_TYPES {
	WATER = 0, FIRE = 1, EARTH = 2, AIR = 3
}


func _init(stype, sdmg, srng, sct, smag, iu, graphic, spname):
	spell_type = stype
	spell_damage = sdmg
	spell_range = srng
	spell_magnitude = smag
	spell_cast_time = sct
	is_unlocked = iu
	item_uniqueness = UNIQUENESS.COMMON
	item_modifiers = []
	item_graphic = graphic
	item_name = spname
