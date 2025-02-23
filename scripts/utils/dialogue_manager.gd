# DialogueManager.gd
extends Node
class_name _DialogueManager
# Signals
signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String)



var current_dialogue_id: String = ""
var current_dialogue_index: int = 0
var is_dialogue_active: bool = false
