class_name Stats
extends Control

var PROCESS : Dictionary = {
	"health" : -0.0,
}

#@export var example : Dictionary = {
	#"health" : {
		## init
		#"color" : Color.RED,
		#"numbers" : true,
		## values
		#"current" : 100,
		#"max" : 100, # const / current?
		#"min" : 0, # const / current?
		#"updating" : true,
		## states
		#"states" : {
			#"max" : false,
			#"min" : false,
		#},
		## state func
		#"state func" : {
			#"max true" : ["full_health", Sprite.FULL_HEALTH],
			#"max false" : ["missing_health", Sprite.MISSING_HEALTH, Anim.LIMPING],
			#"min true" : ["death", Sprite.MISSING_HEALTH, Anim.LIMPING],
			#"min false" : ["revive", Anim.LIMPING],
		#},
	#},
	#"hunger" : {
		## init
		#"color" : Color.ORANGE,
		#"numbers" : true,
		## values
		#"current" : 100,
		## points
		#"max" : 100, # const / current?
		#"min" : 0, # const / current?
		#"updating" : true,
		## states
		#"states" : {
			#"max" : false,
			#"min" : false,
		#},
		## state func
		#"state func" : {
			##"state bool" : ["function_name", varargs,...],
			#"max true" : ["full_hunger", Sprite.FULL_HEALTH],
			#"max false" : ["missing_hunger", Sprite.MISSING_HEALTH, Anim.LIMPING],
			#"min true" : ["starving", Sprite.MISSING_HEALTH, Anim.LIMPING],
			#"min false" : ["hungry", Anim.LIMPING],
		#},
		## /rw
		#"dependant" : {
			#"health" : -1,
		#},
	#},
#}


@export var stats : Dictionary = {
	"health" : {
		# init
		"color" : Color.RED,
		"numbers" : true,
		# values
		"current" : 100,
		"max" : 100, # const / current?
		"min" : 0, # const / current?
		"updating" : true,
		# states
		"states" : {
			"max" : true,
			"min" : false,
		},
		# state func
		"func" : {
			"above max" : "healthy",
			"below max" : "damaged",
			"above min" : "damaged",
			"below min" : "death",
		},
	},
}

# var default_stats_XXX : Dict ={.

# id per entity with saveable stats
# db[id] = default_stats["node"].duplicate(true)
#Stats.change(target, "health", dmg)


#region init / debug

# /rw do I need this?
static func add(new_node : Node) -> Stats:
	return UM.inst(Stats, new_node)

func _ready() -> void:
	create_displays()

func create_displays() -> void:
	# create the bars
	var count : int = 0
	var BAR_OFFSET : Vector2 = Vector2(-100, -100)
	var NUMBER_OFFSET : Vector2 = Vector2(100, 0)
	var SPACING : Vector2 = Vector2(0, 50)
	for i : String in stats:
		
		if stats[i]["color"]:
			# create the colored portion of the bar
			var bar : ColorRect = UM.inst(ColorRect, self)
			bar.name = i
			bar.color = stats[i].color
			bar.size = Vector2(2, 10)
			bar.scale = Vector2(100, 1)
			bar.position = SPACING * count + BAR_OFFSET
			bar.z_index = 1
			# create the black background of the bar
			var bg : ColorRect = UM.inst(ColorRect, self)
			bg.name = i + " bg"
			bg.color = Color.BLACK
			bg.size = Vector2(2, 10)
			bg.scale = Vector2(100, 1)
			bg.position = SPACING * count + BAR_OFFSET
			# save the bar for later use on set
			stats[i].bar = bar
		if stats[i]["numbers"]:
			# create numbers
			var label : Label = UM.inst(Label, self)
			label.name = i + " label"
			label.modulate = Color.WHITE
			label.text = str(stats[i].current)
			label.position = SPACING * count + BAR_OFFSET + NUMBER_OFFSET
			label.z_index = 2
			stats[i].label = label
		
		count += 1

#endregion

#region process

func _process(_delta: float) -> void:
	better_name()

# /n
func better_name() -> void:
	#reduce stat:
	for STAT : String in PROCESS:
		var amount : float = PROCESS[STAT]
		change_stat(STAT, amount)

#endregion

#region updating


func change_stat(stat : String, amount : float) -> void:
	var updating : bool = stats[stat].updating
	if updating:
		# change amount
		stats[stat].current += amount
		# checks if there is an override to stop updating
		check_stat(stat)

#/RW use == aswellt?

# add funcs to check for threshols and how to respond if hit
func check_stat(stat : String) -> void:
	# check every state
	for state : String in stats[stat]["states"]:
		state_machine(state, stat)
	# update new values
	update_values(stat)

# /rw when to break for loop for efficiency?
func state_machine(state : String, stat : String) -> void:
		# values
		var current_stat_value : int = stats[stat].current
		var state_stat_value : int = stats[stat][state]
		
		# how does the current value compare; used for function determining
		var change : String
		if current_stat_value >= state_stat_value:
			change = "above " + state
		#elif current_stat_value == state_stat_value:
			#change = "at " + state
		elif current_stat_value < state_stat_value:
			change = "below " + state
		
		# call the function
		var callable_name : String = stats[stat]["func"][change]
		var callable : Callable  = Callable(self, callable_name)
		callable.call(stat)


func update_values(stat : String) -> void:
	if stats[stat]["color"]:
		update_stat_bar(stat)
	if stats[stat]["numbers"]:
		update_numbers(stat)

func update_stat_bar(stat: String) -> void:
	# takes the current and max values of the stat
	var current_stat : int = stats[stat].current
	var max_stat : int = stats[stat].max
	# finds the percentage
	var percentage : float = clamp(current_stat, 0, max_stat)
	# sets the length of the colored bar to represent the current amount
	stats[stat].bar.scale = Vector2(percentage, 1)

func update_numbers(stat: String) -> void:
	# takes the current and max values of the stat
	var current_stat : int = stats[stat].current
	stats[stat].label.text = str(current_stat)


#endregion

#region funcs
#region health

func healthy(_stat : String) -> void:
	get_parent().activate()

func damaged(_stat : String) -> void:
	pass

func death(stat : String) -> void:
	finished(stat)
	# die
	get_parent().death()

func revive() -> void:
	pass

#endregion 
#endregion

#region saved funcs
# = 0.25
func tired(stat : String) -> void:
	var stat_time : float = stats[stat]["timer"]
	var timer : SceneTreeTimer = get_tree().create_timer(stat_time)
	timer.timeout.connect(replenish.bind(stat))
	PROCESS[stat] = stats[stat]["tired"]
func replenish(stat : String) -> void:
	PROCESS[stat] = stats[stat]["okay"]
func finished(stat : String) -> void:
	# stops the process from continuing to update this stat
	stats[stat].updating = false
	# sets the stat to the minimum
	stats[stat].current = stats[stat].min
func process_stat(stat : String, amount : int) -> void:
	# /rw to a timer; processes the amount each frame
	PROCESS[stat] = amount
#endregion 

# get the current value of the stat
func get_stat(stat : String) -> float:
	var stat_value : float = stats[stat].current
	return stat_value
