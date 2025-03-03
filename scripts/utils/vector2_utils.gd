extends Node
class_name Vector2Utils


static func generate_patrol_points(origin: Vector2, number_of_points: int, radius_of_search: float) -> Array[Vector2]:
	var patrol_points: Array[Vector2] = []
	
	for i in range(number_of_points):
		var random_offset = Vector2(
			randf_range(-radius_of_search, radius_of_search), 
			randf_range(-radius_of_search, radius_of_search)
		)
		patrol_points.append(origin + random_offset)
	
	return patrol_points
