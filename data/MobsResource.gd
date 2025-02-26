extends Resource
class_name MobResource

var master_mobs_book: Dictionary

func _init():
	# declare all resources and save to file, i guess this is how godot wants data
	var skeleton_animations = AnimationUtils.load_character_animation_sheet("res://sprites/enemies/skeleton/skeleton_sprites.png", Vector2(64, 64))
	var skeleton: Enemy = Enemy.new(20, 20, [Vector2(-200,-100), Vector2(-200,-200)], skeleton_animations, [], Globals.item_resources.master_weapon_book["short_sword"])
	master_mobs_book["skeleton"] = skeleton


	var dark_skeleton_animations = AnimationUtils.load_character_animation_sheet("res://sprites/enemies/skeleton/dark_skeleton_sprites.png", Vector2(64, 64))
	var dark_skeleton: Enemy = Enemy.new(20, 20, [], dark_skeleton_animations, [], Globals.item_resources.master_weapon_book["short_sword"])
	master_mobs_book["dark_skeleton"] = dark_skeleton
