extends Area2D

const DialogueUI = preload("res://ui/dialogue/dialogue_ui.tscn")


@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"


func action() -> void:
	var dialogue: Node = DialogueUI.instantiate()
	get_tree().current_scene.add_child(dialogue)
	dialogue.start(dialogue_resource, dialogue_start)
