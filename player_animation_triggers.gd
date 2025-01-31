extends AnimatedSprite2D

signal spell_cast
signal attack_slash

func _ready():
	frame_changed.connect(_on_frame_changed)

func _on_frame_changed():
	if animation == "spell_cast" and frame == 3:  # Adjust frame number
		emit_signal("spell_cast")
	elif animation == "slash_attack" and frame == 2:
		emit_signal("attack_slash")
