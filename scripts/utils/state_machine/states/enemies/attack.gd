extends EnemyState
class_name EnemyAttackState

func enter(previous_state_path: String, data := {}) -> void:
	
	pass


func try_attack():
	
	if char_body.can_attack and char_body.player_ref:
		char_body.can_attack = false
		char_body.is_animating_attack = true
		char_body.enemy_animated_sprite_2d.play("attack_"+char_body.facing)

func physics_update(_delta: float) -> void:
	pass
