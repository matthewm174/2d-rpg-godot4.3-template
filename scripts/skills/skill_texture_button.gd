extends Button
class_name SkillButton

var skill_data: SkillTree.SkillData
@onready var name_label: Label = Label.new()
@onready var cost_label: Label = Label.new()

signal skill_selected(skill_id)

func _on_pressed():
	if skill_data:
		emit_signal("skill_selected", skill_data.id)
		set_highlighted(true)

func _ready():
	pressed.connect(_on_pressed)
	custom_minimum_size = Vector2(150, 100)

	# Style the button directly
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 1)  # Dark gray background
	style_box.border_color = Color(1, 1, 1)      # White border
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	add_theme_stylebox_override("normal", style_box)

	# Container to align labels properly
	var label_container = VBoxContainer.new()
	label_container.anchor_left = 0.1
	label_container.anchor_top = 0.1
	label_container.anchor_right = 0.9
	label_container.anchor_bottom = 0.9
	label_container.offset_left = 5
	label_container.offset_top = 5
	label_container.offset_right = -5
	label_container.offset_bottom = -5
	label_container.alignment = BoxContainer.ALIGNMENT_CENTER

	# Name label
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_font_size_override("font_size", 16)

	# Cost label
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.add_theme_color_override("font_color", Color.YELLOW)
	cost_label.add_theme_font_size_override("font_size", 14)

	# Add labels to container
	label_container.add_child(name_label)
	label_container.add_child(cost_label)

	# Add container to button
	add_child(label_container)

	update_appearance()


func update_appearance():
	if skill_data and skill_data.unlocked:
		modulate = Color.GREEN
	else:
		modulate = Color.RED

	if skill_data:
		name_label.text = skill_data.name
		cost_label.text = "Cost: %d" % skill_data.cost

func set_highlighted(highlight: bool):
	if highlight:
		add_theme_color_override("font_color", Color.YELLOW)
	else:
		add_theme_color_override("font_color", Color.WHITE)
