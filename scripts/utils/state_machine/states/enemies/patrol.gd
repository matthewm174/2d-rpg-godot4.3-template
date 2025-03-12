extends EnemyState
class_name EnemyPatrolState
@onready var patrol_change_timer = Timer.new()



func _ready():
	var state_interval = 3
	patrol_change_timer.timeout.connect(_on_patrol_change_timer_timeout)
	patrol_change_timer.wait_time = state_interval
	patrol_change_timer.autostart = false
	add_child(patrol_change_timer)


func _on_patrol_change_timer_timeout():

	if char_body.is_dead || char_body.patrol_points.is_empty():
		return
	var current_target = (char_body.current_target + 1) % char_body.patrol_points.size()
	char_body.target_position = char_body.patrol_points[current_target]
	char_body.agent.target_position = char_body.target_position
	patrol_change_timer.start()

func enter(previous_state_path: String, data := {}) -> void:
	
	if char_body.is_dead || char_body.search_points.is_empty():
		return
	print("search_state")
	char_body.search_timer.stop()
	#char_body.enemy_state = ENEMY_STATE.PATROL
	if char_body.patrol_change_timer.is_stopped():
		char_body.patrol_change_timer.start()
	pass

func update(delta):
	check_detect_player()


func physics_update(_delta: float) -> void:
	
	pass
