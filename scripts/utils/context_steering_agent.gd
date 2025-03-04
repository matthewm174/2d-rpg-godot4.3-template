class_name ContextSteering
extends Node2D

@export var look_ahead: float = 100.0
@export var num_rays: int = 16

var ray_directions: PackedVector2Array
var interest: PackedFloat32Array
var danger: PackedFloat32Array

var chosen_dir: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var agent: CharacterBody2D
var params = PhysicsRayQueryParameters2D.new()
signal direction_updated(new_direction: Vector2)

func _init(p_agent: CharacterBody2D):
	agent = p_agent
func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	var angle_step = TAU / num_rays
	for i in num_rays:
		ray_directions[i] = Vector2.RIGHT.rotated(angle_step * i)

func calculate_direction(delta: float) -> Vector2:
	_update_interest()
	_update_danger()
	_choose_direction()
	return chosen_dir


func _get_target_direction() -> Vector2:
	if agent.agent.is_navigation_finished():
		return Vector2.ZERO
	return agent.agent.get_next_path_position() - agent.global_position

func _update_interest():
	interest.fill(0.0)
	var target_dir = _get_target_direction().normalized()
	
	for i in range(num_rays):
		var global_dir = agent.global_transform.basis_xform(ray_directions[i]).normalized()
		var weight = global_dir.dot(target_dir)
		interest[i] = maxf(weight, 0.0)

func _draw():
	var line_length = 50.0
	var danger_color = Color(1, 0, 0, 1.0)
	var interest_color = Color(0, 1, 0, 1.0)
	
	for i in range(num_rays):
		var diff = danger[i] - interest[i]
		
		var color = danger_color if diff > 0 else interest_color
		
		var length = abs(diff) * line_length
		var end_pos = Vector2.RIGHT.rotated(TAU / num_rays * i) * length
		
		draw_line(Vector2.ZERO, end_pos, color, 1.0)

func _update_danger():
	danger.fill(0.0)
	var space_state = agent.get_world_2d().direct_space_state
	params.exclude = [agent.get_rid()]
	
	for i in range(num_rays):
		var global_dir = agent.global_transform.basis_xform(ray_directions[i]).normalized()
		var start_pos = agent.global_position
		var end_pos = start_pos + global_dir * look_ahead
		
		params.from = start_pos
		params.to = end_pos
		
		var result = space_state.intersect_ray(params)
		if result:
			var dist = start_pos.distance_to(result.position)
			danger[i] = 1.0 - (dist / look_ahead)
	queue_redraw()

func _choose_direction():
	chosen_dir = Vector2.ZERO
	
	for i in num_rays:
		var weight = interest[i] * (1.0 - danger[i])
		chosen_dir += ray_directions[i] * weight
	
	chosen_dir = chosen_dir.normalized()
	direction_updated.emit(chosen_dir)
