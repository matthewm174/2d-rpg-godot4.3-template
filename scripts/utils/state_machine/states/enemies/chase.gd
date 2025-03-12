extends EnemyState
class_name EnemyChaseState

var chase_state_timer = Timer.new()
var chase_state_interval: float = 15.0


func _ready():
	chase_state_timer.wait_time = chase_state_interval
	chase_state_timer.autostart = false
	chase_state_timer.timeout.connect(_chase_state_completed)
	add_child(chase_state_timer)
	
	pass

func _chase_state_completed():
	if char_body.detected_player == false:
		finished.emit("EnemySearchState")

func enter(previous_state_path: String, data := {}) -> void:
	print("chase_state")
	chase_state_timer.start()
	pass

func update(delta):
	check_detect_player()

func exit():
	chase_state_timer.stop()
	pass

func physics_update(_delta: float) -> void:
	pass
