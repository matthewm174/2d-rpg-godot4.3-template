extends Resource
class_name SpellDataResource

var fire_ball: Spell


func _init():
	fire_ball.is_unlocked = true
	fire_ball.spell_cast_time = 1
	fire_ball.spell_damage = 10
	fire_ball.spell_magnitude = 5
	fire_ball.spell_range = 2
	fire_ball.spell_type = Globals.SPELL_TYPES.FIRE
	Globals.spells["fire_ball"] = fire_ball
	
