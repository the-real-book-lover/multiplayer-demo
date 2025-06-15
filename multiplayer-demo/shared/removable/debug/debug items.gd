extends Control

@onready var tml: TileMapLayer = $tml
@onready var items: Sprite2D = $tml/items
@onready var search_page: Node2D = $tml/search_page

@onready var highlight: ColorRect = $highlight

@onready var buttons: Control = $buttons
@onready var custom: LineEdit = $custom

@onready var page: Control = $page
@onready var page_count: Button = $"page/0"

@onready var searches: Control = $searches
@onready var search: LineEdit = $search
@onready var filters: Control = $filters

@onready var history: Node2D = $tml/history

@onready var comparisons: Control = $comparisons
@onready var hover_info: Control = $"hover info"


var next_comparison : Array = [0,1,2,3]
var current_comparisons : Array = [null,null,null,null]

# Vector2(x,y) : GM.ITEM.ID
var item_textures : Dictionary


var mode : int = MODE.DEFAULT
var comparing : bool = false
enum MODE {
	DEFAULT,
	SEARCH,
	HISTORY,
}



const SEARCH = preload("res://shared/removable/debug/search.tscn")
const DEBUG = "res://testing/debug/saving/debug/debug.tres"
var debug : Debug

var ITEM_NODE_SIZE : int = 32
var ITEM_SIZE : int = 16

var current_mTP : Vector2i = Vector2i(0,0)
var current_item : int = -1
var current_amount: int = 1

var current_page : int = 0
var max_pages : int = 0



# all queried atlases; [atlas, atlas, ..]
var search_items : Array


var item_sheet_data : Dictionary
var item_sheet_image : Image
var new_image : Image = Image.new()

var filter_settings : Array

# saved recently spawned items
var item_history : Array
# "search query" : [id,..]
var search_history : Array

var ITEMS_PER_PAGE : int

var history_page : int = 0
var HISTORY_OFFSET : Vector2i = Vector2i(-20, 0)


