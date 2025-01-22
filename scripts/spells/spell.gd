extends Node
class_name Spell



var spell_type: Globals.SPELL_TYPES
var spell_damage: int
var spell_graphic
var spell_range: float
var spell_cast_time: float
var spell_magnitude: float
var is_unlocked: bool

func _init(stype, sdmg, sgrph, srng, sct, smag, iu):
	spell_type = stype
	spell_damage = sdmg
	spell_graphic = sgrph
	spell_range = srng
	spell_magnitude = smag
	spell_cast_time = sct
	is_unlocked = iu
