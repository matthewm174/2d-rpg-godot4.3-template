extends Resource
class_name MobResource

var master_mobs_book: Dictionary

func _init():
	# declare all resources and save to file, i guess this is how godot wants data
	var skeleton_animations = AnimationUtils.load_character_animation_sheet("res://sprites/enemies/skeleton/skeleton_sprites.png", Vector2(64, 64))
	var skeleton:  = Enemy.new(20, 100, [Vector2(0,-100), Vector2(0,-200)], skeleton_animations, [], Globals.item_resources.master_weapon_book["short_sword"])
	master_mobs_book["skeleton"] = skeleton
