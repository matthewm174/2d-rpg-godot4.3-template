extends EnemyState
class_name EnemySearchState

var search_timer = Timer.new()
#var search_points
var times_iterated

func _ready() -> void:
	#search_iterations = randi() % 9 + 2
	search_timer.wait_time = 10
	search_timer.autostart = false
	search_timer.timeout.connect(_on_search_change_timer_timeout)
	add_child(search_timer)
	
func _on_search_change_timer_timeout():
	print("search")
	times_iterated+=1
	if char_body.is_dead || char_body.search_points.is_empty():
		return
	if times_iterated < char_body.search_points.size():
		search_timer.stop()
		finished.emit("EnemyMeanderState")
	else:
		search_timer.start()

func enter(previous_state_path: String, data := {}) -> void:
	search_timer.start()
	char_body.search_points = generate_search_points()
	times_iterated = randi() % 9 + 2

func physics_update(_delta: float) -> void:
	pass
