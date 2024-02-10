extends Node2D

@onready var player_scene = preload("res://Player/Player.tscn")
@onready var enemy_scene = preload("res://Enemy/Enemy.tscn")
var players = {}
var colours = [Color.PINK, Color.AQUA, Color.FUCHSIA, Color.PURPLE, Color.VIOLET, Color.INDIGO, Color.BLUE, Color.LIGHT_BLUE, Color.CYAN, Color.TEAL, Color.DARK_GREEN, Color.GREEN, Color.LIME, Color.YELLOW, Color.ORANGE, Color.RED, Color.GRAY, Color.LIGHT_SLATE_GRAY, Color.MISTY_ROSE]
var positions = []
var queued_actions = []
var spawn = 4
var spawn_counter = 4

enum {JOIN, MOVE, LEVELUP, LEAVE}

func _ready():
	for x in range(65, DisplayServer.window_get_size().x  - 63, 64):
		for y in range(129, DisplayServer.window_get_size().y - 127, 128):
			positions.append(Vector2(x, y))

func _process(_delta):
	$Timer/Label.text = str(int($Timer.time_left))
	if players.size() == 0 and queued_actions.size() != 0:
		_on_timer_timeout()

func join(user):
	var bots = get_tree().get_nodes_in_group("Bot")
	var number_of_players = players.size() - bots.size()
	if number_of_players < colours.size():
		if is_open_position():
			var player = player_scene.instantiate()
			player.user = user
			$GameBoard/Players.call_deferred("add_child", player)
			players[user] = [player, 0, colours[number_of_players - 1]]
			player.global_position = get_open_position()
			player.died.connect(leave.bind(user))
			player.get_node("Sprite2D").modulate = colours[number_of_players - 1]
			player.get_node("Label2").text = user

func leave(user):
	if players.has(user):
		players[user][0].queue_free()
		players.erase(user)
		if players.size() == 0:
			$Timer.stop()

func get_open_position() -> Vector2:
	for option in positions:
		if !is_entity_in_spot(option):
			return option
	return Vector2.ZERO
	
func get_enemy_position() -> Vector2:
	for option in range(positions.size() - 1, 0, -1):
		if !is_entity_in_spot(positions[option]):
			return positions[option]
	return Vector2.ZERO

func is_open_position() -> bool:
	for option in positions:
		if !is_entity_in_spot(option):
			return true
	return false

func is_entity_in_spot(spot) -> bool:
	for player in get_tree().get_nodes_in_group("Player"): 
		if player.global_position == spot:
			return true
	return false

func _on_timer_timeout():
	all_players_experience()
	for action in queued_actions:
		if action[1] != JOIN:
			if players.has(action[0]) and is_instance_valid(players[action[0]][0]):
				match action[1]:
					MOVE:
						players[action[0]][0].move(action[2])
					LEVELUP:
						players[action[0]][0].level_up(action[2])
					LEAVE:
						leave(action[0])
		elif action[1] == JOIN:
			if players.size() == 0:
				$GameBoard/Label.visible = false
				$Timer.start()
			join(action[0])
	queued_actions.clear()
	await get_tree().create_timer(1).timeout
	if spawn_counter >= spawn and !$Timer.is_stopped():
		spawn_counter = 0
		if is_open_position():
			var bots = get_tree().get_nodes_in_group("Bot")
			if bots.size() < colours.size():
				var enemy = enemy_scene.instantiate()
				enemy.user = "BOT BEEP BOOP - " + str(randf_range(0, 100))
				players[enemy.user] = [enemy, 0, colours[bots.size() - 1]]
				add_child(enemy)
				enemy.died.connect(leave.bind(enemy.user))
				enemy.global_position = get_enemy_position()
				enemy.get_node("Sprite2D").modulate = colours[bots.size() - 1]
				enemy.queue_command()
				$Timer.timeout.connect(enemy.queue_command)
	else:
		spawn_counter += 1

func all_players_experience():
	for player in get_tree().get_nodes_in_group("Player"):
		player.gain_experience(2)

func round_over():
	$Timer.stop()
	$GameBoard/Label.visible = true
	await get_tree().create_timer(5).timeout
	for player in get_tree().get_nodes_in_group("Player"):
		player.queue_free()
	players.clear()

func _on_enemy_goal_body_entered(body):
	if body is Enemy:
		$GameBoard/Label.text = "Enemies win. What."
		round_over()


func _on_player_goal_body_entered(body):
	if body is Player and !body is Enemy:
		$GameBoard/Label.text = "PLAYERS WIN!!"
		round_over()
