
class_name TeleportEffect

static func teleport(target: PlayerCharacterBody2d, target_end_pos: Vector2):
	
	#print(target.position)
	#print(target.global_position)
	#print(target_end_pos)
	var tween = target.create_tween()
	#make this configgable
	var particles = GPUParticles2D.new()
	particles.position = target.player_animated_sprite_2d.position 
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.amount = 40
	particles.explosiveness = 1.0


	var process_material = ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EmissionShape.EMISSION_SHAPE_RING #idk why this seems to not work.
	process_material.emission_sphere_radius = 64
	process_material.initial_velocity_min = 30
	process_material.initial_velocity_max = 60 
	process_material.scale_min = 4.0
	process_material.scale_max = 2.0
	process_material.color = Color(0.1, 0.2, 1.0, 1.0)

	process_material.gravity = Vector3(0, 0, 0)
	process_material.direction = Vector3(0, -10, 0) 
	process_material.angular_velocity_min = 180
	process_material.angular_velocity_max = 360

	particles.process_material = process_material
	target.add_child(particles)

	# player animation
	tween.tween_property(target.player_animated_sprite_2d, "scale", Vector2(0.2, 1.5), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	target.position = target_end_pos
	tween = target.create_tween()
	tween.tween_property(target.player_animated_sprite_2d, "scale", Vector2(0.2, 1.5), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(target.player_animated_sprite_2d, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await target.get_tree().create_timer(particles.lifetime).timeout
	particles.queue_free()
