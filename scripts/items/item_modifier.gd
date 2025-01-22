extends Node
class_name Item_Modifier

var modifier_type
var modifier_number
var modifier_percent

func _init(modifier_t, modifier_num, modifier_perc):
	modifier_type = modifier_t
	modifier_number = modifier_num
	modifier_percent = modifier_perc
	
