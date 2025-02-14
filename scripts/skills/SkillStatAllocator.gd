extends Control
class_name SkillStatAllocator

## Player attributes
var level: int = 1
var skill_points_available: int = 5
var stat_points_available: int = 10
var skill_points_used: int = 0
var unlocked_spells: Array[String] = []



## UI Elements
var stat_points_label: Label
var skill_points_label: Label
var stats_container: VBoxContainer
var skills_container: VBoxContainer

#func set_player_skills_stats(playerskills, playerstats):
	#skills = playerskills
	#stats = playerstats

	

func _ready():
	create_ui()

func create_ui():
	var main_container = Control.new()
	add_child(main_container)

	main_container.anchor_right = 1.0
	main_container.anchor_top = 0.0
	main_container.offset_right = -10
	main_container.offset_top = 10

	var hbox = HBoxContainer.new()
	main_container.add_child(hbox)

	var left_vbox = VBoxContainer.new()
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Stretch horizontally
	hbox.add_child(left_vbox)

	stat_points_label = Label.new()
	skill_points_label = Label.new()
	left_vbox.add_child(stat_points_label)
	left_vbox.add_child(skill_points_label)

	var stats_title = Label.new()
	stats_title.text = "Stats"
	stats_title.add_theme_color_override("font_color", Color.YELLOW)
	left_vbox.add_child(stats_title)

	stats_container = VBoxContainer.new()
	left_vbox.add_child(stats_container)
	
	for stat_name in Globals.player_data.stats.keys():
		stats_container.add_child(create_stat_row(stat_name, true))

	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(right_vbox)

	var skills_title = Label.new()
	skills_title.text = "Skills"
	skills_title.add_theme_color_override("font_color", Color.YELLOW)
	right_vbox.add_child(skills_title)

	skills_container = VBoxContainer.new()
	right_vbox.add_child(skills_container)
	
	for skill_name in Globals.player_data.skills.keys():
		skills_container.add_child(create_stat_row(skill_name, false))

	update_points_labels()

func create_stat_row(name: String, is_stat: bool) -> HBoxContainer:
	var row = HBoxContainer.new()

	var label = Label.new()
	label.text = "%s: %d" % [name, Globals.player_data.stats[name] if is_stat else Globals.player_data.skills[name]]
	label.name = name + "_label"
	row.add_child(label)

	var plus_button = Button.new()
	plus_button.text = "+"
	plus_button.pressed.connect(func(): increase_stat(name, is_stat, label))  # Pass the label to update
	row.add_child(plus_button)

	return row

func increase_stat(name: String, is_stat: bool, label: Label):
	if is_stat and stat_points_available > 0:
		Globals.player_data.stats[name] += 1
		stat_points_available -= 1
	elif not is_stat and skill_points_available > 0:
		Globals.player_data.skills[name] += 1
		skill_points_available -= 1

	label.text = "%s: %d" % [name, Globals.player_data.stats[name] if is_stat else Globals.player_data.skills[name]]

	update_points_labels()

func update_points_labels():
	stat_points_label.text = "Stat Points Available: %d" % stat_points_available
	skill_points_label.text = "Skill Points Available: %d" % skill_points_available
