extends Node2D
class_name DebugPathDrawer

var agent: NavigationAgent2D  # Assign this from the enemy script
var debug_path: PackedVector2Array = []

func _process(_delta):
	if agent:
		debug_path = agent.get_current_navigation_path()
		queue_redraw()  # ✅ Correct way to update `_draw()`

func _draw():
	if debug_path.size() > 1:
		for i in range(debug_path.size() - 1):
			draw_line(debug_path[i] - global_position, debug_path[i + 1] - global_position, Color(1, 0, 0), 2)
