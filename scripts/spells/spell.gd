extends Wearable_Item
class_name Spell

var spell_type: CAST_TYPES
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
var explodes

var target_effects: Array[TARGET_EFFECT]

#explains what the spell does when cast
enum CAST_TYPES {
	PROJECTILE = 0, TEMPORAL = 1, SELF = 2, TARGET = 3
}

#defines how to handle effects on collision
enum TARGET_EFFECT {
	EXPLOSION = 0,
	TELEPORT = 1,
	MATERIALIZE = 2,
	NOVA = 3,
	GRAVITY = 4,
	SUMMONING = 5,
	LINKING = 7,
	TIME = 8
}


func _init(explode_dur, explode_rad, speed, stype, sdmg, srng, sct, smag, iu, graphic, spname, 
itmtype: Wearable_Item.ITEM_TYPE, equiploc: Wearable_Item.WEARABLE_LOCATION, itemid: String, spell_anim: String, explode_anim: String, make_explode: bool, target_fx: Array[TARGET_EFFECT]):
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
	explodes = make_explode
	target_effects = target_fx