func init():
	# hides the clear button since it's not needed
	hover_info.get_child(0).visible = false
	
	# init texture dicts
	item_textures[MODE.DEFAULT] = {}
	item_textures[MODE.SEARCH] = {}
	item_textures[MODE.HISTORY] = {}
	
	# load resource
	#debug = ResourceLoader.load(DEBUG)
	
	item_history = debug.item_history.duplicate(true)
	search_history = debug.search_history.duplicate(true)
	current_comparisons = debug.current_comparisons.duplicate(true)
	current_amount = debug.current_amount
	filter_settings = debug.filter_settings
	
	for i in current_comparisons:
		
		if i:
			comparisons.get_child(current_comparisons.find(i)).init(i)
			next_comparison.erase(current_comparisons.find(i))
		
		
	for i in search_history:
		create_searches(i)
	
	
	print("what: ", GM.ITEM.FISH_RED)
	
	
	
	# checks all the items and gets their sprite atlas location; used to pull items from the debug menu spawner
	for item_id in GM.DB:
		var atlas : Vector2i = GM.DB[item_id]["sprite"]
		item_textures[MODE.DEFAULT][atlas] = item_id
	
	
	# current amount buttons
	for i in buttons.get_children():
		# sets the signals
		i.pressed.connect(set_amount.bind(i))
		# set current amount
		if i.button_pressed:
			set_amount(i)
	
	
	# current amount buttons
	for i in page.get_children():
		# sets the signals
		i.pressed.connect(change_page.bind(i))
	
	# current amount buttons
	for i in filters.get_children():
		# sets the signals
		i.pressed.connect(change_filter.bind(i))
		# sets save settings
		if i.button_pressed:
			change_filter(i)
	
	
	
	
	var node : int = 0
	var x : int = 0
	var y : int = 0
	var page : int = 0
	var width : int = 18
	var height : int = 11
	
	ITEMS_PER_PAGE = height * width
	
	for i in ITEMS_PER_PAGE:
		var search_node = Sprite2D.new()
		var history_node = Sprite2D.new()
		# sets the atlas to the item_sheet
		var search_atlas = AtlasTexture.new()
		var history_atlas = AtlasTexture.new()
		
		search_atlas.atlas = GM.DB_sprite
		history_atlas.atlas = GM.DB_sprite
		
		search_node.texture = search_atlas
		history_node.texture = history_atlas
		
		search_node.visible = false
		history_node.visible = false
		
		
		# add to tree
		search_page.add_child(search_node)
		history.add_child(history_node)
		
		
		history_node.position = Vector2(ITEM_SIZE, ITEM_SIZE) * Vector2(x,y)
		
		# updates position values
		x += 1
		if x == width:
			x = 0
			y += 1
			if y == height:
				y = 0
	
	node = 0
	x = 0
	y = 0
	page = 0
	
	
	for id in GM.DB:
		
		var current_node = search_page.get_child(node)
		# sets the position to where the item would lie on a sprite_sheet
		current_node.position = Vector2(ITEM_SIZE, ITEM_SIZE) * Vector2(x,y)
		item_textures[MODE.SEARCH][Vector2(x,y)] = id
		# sets region of each item
		current_node.texture.region = Rect2(ITEM_SIZE * GM.DB[id]["sprite"].x, ITEM_SIZE * GM.DB[id]["sprite"].y, ITEM_SIZE, ITEM_SIZE)
		
		# updates values
		node += 1
		x += 1
		if x == width:
			x = 0
			y += 1
			if y == height:
				y = 0
				page += 1
	
	
	node = 0
	x = 0
	y = 0
	page = 0
	
	
	var history_size : int = item_history.size()
	print("history_size : ", history_size)
	for i in history_size:
		# gets the ids from back to front
		var id : int = item_history[history_size - i - 1]
		var atlas : Vector2i = Vector2i(x,y) + HISTORY_OFFSET + Vector2i(0, 12)
		var current_node = history.get_child(node)
		# sets the position to where the item would lie on a sprite_sheet
		current_node.position = Vector2(ITEM_SIZE, ITEM_SIZE) * Vector2(x,y)
		current_node.visible = true
		
		item_textures[MODE.SEARCH][atlas] = id
		# sets region of each item
		current_node.texture.region = Rect2(ITEM_SIZE * GM.DB[id]["sprite"].x, ITEM_SIZE * GM.DB[id]["sprite"].y, ITEM_SIZE, ITEM_SIZE)
		
		
		item_textures[MODE.HISTORY][atlas] = id
		
		# updates values
		node += 1
		x += 1
		if x == width:
			x = 0
			y += 1
			if y == height:
				y = 0
				page += 1
	
	# gets total pages
	max_pages = GM.DB_sprite.get_size().y / 176
	
	
	print(max_pages)
	# sets the highlight box size to be the size of an item sprite
	highlight.size = Vector2(1,1) * ITEM_NODE_SIZE
	# resets the custom amount text
	custom.text = ""
	
	mode = MODE.DEFAULT
	
	page_count.text = "0" + " / " + str(max_pages - 1)
	
	# i have no idea why this doesn't work
	
	#for tml_x in width:
		#for tml_y in height:
			#var atlas : Vector2i = Vector2i(tml_x, tml_y)
			#if item_textures[MODE.DEFAULT].has(atlas):
				#continue
			#else:
				#var error_node : ColorRect = ColorRect.new()
				#error_node.position = atlas * ITEM_NODE_SIZE
				#error_parent.add_child(error_node)
	

#@onready var error_parent: Control = $"tml/items/error parent"



func _ready() -> void:
	init()
	
	SM.debug_primary.connect(debug_primary)
	SM.debug_secondary.connect(debug_secondary)
	SM.debug_search.connect(debug_search)
	SM.debug_remove_search.connect(remove_search)
	SM.debug_open_comparison.connect(debug_open_comparison)

func debug_search(search_text : String):
	search.text = search_text
	_on_search_text_changed(search_text)

func debug_open_comparison(index : int):
	next_comparison.push_front(index)
	
	current_comparisons[index] = null
	
	debug.current_comparisons = current_comparisons
	save_debug()


