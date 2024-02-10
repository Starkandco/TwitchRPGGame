extends CharacterBody2D

class_name Player

const horizontal_speed: int = 64
const vertical_speed: int = 128
@export var damage: int = 5
@export var max_damage: int = 100
@export var health: int = 100
@export var max_health: int = 100
var experience: int = 0
var level: int = 1
var level_tokens: int = 0
var user: String = ""

signal died

func level_up(stat):
	if level_tokens == 0:
		return
	level_tokens -= 1
	match stat:
		"DAMAGE":
			damage += 5
			if damage > 100:
				damage = 100
			$StrengthBar.value = damage
		"HEALTH":
			max_health += 25
			$HealthBar.max_value = max_health

func prepare_move(direction):
	match direction:
		"RIGHT":
			$Arrow.visible = true
			$Arrow.rotation_degrees = 0
		"LEFT":
			$Arrow.visible = true
			$Arrow.rotation_degrees = 180
		"UP":
			$Arrow.visible = true
			$Arrow.rotation_degrees = 270
		"DOWN":
			$Arrow.visible = true
			$Arrow.rotation_degrees = 90
		

func move(direction):
	$Arrow.visible = false
	$Arrow.rotation_degrees = 0
	match direction:
		"RIGHT":
			velocity = Vector2.RIGHT * horizontal_speed
		"LEFT":
			velocity = Vector2.LEFT * horizontal_speed
		"UP":
			velocity = Vector2.UP * vertical_speed
		"DOWN":
			velocity = Vector2.DOWN * vertical_speed
	
	var tween = create_tween()
	tween.tween_callback(stop).set_delay(1)

func stop():
	velocity = Vector2.ZERO

func attack(unit):
	while(health >= 0 and unit.health >= 0): 
		unit.take_damage(self)
		if unit.health <= 0:
			break
		take_damage(unit)

func take_damage(body):
	health -= body.damage
	$HealthBar.value = health
	if health <= 0:
		body.gain_experience(5)
		died.emit()

func gain_experience(new_exp):
	experience += new_exp
	if experience >= (10 * level):
		experience = experience - (10 * level)
		level += 1
		level_tokens += 1
		$Label.text = "Lvl:" + str(level)
		health = max_health
		$HealthBar.value = health

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = Vector2.ZERO

func _on_area_entered(area):
	var entity = area.get_parent()
	if entity is Enemy:
		attack(entity)
