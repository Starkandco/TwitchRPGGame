extends Player

class_name Enemy

var options: Array[String] = ["HEALTH", "DAMAGE"]
var directions = ["UP","LEFT","LEFT","LEFT"]

func queue_command():
	var randi_direction = directions[randi_range(0, 3)]
	prepare_move(randi_direction)
	if !get_tree().get_first_node_in_group("Main").queued_actions.has(1):
		get_tree().get_first_node_in_group("Main").queued_actions[1] = {user: randi_direction}
	else:
		get_tree().get_first_node_in_group("Main").queued_actions[1][user] = randi_direction

func level_up(_stat):
	var stat = options[randi_range(0, 1)]
	super(stat)

func _on_area_entered(_area):
	pass
