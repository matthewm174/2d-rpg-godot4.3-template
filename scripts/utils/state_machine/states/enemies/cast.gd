extends EnemyState
class_name EnemyCastState

const ProjectileSpell = preload("res://scripts/projectile/Projectile.tscn")
const TargetSpell = preload("res://scripts/target_spell/TargetSpell.tscn")

func enter(previous_state_path: String, data := {}) -> void:
	## play current spelll animation, then go back to defend or roll back
	pass


func physics_update(_delta: float) -> void:
	pass


func try_cast():
	if char_body.caster and char_body.can_cast and char_body.player_ref:
		char_body.can_cast = false
		char_body.is_animating_spell = true
		char_body.enemy_animated_sprite_2d.play("cast_"+char_body.facing)
		char_body.current_spell = char_body.enemy_spells[char_body.select_spell()]
		create_projectile_for_current_spell()


func select_spell():
	if char_body.enemy_spells.is_empty():
		return -1
	
	return randi() % char_body.enemy_spells.size()


func create_projectile_for_current_spell():
	
	if char_body.current_spell == null:
		return
	var mouse_position = char_body.get_global_mouse_position()
	var direction = (mouse_position - char_body.position).normalized()
	if char_body.current_spell.spell_type == Spell.CAST_TYPES.PROJECTILE:
		var projectile = ProjectileSpell.instantiate()
		projectile.projectile_owner_group = self.get_groups()
		projectile.direction = direction
		projectile.speed = char_body.current_spell.spell_speed
		projectile.explosion_duration = char_body.current_spell.explosion_dur
		projectile.explosion_radius = char_body.current_spell.explosion_radius
		projectile.damage = char_body.current_spell.spell_damage
		projectile.explosion_sprite_path = char_body.current_spell.explode_animation
		projectile.animation_name="missle"
		projectile.distance = char_body.current_spell.spell_range
		projectile.frame_count=7
		projectile.explodes = char_body.current_spell.explodes
		projectile.sprite_path= char_body.current_spell.spell_animation
		projectile.frame_size = Vector2i(64,64)
		projectile.position = char_body.position
		var computed_angle = rad_to_deg(direction.angle()) + 180.0
		projectile.rotation_degrees = fposmod(computed_angle, 360.0)
		get_tree().current_scene.add_child(projectile)
	if char_body.current_spell.spell_type == Spell.CAST_TYPES.TARGET:
		var target_spell = TargetSpell.instantiate()
		target_spell.damage = char_body.current_spell.spell_damage
		target_spell.animation_name = "missle"
		target_spell.frame_size = Vector2i(64,64)
		target_spell.sprite_path = char_body.current_spell.spell_animation
		target_spell.frame_count=7
		target_spell.position = mouse_position
		target_spell.explosion_duration = char_body.current_spell.explosion_dur
		target_spell.explosion_radius = char_body.current_spell.explosion_radius
		target_spell.initial_position = mouse_position
		target_spell.explosion_sprite_path = char_body.current_spell.explode_animation
		target_spell.explodes = char_body.current_spell.explodes
		target_spell.target_effects = char_body.current_spell.target_effects
		get_tree().current_scene.add_child(target_spell)
		
