extends Node

func _ready():
	var config = ConfigFile.new()
	var path = OS.get_executable_path().get_base_dir()
	# Load data from a file.
	var err = config.load(path + "/setup.cfg")

	# If the file didn't load, create one.
	if err != OK or config.get_value("setup", "clientID") == "Create an app on twitch and assign the client ID here":
		config.set_value("setup", "clientID", "Create an app on twitch and assign the client ID here")
		config.set_value("setup", "channel", "Yourchannelhere")
		config.set_value("setup", "botname", "Blah")
		config.set_value("setup", "refreshspeed", "4")
		config.save(path + "/setup.cfg")
		$"../Popup".visible = true
		get_tree().paused = true
	else:
		var twitch_node = get_tree().get_first_node_in_group("Twitch")
		twitch_node.client_id = config.get_value("setup", "clientID")
		twitch_node.channel = config.get_value("setup", "channel")
		twitch_node.username = config.get_value("setup", "botname")
		$"../Window".get_node("VBoxContainer/OptionButton").selected = int(config.get_value("setup", "refreshspeed"))
		$"../Window"._on_option_button_item_selected(config.get_value("setup", "refreshspeed"))
		twitch_node.my_ready()
