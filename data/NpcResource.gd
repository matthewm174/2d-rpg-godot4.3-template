extends Node
class_name NpcResource

var master_npc_book: Dictionary
const PIGGUMS = preload("res://ui/dialogue/npc/piggums_mcdoo/piggums_mcdoo.dialogue")

func _init():
	create_piggums_mcdoo()
	
func create_piggums_mcdoo():
	var piggum_anims_walk = AnimationUtils.load_action_animation_sheet("res://sprites/npc/piggums_mcdoo/walk.png", Vector2(64, 64))
	var piggum_anims_idle = AnimationUtils.load_action_animation_sheet("res://sprites/npc/piggums_mcdoo/idle.png", Vector2(64, 64))
	var piggums_avatars = AnimationUtils.load_avatar("res://sprites/npc/piggums_mcdoo/avatar.png", Vector2(128, 128))
	var piggums_mcdoo = Npc.new(piggum_anims_walk, piggum_anims_idle, [Vector2(300,-100), Vector2(300,-200)], "Piggums McDoo", "piggums_mcdoo", PIGGUMS)
	piggums_mcdoo.npc_avatar_normal = piggums_avatars
	master_npc_book["piggums_mcdoo"] = piggums_mcdoo
