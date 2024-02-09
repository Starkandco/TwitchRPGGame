extends Player

class_name Enemy

var options: Array[String] = ["HEALTH", "DAMAGE"]
var directions = ["UP","LEFT","LEFT","LEFT"]

func _ready():
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	$StrengthBar.value = damage
	$StrengthBar.max_value = max_damage

func queue_command():
	var randi_direction = directions[randi_range(0, 3)]
	var command = [user, 1, randi_direction]
	get_tree().get_first_node_in_group("Main").queued_actions.append(command)

func level_up(_stat):
	var stat = options[randi_range(0, 1)]
	super(stat)

func _on_area_entered(_area):
	pass
