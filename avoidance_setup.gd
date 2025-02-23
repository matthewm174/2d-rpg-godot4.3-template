extends TileMapLayer

## NOTE: all avoidance should be stored in ID == 1!! atleast, this is what the script assumes

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in get_used_cells_by_id(1):
		return true
	return false
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in get_used_cells_by_id(1):
		tile_data.set_navigation_polygon(0, null)
