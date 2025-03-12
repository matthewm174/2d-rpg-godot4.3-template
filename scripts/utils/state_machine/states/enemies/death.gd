extends EnemyState
class_name EnemyDeathState

func enter(previous_state_path: String, data := {}) -> void:
	play_death()
	
func play_death():
	if not char_body.is_dead:
		char_body.is_dead = true
		char_body.enemy_animated_sprite_2d.play("death")


func physics_update(_delta: float) -> void:
	pass
