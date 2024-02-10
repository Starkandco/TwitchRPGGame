extends Window

var count = 0

func _ready():
	_on_option_button_item_selected($VBoxContainer/OptionButton.selected)

func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		visible = !visible

func _on_button_pressed():
	get_tree().get_first_node_in_group("Main").join("starkandco" + str(count))
	count += 1

func _on_option_button_item_selected(index):
	match int(index):
		0:
			$"../Timer".stop()
			$"../Timer".wait_time = 2
			if get_tree().get_first_node_in_group("Main").players.size() > 0:
				$"../Timer".start()
		1:
			$"../Timer".stop()
			$"../Timer".wait_time = 5
			if get_tree().get_first_node_in_group("Main").players.size() > 0:
				$"../Timer".start()
		2:
			$"../Timer".stop()
			$"../Timer".wait_time = 10
			if get_tree().get_first_node_in_group("Main").players.size() > 0:
				$"../Timer".start()
		3:
			$"../Timer".stop()
			$"../Timer".wait_time = 15
			if get_tree().get_first_node_in_group("Main").players.size() > 0:
				$"../Timer".start()
		4:
			$"../Timer".stop()
			$"../Timer".wait_time = 30
			if get_tree().get_first_node_in_group("Main").players.size() > 0:
				$"../Timer".start()


func _on_option_button_2_item_selected(index):
	match int(index):
		0:
			get_tree().get_first_node_in_group("Main").spawn = 1
			get_tree().get_first_node_in_group("Main").spawn_counter = 1
		1:
			get_tree().get_first_node_in_group("Main").spawn = 2
			get_tree().get_first_node_in_group("Main").spawn_counter = 2
		2:
			get_tree().get_first_node_in_group("Main").spawn = 4
			get_tree().get_first_node_in_group("Main").spawn_counter = 4
		3:
			get_tree().get_first_node_in_group("Main").spawn = 6
			get_tree().get_first_node_in_group("Main").spawn_counter = 6
		4:
			get_tree().get_first_node_in_group("Main").spawn = 9
			get_tree().get_first_node_in_group("Main").spawn_counter = 9

func _on_close_requested():
	visible = false
