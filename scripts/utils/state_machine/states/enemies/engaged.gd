extends EnemyState
class_name EnemyEngagedState

func enter(previous_state_path: String, data := {}) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_combat_decisions():
	var should_move = true
	var distance = char_body.global_position.distance_to(Globals.current_player.character_body_2d.global_position)
	if distance <= char_body.attack_range:
		finished.emit("EnemyAttackState")
		should_move = false
	elif char_body.caster and distance <= char_body.cast_range:
		finished.emit("EnemtCastState")
		should_move = false
	return should_move
