extends ColorRect
class_name XrayRect

@onready var mask: MeshInstance2D = $BackBufferCopy/Mask
@onready var mask_2: Sprite2D = $BackBufferCopy/Sprite2D

func _process(delta: float) -> void:
	mask.global_position = Globals.current_player.position
	mask_2.global_position = Globals.current_player.position
