extends EnemyState
class_name EnemyIdleState
var idle_timer = Timer.new()

func _ready() -> void:
	idle_timer.timeout.connect(_idle_timer_timeout)
	idle_timer.autostart = false
	add_child(idle_timer)
	pass

func _idle_timer_timeout():
	finished.emit("EnemyMeanderState")

func enter(previous_state_path: String, data := {}) -> void:
	print("idle_state")
	var new_time = char_body.get_movement_noise()
	idle_timer.wait_time = new_time
	idle_timer.start()
	pass
	
func update(delta):
	check_detect_player()
	
func exit():
	idle_timer.stop()


func physics_update(_delta: float) -> void:
	pass