func _process(_delta: float) -> void:
	# gets current mouse position
	var mouse = get_local_mouse_position()
	# gets the tile its hovering on the tilemaplayer node
	var mTP = tml.local_to_map(mouse)
	
	# if new tile then update
	if mTP != current_mTP:
		# set new tile
		current_mTP = mTP
		
		var current_atlas : Vector2i = mTP + (Vector2i(0, 10) * current_page + Vector2i(0, 1) * sign(current_page))
		var history_atlas : Vector2i = current_atlas + HISTORY_OFFSET
		#print(current_atlas)
		#print(history_atlas)
		
		# shows for visual feedback what tile is hovered
		highlight.position = current_mTP * ITEM_NODE_SIZE
		
		# if the mouse is hovering an item
		if item_textures[mode].has(current_atlas):
			# get the tile position (chooses hovered) + items per page * the page (offsets the selected item to the current based on region ( Rect2 ) )
			current_item = item_textures[mode][current_atlas]
			highlight.visible = true
			# if hovering an item; show it's info
			hover_info.init(current_item)
			
		elif item_textures[MODE.HISTORY].has(history_atlas):
			# get the tile position (chooses hovered) + items per page * the page (offsets the selected item to the current based on region ( Rect2 ) )
			current_item = item_textures[MODE.HISTORY][history_atlas]
			print("why: " , current_item)
			highlight.visible = true
		else:
			# sets as an OOB id
			current_item = -1
			highlight.visible = false
			# hide when not an item
			hover_info._on_clear_pressed()


# takes a click input from GM > STATE.DEBUG

func debug_primary():
	print(can_process())
	if can_process() == false:
		return
	# if an item is hovered
	if current_item > -1:
		if comparing and next_comparison:
			var index : int = next_comparison.pop_front()
			comparisons.get_child(index).init(current_item)
			current_comparisons[index] = current_item
			
			debug.current_comparisons = current_comparisons
			save_debug()
			
			# /rw/ add the text effect anim z here
			if next_comparison.is_empty():
				next_comparison = [0,1,2,3]
			
		else:
			# spawn to player; inventory
			give_item(current_item, current_amount)
			update_item_history()

func debug_secondary():
	if can_process() == false:
		return
	print("current_item : ", current_item)
	# if an item is hovered
	if current_item > -1:
		if current_mTP.y > 11:
			print("remove: ", current_item)
			item_history.erase(current_item)
			history_sprites()
			
			debug.item_history = item_history
			save_debug()
	


func update_item_history():
	# adds 
	if !item_history.has(current_item):
		item_history.append(current_item)
	# 
	else:
		item_history.erase(current_item)
		item_history.append(current_item)
	
	history_sprites()
	
	debug.item_history = item_history
	save_debug()


func history_sprites():
	item_textures[MODE.HISTORY].clear()
	
	var history_size : int = item_history.size()
	
	var node : int = 0
	var x : int = 0
	var y : int = 0
	var page : int = 0
	var width : int = 18
	var height : int = 11
	
	
	for i in history_size + 1:
		var current_node = history.get_child(i)
		current_node.visible = false
		
	
	for i in history_size:
		# gets the ids from back to front
		var id : int = item_history[history_size - i - 1]
		var atlas : Vector2i = Vector2i(x,y) + HISTORY_OFFSET + Vector2i(0, 12)
		var current_node = history.get_child(node)
		current_node.visible = true
		# sets region of each item
		current_node.texture.region = Rect2(ITEM_SIZE * GM.DB[id]["sprite"].x, ITEM_SIZE * GM.DB[id]["sprite"].y, ITEM_SIZE, ITEM_SIZE)
		
		item_textures[MODE.HISTORY][atlas] = id
		
		# updates values
		node += 1
		x += 1
		if x == width:
			x = 0
			y += 1
			if y == height:
				y = 0
				page += 1
	
	print(item_textures[MODE.HISTORY])




# item spawning
func give_item(item : int, amount : int):
	print("giving: ", item, " maount : "  , amount)
	# makes sure ingame
	if GM.game_state == GM.GAME_STATE.INGAME:
		# send to inventory
		SM.console_give_item.emit(item, amount)
	
	

# sets the amount of items to spawn each click
func set_amount(button : Button):
	# sets custom amount instead of "x"
	if button.name == "x":
		current_amount = custom.text.to_int()
	elif button.name == "stack" and current_item > -1:
		current_amount = GM.DB[current_item]["stack size"]
	else:
		current_amount = button.text.to_int()
	
	debug.current_amount = current_amount
	save_debug()
	

# changes the page of items
func change_page(button : Button):
	
	if button.name == "0":
		current_page = 0
	else:
		current_page = wrap( current_page + button.name.to_int(), 0, max_pages)
		page_count.text = str( current_page )
	
	page_count.text = str(current_page) + " / " + str(max_pages - 1)
	
	items.texture.region = Rect2( 0, 176 * current_page, 288, 176)


# changes the search filter
func change_filter(button : Button):
	print(button.name)
	# set to pressed button
	if button.name == "all":
			filter_settings = ["id","name","description","type","class"]
	else:
		filter_settings = [button.name]
	
	debug.filter_settings = filter_settings
	save_debug()
	print(filter_settings)

