extends CanvasLayer
const ENEMY = preload("res://scripts/mobs/Enemy.tscn")
## Dialogue UI Controller ##
@onready var panel_container: PanelContainer = $PanelContainer
@onready var margin_container: MarginContainer = $PanelContainer/MarginContainer
@onready var h_box_container: HBoxContainer = $PanelContainer/MarginContainer/HBoxContainer
@onready var portrait_rect: TextureRect = $PanelContainer/MarginContainer/HBoxContainer/PortraitRect
@onready var portrait_image: TextureRect = $PanelContainer/MarginContainer/HBoxContainer/PortraitRect/MarginContainer/PortraitImage
@onready var v_box_container: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer
@onready var speaker_name: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/SpeakerName
@onready var dialogue_text: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/DialogueText
@onready var next_indicator: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/NextIndicator
@onready var spacer: Control = $PanelContainer/MarginContainer/HBoxContainer/Spacer
@onready var response_container: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/ResponseContainer
var quest_state_added
var response_text_rtf: RichTextLabel = RichTextLabel.new()
const PANEL_STYLE = preload("res://ui/dialogue/dialogue_style_box.tres")
const SPEAKER_NAME_FONT = preload("res://ui/dialogue/dialogue_label_settings.tres")
var dialog_avatars
var quest_accepted
var will_hide_balloon
var previous_quest_state_master_quest_book
var is_waiting_for_input: bool = false
var resource: DialogueResource
var current_quest
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		if not next_dialogue_line:
			queue_free()
			return
			
		is_waiting_for_input = false
		dialogue_line = next_dialogue_line
		
		update_display()
		handle_dialogue_flow()
		response_container.modulate.a = 0
		if dialogue_line.responses.size() > 0:
			for response in dialogue_line.responses:
				# Duplicate the template so we can grab the fonts, sizing, etc
				var item: RichTextLabel = response_text_rtf.duplicate()

				item.name = "Response%d" % response_container.get_child_count()
				if not response.is_allowed:
					item.name = String(item.name) + "Disallowed"
					item.modulate.a = 0.4
				item.text = response.text
				item.show()
				response_container.add_child(item)
		if dialogue_line.responses.size() > 0:
			response_container.modulate.a = 1
			configure_menu()
	
	get: return dialogue_line 

func _ready() -> void:
	quest_state_added = false
	
	create_tween().set_loops().tween_property(next_indicator, "modulate:a", 0.5, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	configure_theme()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)
	Engine.get_singleton("DialogueManager").dialogue_ended.connect(_on_dialogue_ended)
	hide()

func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()


func show_dialogue() -> void:
	show()
	
	dialogue_text.visible_ratio = 0
	var duration = dialogue_line.text.length() * 0.03
	create_tween().tween_property(dialogue_text, "visible_ratio", 1.0, duration)

func hide_dialogue() -> void:
	hide()

func get_responses() -> Array:
	var items: Array = []
	for child in response_container.get_children():
		if "Disallowed" in child.name: continue
		items.append(child)

	return items

func configure_menu() -> void:
	panel_container.focus_mode = Control.FOCUS_NONE

	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]

		item.focus_mode = Control.FOCUS_ALL

		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()

		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()

		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()

		item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
		item.gui_input.connect(_on_response_gui_input.bind(item))

	items[0].grab_focus()

func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: return

	item.grab_focus()

func _on_response_gui_input(event: InputEvent, item: Control) -> void:
	if "Disallowed" in item.name: return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		next(dialogue_line.responses[item.get_index()].next_id)
	elif event.is_action_pressed("ui_accept") and item in get_responses():
		next(dialogue_line.responses[item.get_index()].next_id)

func start(dialogue_resource: DialogueResource, title: String, avatars: Dictionary) -> void:
	previous_quest_state_master_quest_book = _deep_copy(QuestState.master_quest_book)
	dialog_avatars = avatars
	resource = dialogue_resource
	is_waiting_for_input = false
	self.dialogue_line = await resource.get_next_dialogue_line(title)
	show_dialogue()

func configure_theme() -> void:

	panel_container.add_theme_stylebox_override("panel", PANEL_STYLE)
	
	speaker_name.label_settings = SPEAKER_NAME_FONT
	
	response_text_rtf.add_theme_font_size_override("normal_font_size", 16)
	response_text_rtf.add_theme_color_override("default_color", Color.WHITE_SMOKE)
	
	response_text_rtf.fit_content = true
	dialogue_text.add_theme_font_size_override("normal_font_size", 16)
	dialogue_text.add_theme_color_override("default_color", Color.WEB_GRAY)
	
	dialogue_text.bbcode_enabled = true
	
	next_indicator.add_theme_color_override("font_color", Color.WHITE)
	next_indicator.label_settings = SPEAKER_NAME_FONT.duplicate()
	next_indicator.label_settings.font_size = 16


func apply_text_effects(text: String) -> String:
	return "[wave amp=10 freq=2][color=#FFFFFF]%s[/color][/wave]" % text

func name_to_id_format_string(input: String) -> String:
	return input.replace(" ", "_").to_lower()

func update_display() -> void:
	speaker_name.visible = not dialogue_line.character.is_empty()
	speaker_name.text = tr(dialogue_line.character, "dialogue")
	dialogue_text.text = apply_text_effects(dialogue_line.text)
	portrait_image.texture = dialog_avatars[dialogue_line.character].texture
	
	
	
	

func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id)


func _on_panel_container_gui_input(event: InputEvent) -> void:
	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		next(dialogue_line.next_id)
	elif event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == panel_container:
		next(dialogue_line.next_id)

func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			hide()
	)
func dictionary_difference(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var difference = {}

	# Check keys in dict1 that are not in dict2 or have different values
	for key in dict1:
		if not dict2.has(key):
			difference[key] = dict1[key]
		elif dict1[key] != dict2[key]:
			difference[key] = {"dict1": dict1[key], "dict2": dict2[key]}

	# Check keys in dict2 that are not in dict1
	for key in dict2:
		if not dict1.has(key):
			difference[key] = dict2[key]

	return difference

func _deep_copy(d: Dictionary) -> Dictionary:
	var copy = d.duplicate(false)
	for key in copy:
		if typeof(copy[key]) == TYPE_DICTIONARY:
			copy[key] = _deep_copy(copy[key])
	return copy

func find_quest_changes(prev: Dictionary, current: Dictionary) -> Dictionary:
	var changes = {
		"added": [],
		"removed": [],
		"modified": []
	}
	
	var test = dictionary_difference(prev[current_quest], current[current_quest])

	return changes



func handle_spawns():
	for spawn in QuestState.current_quest_QUEST_SPAWN:
		var enemy_copy = Globals.enemy_resources.master_mobs_book[spawn]
		var pat_points: Array[Vector2] = Vector2Utils.generate_patrol_points(QuestState.current_quest_QUEST_LOCATION, 3, 100)
		var enemy = Enemy.duplicate_instance(enemy_copy, pat_points)
		enemy.position = pat_points[0]
		Globals.fantasy_game_state.add_child(enemy)


func _on_dialogue_ended(_dialogue_resource: DialogueResource):
	Globals.current_player.is_talking = false

	if QuestState.init_quest:
		handle_spawns()
		Globals.current_player.handle_new_quest_notification(QuestState.current_quest_QUEST_REQUIREMENTS)
		QuestState.init_quest = false

func handle_dialogue_flow() -> void:
	if dialogue_line.text.is_empty(): return
	
	if dialogue_line.time != "":
		var timeout = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(timeout).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		panel_container.focus_mode = Control.FOCUS_ALL
		panel_container.grab_focus()
