extends Node2D

@onready var player_scene = preload("res://Player/Player.tscn")
@onready var enemy_scene = preload("res://Enemy/Enemy.tscn")
var players = {}
var colours = [Color.PINK, Color.AQUA, Color.FUCHSIA, Color.PURPLE, Color.VIOLET, Color.INDIGO, Color.BLUE, Color.LIGHT_BLUE, Color.CYAN, Color.TEAL, Color.DARK_GREEN, Color.GREEN, Color.LIME, Color.YELLOW, Color.ORANGE, Color.RED, Color.GRAY, Color.LIGHT_SLATE_GRAY, Color.MISTY_ROSE]
var positions = []
var queued_actions = {}
var spawn = 4
var spawn_counter = 4
var started = false

signal actions_complete

enum {LEAVE, MOVE, JOIN, LEVELUP}

func _ready():
	for x in range(66, DisplayServer.window_get_size().x  - 63, 64):
		for y in range(130, DisplayServer.window_get_size().y - 127, 128):
			positions.append(Vector2(x, y))

func _process(_delta):
	$Timer/Label.text = str(int($Timer.time_left))
	if players.size() == 0 and queued_actions.size() != 0 and $Timer.is_stopped() and !started:
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
		var player_x = roundf(player.global_position.x)
		var player_y = roundf(player.global_position.y)
		if Vector2(player_x, player_y) == spot:
			return true
	return false

func _on_timer_timeout():
	started = true
	$Timer.stop()
	all_players_experience()
	for x in range(4):
		if x == 2:
			try_create_bot()
		if !queued_actions.has(x): continue
		await loop_actions(x)
	queued_actions.clear()
	started = false
	$Timer.start()
	actions_complete.emit()

func try_create_bot() -> void:
	if spawn_counter >= spawn:
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
				actions_complete.connect(enemy.queue_command)
	else:
		spawn_counter += 1

func loop_actions(x) -> void:
	match x:
		JOIN:
			for y in range(queued_actions[JOIN].size()):
				join(queued_actions[JOIN][y])
				if players.size() == 1: 
					$GameBoard/Label.visible = false
				await get_tree().create_timer(1).timeout
			return
		MOVE:
			for player_name in queued_actions[MOVE]:
				players[player_name][0].move(queued_actions[MOVE][player_name])
				await get_tree().create_timer(1).timeout
			return
		LEVELUP:
			for y in range(queued_actions[LEVELUP].size()):
				players[queued_actions[LEVELUP][y][0]][0].level_up(queued_actions[LEVELUP][y][1])
			return
		LEAVE:
			for y in range(queued_actions[LEAVE].size()):
				leave(queued_actions[LEAVE][y])
			return

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
