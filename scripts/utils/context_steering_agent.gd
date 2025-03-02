class_name ContextSteering
extends RefCounted

## Configuration - export these if using as node
@export var max_speed: float = 50.0
@export var steer_force: float = 0.1
@export var look_ahead: float = 100.0
@export var num_rays: int = 8

# Data arrays using Godot 4's packed arrays
var ray_directions: PackedVector2Array
var interest: PackedFloat32Array
var danger: PackedFloat32Array

# State
var chosen_dir: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var agent: CharacterBody2D

signal direction_updated(new_direction: Vector2)

func _init(p_agent: CharacterBody2D):
	agent = p_agent # Adjust path as needed
	
	# Initialize arrays
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

func _update_interest():
	interest.fill(0.0)
	var target_dir: Vector2 = _get_target_direction()
	
	for i in num_rays:
		var ray_dir = ray_directions[i].rotated(agent.rotation)
		var weight = ray_dir.dot(target_dir.normalized())
		interest[i] = maxf(weight, 0.0)

func _update_danger():
	danger.fill(0.0)
	var space_state = agent.get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.new()
	
	for i in num_rays:
		var start_pos = agent.global_position
		var end_pos = start_pos + ray_directions[i].rotated(agent.rotation) * look_ahead
		
		params.from = start_pos
		params.to = end_pos
		params.collision_mask = 2
		
		var result = space_state.intersect_ray(params)
		if result:
			danger[i] = 1.0 - (start_pos.distance_to(result.position) / look_ahead)

func _choose_direction():
	chosen_dir = Vector2.ZERO
	
	for i in num_rays:
		var weight = interest[i] * (1.0 - danger[i])
		chosen_dir += ray_directions[i] * weight
	
	chosen_dir = chosen_dir.normalized()
	direction_updated.emit(chosen_dir)

func _get_target_direction() -> Vector2:
	if agent.agent.is_navigation_finished():
		return Vector2.ZERO
	return agent.agent.get_next_path_position() - agent.global_position
