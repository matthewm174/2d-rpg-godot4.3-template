extends AnimatedSprite2D

signal spell_cast
signal attack_slash

func _ready():
	frame_changed.connect(_on_frame_changed)

func _on_frame_changed():
	
	var cast_regex = RegEx.new()
	cast_regex.compile("^man_cast")  # Regex pattern for "starts with man_cast"
	
	if cast_regex.search(animation) and frame == 3:
		Globals.current_player.create_projectile_for_current_spell()
