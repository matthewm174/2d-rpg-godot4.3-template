extends EnemyState
class_name EnemyMeanderState
var meander_timer = Timer.new()

func _ready() -> void:
	meander_timer.timeout.connect(_meander_timer_timeout)
	meander_timer.autostart = false
	add_child(meander_timer)
	pass
	
func _meander_timer_timeout():
	print("meander_idle")
	if char_body.is_dead:
		finished.emit("EnemyDeathState")
		return

		finished.emit("EnemyIdleState")

	pass

func enter(previous_state_path: String, data := {}) -> void:
	var new_time = char_body.get_movement_noise()
	meander_timer.wait_time = new_time
	var meander_points = Vector2Utils.generate_patrol_points(char_body.global_position, 8, 200)
	char_body.current_target = (char_body.current_target + 1) % meander_points.size()
	char_body.target_position = meander_points[char_body.current_target]
	char_body.agent.target_position = char_body.target_position
	pass


func update(delta):
	check_detect_player()
		

func physics_update(_delta: float) -> void:
	pass
