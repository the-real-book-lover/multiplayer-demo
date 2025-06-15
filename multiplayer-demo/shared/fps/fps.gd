extends Button

@onready var min_fps: Button = $min
@onready var max_fps: Button = $max

@onready var recent_avg: Button = $"recent avg"
@onready var overall_avg: Button = $"overall avg"

var fps : int
var limit : int = 60
#var graph_limit : int = 60

var calc_min : int = 9999
var calc_max : int = 0
var calc_recent_avg : int 
var calc_overall_avg : int 

var recent : Array
var overall : Array

var graph_recent_array : Array
var graph_overall_array : Array

var mode : int = MODE.HIDE
var last_mode : int = MODE.RECENT
enum MODE {
	HIDE,
	RECENT,
	OVERALL,
}

const COMICBD = preload("res://shared/fps/COMICBD.TTF")
var scroll_recent : bool = false
var scroll_overall : bool = false

func init():
	recent_avg.button_pressed = true

func _ready() -> void:
	init()

func _process(_delta: float) -> void:
	fps = int(Engine.get_frames_per_second())
	self.text = "FPS: " + str(fps)
	min_fps.text = "Min: " + str(calc_min)
	max_fps.text = "Max: " + str(calc_max)
	
	if calc_min > fps:
		calc_min = int(fps)
		
	if calc_max < fps:
		calc_max = int(fps)
	
	
	if Input.is_action_just_pressed("fps"):
		visible = !visible

func _draw() -> void:
	
	var start : Vector2 = Vector2(-600, 800)
	if mode != MODE.HIDE:
		match mode:
			MODE.RECENT:
				@warning_ignore("integer_division")
				var graph_size : int = graph_recent_array.size() / 2
				for i in graph_size:
					var color : Color = Color.GREEN
					# hides start point
					if i == 0:
						color = Color(0,0,0,0)
					elif graph_recent_array[graph_size - 1] > 1700:
						color = Color.GREEN
					elif graph_recent_array[graph_size - 1] > 1300:
						color = Color.YELLOW
					elif graph_recent_array[graph_size - 1] > 800:
						color = Color.ORANGE
					else:
						color = Color.CRIMSON
					
					# space between points
					var gap : int = 20 * i * -1
					# x/y
					var x : int = gap * -1
					var y : int = graph_recent_array[i] * -1
					
					var offset_x : int = -584
					var offset_y : int = graph_recent_array[graph_size - 1] + 100
					#var offset : Vector2 = Vector2(-600, -700)
					# s/e
					var end : Vector2 = Vector2(x,y) + Vector2(offset_x, offset_y)
					draw_line(start, end, color, 4.0, true)
					# place current end point as next start point
					start = end
				# graph text
				var recent_text : Array = ["1", "M"]
				for i in recent_text.size():
					var pos : Vector2 = Vector2(0, 170) + Vector2(16,0) * i
					draw_char(COMICBD, pos, recent_text[i], 16, Color.DIM_GRAY)
			
			MODE.OVERALL:
				@warning_ignore("integer_division")
				var graph_size : int = graph_overall_array.size() / 2
				for i in graph_size:
					var color : Color = Color.GREEN
					# hides start point
					if i == 0:
						color = Color(0,0,0,0)
					# space between points
					var gap : int = 20 * i * -1
					# x/y
					var x : int = gap * -1
					var y : int = graph_overall_array[i]
					
					var offset_x : int = -584
					var offset_y : int = graph_overall_array[graph_size - 1] * -1 + 100
					# s/e 
					var end : Vector2 = Vector2(x,y) + Vector2(offset_x, offset_y)
					draw_line(start, end, color, 4.0, true)
					# place current end point as next start point
					start = end
				# graph text
				var overall_text : Array = ["1", "H", "r"]
				for i in overall_text.size():
					var pos : Vector2 = Vector2(0, 170) + Vector2(16,0) * i
					draw_char(COMICBD, pos, overall_text[i], 16, Color.DIM_GRAY)
		# draw graph bounds
		var graph_top : Vector2 = Vector2(-584, 0)
		var graph_bottom : Vector2 = Vector2(-584, 150)
		var graph_end : Vector2 = Vector2(start.x, 150)
		draw_line(graph_top, graph_bottom, Color.DIM_GRAY, 2.0, true)
		draw_line(graph_bottom, graph_end, Color.DIM_GRAY, 2.0, true)
	else:
		pass
	
	

func _on_recent_timeout() -> void:
	recent.append(fps)
	
	var total : int = 0
	var SIZE : int = recent.size()
	
	for i in recent:
		total += i
	
	var old = calc_recent_avg
	@warning_ignore("integer_division")
	calc_recent_avg = total / SIZE
	recent_avg.text = "Avg: " + str(calc_recent_avg)
	
	
	graph_recent_array.append(calc_recent_avg)
	
	
	if SIZE > limit:
		scroll_recent = true
		recent.clear()
	
	
	if scroll_recent:
		graph_recent_array.pop_front()
	
	if calc_overall_avg - old > 100:
		# /a/ thing?
		pass
	
	queue_redraw()


func _on_overall_timeout() -> void:
	overall.append(calc_recent_avg)
	

	var total : int = 0
	var SIZE : int = overall.size()
	
	for i in overall:
		total += i
	
	var old = calc_overall_avg
	@warning_ignore("integer_division")
	calc_overall_avg = total / SIZE
	overall_avg.text = "All: " + str(calc_overall_avg)
	
	graph_overall_array.append(calc_overall_avg)
	
	if SIZE > limit:
		scroll_overall = true
		overall.clear()
	
	if scroll_overall:
		graph_overall_array.pop_front()
	
	if calc_overall_avg - old > 100:
		# /a/ thing?
		pass
	


func _on_min_pressed() -> void:
	calc_min = 9999


func _on_max_pressed() -> void:
	calc_max = 0




func _on_recent_avg_pressed() -> void:
	mode = MODE.RECENT
	last_mode = MODE.RECENT
	queue_redraw()


func _on_overall_avg_pressed() -> void:
	mode = MODE.OVERALL
	last_mode = MODE.OVERALL
	queue_redraw()


func _on_toggled(_toggled_on: bool) -> void:
	# toggle graph visibility
	if mode == MODE.HIDE:
		mode = last_mode
	else:
		mode = MODE.HIDE
	# show graph
	queue_redraw()
