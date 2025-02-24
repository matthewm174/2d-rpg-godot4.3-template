extends Node
class_name QuestStateTreeResource
var master_quest_book: Dictionary = {}
var piggums_quest_status: Dictionary = {}

func _init():
	piggums_quest_status["the_dark_skeleton"] = {}
	piggums_quest_status["the_dark_skeleton"]["started"] = false
	piggums_quest_status["the_dark_skeleton"]["completed"] = false
	piggums_quest_status["the_dark_skeleton"]["quest_requirements"] = "Defeat 3 Dark Skeletons Near The Building"
	piggums_quest_status["the_dark_skeleton"]["quest_spawn"] = ['dark_skeleton', 'dark_skeleton', 'dark_skeleton']
	piggums_quest_status["the_dark_skeleton"]["quest_location"] = Vector2(100, 800)
	master_quest_book["piggums_mcdoo"] = piggums_quest_status
