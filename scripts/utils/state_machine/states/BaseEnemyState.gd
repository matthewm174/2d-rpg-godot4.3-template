class_name EnemyState extends State
const ATTACK = "Attack"
const AVOID = "Avoid"
const BLOCK = "Block"
const CAST = "Cast"
const CHASE = "Chase"
const DEATH = "Death"
const FLEE = "Flee"
const IDLE = "Idle"
const MEANDER = "Meander"
const PARRY = "Parry"
const PATROL = "Patrol"
const SEARCH = "Search"
const STAGGER = "Stagger"

var search_points
func check_detect_player():
	if char_body.detected_player:
		if char_body.is_seeker and not char_body.enemy_state_machine.state is EnemyChaseState:
			finished.emit("EnemyChaseState")
		## go to approach or chase
		elif not char_body.enemy_state_machine.state is EnemyApproachState:
			finished.emit("EnemyApproachState")
		pass

func generate_search_points():
	return Vector2Utils.generate_patrol_points(char_body.global_position, 8, 200)

func generate_patrol_points():
	return Vector2Utils.generate_patrol_points(char_body.global_position, 8, 200)
