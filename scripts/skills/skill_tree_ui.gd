extends Control

var skill_tree: SkillTree = SkillTree.new()
@onready var grid = $SkillTreeGridContainer
@onready var line_layer = Node2D.new()
# Preload the skill button scene
#var skill_button_scene: SkillButton

func _ready():
	# Create buttons for each skill
	for skill_id in skill_tree.skills:
		var skill = skill_tree.skills[skill_id]
		var button = SkillButton.new()
		button.skill_data = skill
		button.custom_minimum_size = Vector2(150, 50)
		grid.add_child(button)
		button.update_appearance()
		button.pressed.connect(_on_skill_button_pressed.bind(skill.id))
	
	# Draw lines between connected skills (call this after buttons are positioned)
	await get_tree().process_frame  # Wait for UI updates
	draw_connections()

func draw_connections():
	line_layer.queue_free()  # Clear old lines
	line_layer = Node2D.new()
	add_child(line_layer)

	for skill_id in skill_tree.skills:
		var skill = skill_tree.skills[skill_id]
		for prereq_id in skill.prerequisites:
			var from_button = get_button(prereq_id)
			var to_button = get_button(skill_id)
			if from_button and to_button:
				var line = Line2D.new()
				line.add_point(from_button.global_position + from_button.size / 2)
				line.add_point(to_button.global_position + to_button.size / 2)
				line.width = 2
				line.default_color = Color.WHITE
				line_layer.add_child(line)  # Add to the correct layer

func get_button(skill_id: String) -> SkillButton:
	for child in grid.get_children():
		if child is SkillButton and child.skill_data and child.skill_data.id == skill_id:
			return child
	return null

func _on_skill_button_pressed(skill_id: String):
	if skill_tree.unlock_skill(skill_id):
		update_ui()

func update_ui():
	for child in grid.get_children():
		child.update_appearance()
