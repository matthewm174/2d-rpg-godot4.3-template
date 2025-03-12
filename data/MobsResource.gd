extends Resource
class_name MobResource

var master_mobs_book: Dictionary



func init_state_machine():
	var enemy_state_machine = StateMachine.new()
	enemy_state_machine.name = "EnemyStateMachine"
	var ecasref = EnemyCastState.new()
	ecasref.name = "EnemyCastState"
	var eapssref = EnemyApproachState.new()
	eapssref.name = "EnemyApproachState"
	var easref = EnemyAttackState.new()
	easref.name = "EnemyAttackState"
	var eavsref = EnemyAvoidState.new()
	eavsref.name = "EnemyAvoidState"
	var ebsref = EnemyBlockState.new()
	ebsref.name = "EnemyBlockState"
	var ecsref = EnemyChaseState.new()
	ecsref.name = "EnemyChaseState"
	var edsref = EnemyDeathState.new()
	edsref.name = "EnemyDeathState"
	var eesref = EnemyEngagedState.new()
	eesref.name = "EnemyEngagedState"
	var efsref = EnemyFleeState.new()
	efsref.name = "EnemyFleeState"
	var eisref = EnemyIdleState.new()
	eisref.name = "EnemyIdleState"
	var emsref = EnemyMeanderState.new()
	emsref.name = "EnemyMeanderState"
	var eprsref = EnemyParryState.new()
	eprsref.name = "EnemyParryState"
	var eparef = EnemyPatrolState.new()
	eparef.name = "EnemyPatrolState"
	var essref = EnemySearchState.new()
	essref.name = "EnemySearchState"
	var estsref = EnemyStaggerState.new()
	estsref.name = "EnemyStaggerState"
	
	enemy_state_machine.add_child(eapssref)
	enemy_state_machine.add_child(easref)
	enemy_state_machine.add_child(eavsref)
	enemy_state_machine.add_child(ebsref)
	enemy_state_machine.add_child(ecsref)
	enemy_state_machine.add_child(edsref)
	enemy_state_machine.add_child(eesref)
	enemy_state_machine.add_child(efsref)
	enemy_state_machine.add_child(eisref)
	enemy_state_machine.add_child(emsref)
	enemy_state_machine.add_child(eprsref)
	enemy_state_machine.add_child(eparef)
	enemy_state_machine.add_child(essref)
	enemy_state_machine.add_child(estsref)
	enemy_state_machine.add_child(ecasref)
	enemy_state_machine.initial_state = eisref # idle
	
	return enemy_state_machine


func _init():
	init_state_machine()
	# declare all resources and save to file, i guess this is how godot wants data
	var skeleton_animations = AnimationUtils.load_character_animation_sheet("res://sprites/enemies/skeleton/skeleton_sprites.png", Vector2(64, 64))
	var skeleton: Enemy = Enemy.new(init_state_machine(),
	20, 100, [Vector2(-200,-100), 
	Vector2(-200,-200)], skeleton_animations, 
	[], Globals.item_resources.master_weapon_book["short_sword"])
	master_mobs_book["skeleton"] = skeleton


	var dark_skeleton_animations = AnimationUtils.load_character_animation_sheet("res://sprites/enemies/skeleton/dark_skeleton_sprites.png", Vector2(64, 64))
	var dark_skeleton: Enemy = Enemy.new(init_state_machine(), 
	20, 100, [], dark_skeleton_animations, [Globals.item_resources.master_spell_book['fire_ball']], 
	Globals.item_resources.master_weapon_book["short_sword"])
	
	master_mobs_book["dark_skeleton"] = dark_skeleton
