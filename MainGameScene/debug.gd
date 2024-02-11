extends Window

@onready var main = get_tree().get_first_node_in_group("Main")
var count = 0

func _ready():
	var config = ConfigFile.new()
	var path = OS.get_executable_path().get_base_dir()
	var err = config.load(path + "/setup.cfg")
	if err == OK:
		_on_option_button_item_selected(int(config.get_value("setup", "refreshspeed")))
		$MarginContainer/VBoxContainer/OptionButton.selected = int(config.get_value("setup", "refreshspeed"))
		_on_option_button_2_item_selected(int(config.get_value("setup", "bots_delay")))
		$MarginContainer/VBoxContainer/OptionButton2.selected = int(config.get_value("setup", "bots_delay"))

func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		visible = !visible

func _on_button_pressed():
	main.join("starkandco" + str(count))
	count += 1

func _on_option_button_item_selected(index):
	match int(index):
		0:
			$"../Timer".stop()
			$"../Timer".wait_time = 2
			if main.players.size() > 0:
				$"../Timer".start()
		1:
			$"../Timer".stop()
			$"../Timer".wait_time = 5
			if main.players.size() > 0:
				$"../Timer".start()
		2:
			$"../Timer".stop()
			$"../Timer".wait_time = 10
			if main.players.size() > 0:
				$"../Timer".start()
		3:
			$"../Timer".stop()
			$"../Timer".wait_time = 15
			if main.players.size() > 0:
				$"../Timer".start()
		4:
			$"../Timer".stop()
			$"../Timer".wait_time = 30
			if main.players.size() > 0:
				$"../Timer".start()


func _on_option_button_2_item_selected(index):
	match int(index):
		0:
			main.spawn = 1
			main.spawn_counter = 1
		1:
			main.spawn = 2
			main.spawn_counter = 2
		2:
			main.spawn = 4
			main.spawn_counter = 4
		3:
			main.spawn = 6
			main.spawn_counter = 6
		4:
			main.spawn = 9
			main.spawn_counter = 9

func _on_close_requested():
	visible = false


func _on_player_health_text_submitted(new_text):
	var players = get_tree().get_nodes_in_group("Player")
	var new_value = new_text.to_int()
	main.chatter_health = new_value 
	for player in players:
		if player is Enemy: continue
		player.max_health = new_value
		player.health = new_value
		player.get_node("HealthBar").max_value = new_value
		player.get_node("HealthBar").value = new_value

func _on_player_damage_text_submitted(new_text):
	var players = get_tree().get_nodes_in_group("Player")
	var new_value = new_text.to_int()
	main.chatter_damage = new_value 
	for player in players:
		if player is Enemy: continue
		player.damage = new_value
		player.get_node("StrengthBar").value = new_value

func _on_bot_health_text_submitted(new_text):
	var players = get_tree().get_nodes_in_group("Player")
	var new_value = new_text.to_int()
	main.bot_health = new_value 
	for player in players:
		if !player is Enemy: continue
		player.max_health = new_value
		player.health = new_value
		player.get_node("HealthBar").max_value = new_value
		player.get_node("HealthBar").value = new_value

func _on_bot_damage_text_submitted(new_text):
	var players = get_tree().get_nodes_in_group("Player")
	var new_value = new_text.to_int()
	main.bot_damage = new_value 
	for player in players:
		if !player is Enemy: continue
		player.damage = new_value
		player.get_node("StrengthBar").value = new_value
