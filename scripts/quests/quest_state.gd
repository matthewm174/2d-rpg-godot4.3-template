extends Node
class_name QuestStateTreeResource
var master_quest_book: Dictionary = {}
var piggums_quest_status: Dictionary = {}

func _init():
	piggums_quest_status["the_dark_skeleton_started"] = false
	piggums_quest_status["the_dark_skeleton_completed"] = false
	master_quest_book["piggums_mcdoo"] = piggums_quest_status
