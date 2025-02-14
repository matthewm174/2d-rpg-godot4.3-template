extends Wearable_Item
class_name Spell

var spell_type: SPELL_TYPES
var spell_damage: int
var spell_range: float
var spell_cast_time: float
var spell_magnitude: float
var spell_animation
var spell_speed: float
var explode_animation
var explosion
var is_unlocked: bool
var explosion_radius
var explosion_dur

enum SPELL_TYPES {
	WATER = 0, FIRE = 1, EARTH = 2, AIR = 3
}


func _init(explode_dur, explode_rad, speed, stype, sdmg, srng, sct, smag, iu, graphic, spname, itmtype: Wearable_Item.ITEM_TYPE, equiploc: Wearable_Item.WEARABLE_LOCATION, itemid: String, spell_anim: String, explode_anim: String):
	spell_type = stype
	spell_damage = sdmg
	spell_range = srng
	spell_magnitude = smag
	spell_cast_time = sct
	spell_animation = spell_anim
	spell_speed = speed
	explode_animation = explode_anim
	explosion_radius = explode_rad
	explosion_dur = explode_dur
	is_unlocked = iu
	item_uniqueness = UNIQUENESS.COMMON
	item_modifiers = []
	item_graphic = graphic
	item_name = spname
	item_equip_location = equiploc
	item_id = itemid
