extends Resource
class_name SkillTree
## WIP
class SkillData:
	var id: String
	var name: String
	var description: String
	var cost: int
	var unlocked: bool = false
	var prerequisites: Array = [] 


var skills: Dictionary = {}
# TODO: hook up to available spells in player
func _init():
	add_skill("fire_1", "Fireball", "Basic fire spell", 1, [])
	add_skill("fire_2", "Inferno", "Upgraded fire spell", 2, ["fire_1"])

func add_skill(id: String, name: String, description: String, cost: int, prerequisites: Array):
	var skill = SkillData.new()
	skill.id = id
	skill.name = name
	skill.description = description
	skill.cost = cost
	skill.prerequisites = prerequisites
	skills[id] = skill

func unlock_skill(id: String) -> bool:
	var skill = skills.get(id)
	if not skill:
		return false
	
	# check prerequisites
	for prereq_id in skill.prerequisites:
		if not skills[prereq_id].unlocked:
			return false
	
	# check if already unlocked or insufficient points
	if skill.unlocked:
		return false
	
	skill.unlocked = true
	return true
