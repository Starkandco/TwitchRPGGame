extends Control

# Your client id. You can share this publicly. Default is my own client_id.
# Please do not ship your project with my client_id, but feel free to test with it.
# Visit https://dev.twitch.tv/console/apps/create to create a new application.
# You can then find your client id at the bottom of the application console.
# DO NOT SHARE THE CLIENT SECRET. If you do, regenerate it.

@onready var players = get_tree().get_first_node_in_group("Main").players
@onready var queued_actions = get_tree().get_first_node_in_group("Main").queued_actions
enum {LEAVE, MOVE, JOIN, LEVELUP}

@export var client_id : String = ""

# The name of the channel we want to connect to.
@export var channel : String
# The username of the bot account.
@export var username : String

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection

var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()

var iconloader : TwitchIconDownloader

func my_ready() -> void:
	if client_id == "": return
	# We will login using the Implicit Grant Flow, which only requires a client_id.
	# Alternatively, you can use the Authorization Code Grant Flow or the Client Credentials Grant Flow.
	# Note that the Client Credentials Grant Flow will only return an AppAccessToken, which can not be used
	# for the majority of the Twitch API or to join a chat room.
	var auth : ImplicitGrantFlow = ImplicitGrantFlow.new()
	# For the auth to work, we need to poll it regularly.
	get_tree().process_frame.connect(auth.poll) # You can also use a timer if you don't want to poll on every frame.

	# Next, we actually get our token to authenticate. We want to be able to read and write messages,
	# so we request the required scopes. See https://dev.twitch.tv/docs/authentication/scopes/#twitch-access-token-scopes
	var token : UserAccessToken = await(auth.login(client_id, ["chat:read", "chat:edit"]))
	if (token == null):
		# Authentication failed. Abort.
		return

	# Store the token in the ID connection, create all other connections.
	id = TwitchIDConnection.new(token)
	irc = TwitchIRCConnection.new(id)
	api = TwitchAPIConnection.new(id)
	
	# For everything to work, the id connection has to be polled regularly.
	get_tree().process_frame.connect(id.poll)
	

	# Connect to the Twitch chat.
	if(!await(irc.connect_to_irc(username))):
		# Authentication failed. Abort.
		return
	# Request the capabilities. By default only twitch.tv/commands and twitch.tv/tags are used.
	# Refer to https://dev.twitch.tv/docs/irc/capabilities/ for all available capapbilities.
	irc.request_capabilities()
	# Join the channel specified in the exported 'channel' variable.
	irc.join_channel(channel)

	cmd_handler.add_command("join", player_join)
	
	cmd_handler.add_command("leave", player_leave)

	cmd_handler.add_command("move", player_move, 1)
		
	cmd_handler.add_command("levelup", player_level_up, 1)
		
	# We also have to forward the messages to the command handler to handle them.
	irc.chat_message.connect(cmd_handler.handle_command)

func player_join(cmd_info: CommandInfo) -> void:
	if !players.has(cmd_info.sender_data.user):
		if !queued_actions.has(JOIN):
			queued_actions[JOIN] = [cmd_info.sender_data.user]
		else:
			queued_actions[JOIN].append(cmd_info.sender_data.user)

func player_leave(cmd_info: CommandInfo) -> void:
	
	if players.has(cmd_info.sender_data.user):
		if !queued_actions.has(LEAVE):
			queued_actions[LEAVE] = [cmd_info.sender_data.user]
		else:
			queued_actions[LEAVE].append(cmd_info.sender_data.user)

func player_move(cmd_info: CommandInfo, second_arg) -> void:
	if players.has(cmd_info.sender_data.user):
		var arg = str(second_arg[0]).to_upper()
		if (arg in ["LEFT", "RIGHT", "UP", "DOWN"]):
			players[cmd_info.sender_data.user][0].prepare_move(arg)
			if !queued_actions.has(MOVE):
				queued_actions[MOVE] = {cmd_info.sender_data.user: arg}
			else:
				queued_actions[MOVE][cmd_info.sender_data.user] = arg

func player_level_up(cmd_info: CommandInfo, second_arg) -> void:
	if players.has(cmd_info.sender_data.user):
		var arg = str(second_arg[0]).to_upper()
		if (arg in ["HEALTH", "DAMAGE"]):
			players[cmd_info.sender_data.user][0].prepare_move(arg)
			if !queued_actions.has(LEVELUP):
				queued_actions[LEVELUP] = {cmd_info.sender_data.user: arg}
			else:
				queued_actions[LEVELUP][cmd_info.sender_data.user] = arg
