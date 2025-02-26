extends Node
class_name QuestStateTreeResource
var master_quest_book: Dictionary = {}
var init_quest = false

enum QUEST_META {
	QUEST_ORDER_MAX,
	QUEST_ORDER,
	QUEST_STARTED,
	QUEST_COMPLETED,
	QUEST_REQUIREMENTS,
	QUEST_SPAWN,
	QUEST_LOCATION
}

var current_quest_QUEST_STARTED: bool
var current_quest_QUEST_ORDER: int
var current_quest_QUEST_COMPLETED: bool
var current_quest_QUEST_SPAWN: Array
var current_quest_QUEST_LOCATION: Vector2
var current_quest_QUEST_REQUIREMENTS: String
var current_quest_QUEST_ORDER_MAX: int


func get_next_incomplete_quest(master_quest_book: Dictionary, character_name: String) -> Dictionary:
	if not master_quest_book.has(character_name):
		return {} # Return empty if character not found

	var character_quests = master_quest_book[character_name]
	var quests = get_sorted_quests(master_quest_book, character_name)
	
	for quest in quests:
		var data = quest.data
		if QUEST_META.QUEST_COMPLETED in data and not data[QUEST_META.QUEST_COMPLETED]:
			return quest # Return the first incomplete quest

	return {} # Return empty if all quests are completed

func get_sorted_quests(master_quest_book: Dictionary, character_name: String) -> Array:
	if not master_quest_book.has(character_name):
		return []

	var character_quests = master_quest_book[character_name]
	var quests = []
	
	for quest_name in character_quests.keys():
		if quest_name == "all_quests_complete":
			continue
		var quest_data = character_quests[quest_name]
		if QUEST_META.QUEST_ORDER in quest_data:
			quests.append({ "name": quest_name, "data": quest_data })
	quests.sort_custom(func(a, b): return a.data[QUEST_META.QUEST_ORDER] < b.data[QUEST_META.QUEST_ORDER])
	
	return quests

func check_all_quests_complete(master_quest_book: Dictionary, character_name: String) -> void:
	if not master_quest_book.has(character_name):
		return

	var character_quests = master_quest_book[character_name]
	
	for quest_name in character_quests.keys():
		if quest_name == "all_quests_complete":
			continue
		if QUEST_META.QUEST_ORDER_MAX in character_quests[quest_name] and character_quests[quest_name][QUEST_META.QUEST_ORDER_MAX] == true:
			character_quests["all_quests_complete"] = true
			return
	
	character_quests["all_quests_complete"] = false # Ensure it's false if no max-order quest is found


func _init():
	var piggums_quest_status = {
		"all_quests_complete": false,
		"the_dark_skeleton_2": {
			QUEST_META.QUEST_ORDER_MAX: true,
			QUEST_META.QUEST_ORDER: 1,
			QUEST_META.QUEST_STARTED: false,
			QUEST_META.QUEST_COMPLETED: false,
			QUEST_META.QUEST_REQUIREMENTS: "Defeat 1 Large Dark Skeleton Near The Building",
			QUEST_META.QUEST_SPAWN: ["velen_the_super_skelen"],
			QUEST_META.QUEST_LOCATION: Vector2(-100, -100)
		},
		"the_dark_skeleton": {
			QUEST_META.QUEST_ORDER: 0,
			QUEST_META.QUEST_STARTED: false,
			QUEST_META.QUEST_COMPLETED: false,
			QUEST_META.QUEST_REQUIREMENTS: "Defeat 3 Dark Skeletons Near The Building",
			QUEST_META.QUEST_SPAWN: ["dark_skeleton", "dark_skeleton", "dark_skeleton"],
			QUEST_META.QUEST_LOCATION: Vector2(10, 10)
		}
	}
	master_quest_book["piggums_mcdoo"] = piggums_quest_status