func _on_custom_text_changed(new_text: String) -> void:
	current_amount = new_text.substr(0, 4).to_int()


var temp_filter_settings : Array
var search_id : int 
var search_text : String

func _on_search_text_changed(new_text: String) -> void:
	
	# checks whether its been reset from clear button
	if new_text.is_empty():
		items.visible = true
		search_page.visible = false
		mode = MODE.DEFAULT
		return
	else:
		items.visible = false
		search_page.visible = true
		mode = MODE.SEARCH
	
	# current search values
	temp_filter_settings = filter_settings.duplicate(true)
	search_items.clear()
	item_textures[MODE.SEARCH].clear()
	
	# check if id searchable
	search_id = new_text.to_int()
	search_text = new_text
	
	if !new_text.to_int():
		temp_filter_settings.erase("id")
	
	
	print(search_id)
	print(temp_filter_settings)
	
	for id in GM.DB:
		check_item(id)
	
	print(search_items)
	
	if search_items:
		update_sprites()
		mode = MODE.SEARCH
		debug.item_history = item_history
		save_debug()

func check_item(id : int):
	for f in temp_filter_settings:
		match f:
			"id":
				print("what??")
				if id == search_id:
					search_items.append(id)
					return
			"name":
				if GM.DB[id][f].contains(search_text):
					search_items.append(id)
					return
			"description":
				if GM.DB[id][f].contains(search_text):
					search_items.append(id)
					return
			"type":
				if GM.DB[id].has(f) and GM.DB[id][f].contains(search_text):
					search_items.append(id)
					return
					
			"class":
				pass
				#if GM.DB[id][f].contains(new_text):
					#search_items.append(id)
					#return
	

func update_sprites():
	
	
	# values
	var item_index : int = 0
	var item_row : int = 0
	
	var search_node_count : int = search_page.get_children().size()
	var search_count : int = search_items.size()
	
	print(search_node_count)
	print(search_count)
	
	for i in search_node_count:
		
		if search_count > i:
			# item id
			var id : int = search_items[i]
			# position it appears on the tile map
			var atlas : Vector2i = Vector2i(item_index, item_row)
			
			search_page.get_child(i).texture.region = Rect2(ITEM_SIZE * GM.DB[id]["sprite"].x, ITEM_SIZE * GM.DB[id]["sprite"].y, ITEM_SIZE, ITEM_SIZE)
			search_page.get_child(i).visible = true
			
			item_textures[MODE.SEARCH][atlas] = id
		
			# current item number being added;
			item_index += 1
			# doesn't go off inf. ->
			if item_index == 18:
				item_index = 0
				item_row += 1
		else:
			search_page.get_child(i).visible = false
	
	print(item_textures[mode])
	
	

func _on_search_text_submitted(new_text: String) -> void:
	if !search_history.has(new_text):
		var old_search = SEARCH.instantiate()
	
		old_search.position = Vector2(0, 36) * search_history.size()
		searches.add_child(old_search)
		
		old_search.init(new_text)
		
		search_history.append(new_text)
		debug.search_history = search_history
		save_debug()

func create_searches(search_text : String):
	var old_search = SEARCH.instantiate()
	
	old_search.position = Vector2(0, 36) * search_history.find(search_text)
	searches.add_child(old_search)
	
	old_search.init(search_text)



func _on_clear_history_pressed() -> void:
	# hides history results
	for i in item_history.size():
		history.get_child(i).visible = false
	# clears arrays
	item_history.clear()
	debug.item_history.clear()
	# save
	save_debug()


func _on_clear_searches_pressed() -> void:
	# hides history results
	for i in searches.get_children():
		i.queue_free()
	# clears arrays
	search_history.clear()
	debug.search_history.clear()
	# save
	save_debug()

func remove_search(index : int):
	search_history.remove_at(index)
	for i in searches.get_children():
		if i.get_index() >= index:
			i.position -= Vector2(0, 36)
	
	debug.search_history = search_history
	save_debug()


func _on_compare_toggled(toggled_on: bool) -> void:
	comparing = toggled_on


func _on_clear_comparisons_pressed() -> void:
	next_comparison = [0,1,2,3]
	current_comparisons = [null,null,null,null]
	
	for i in comparisons.get_children():
		i._on_clear_pressed()
	
	debug.current_comparisons = current_comparisons
	save_debug()
