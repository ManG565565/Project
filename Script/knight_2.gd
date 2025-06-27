class_name Enemy2
extends CharacterBody2D

const SPEED = 100.0
const ATTACK_DISTANCE = 70.0
const ATTACK_COOLDOWN = 1.0

@onready var sprite = $AnimatedSprite2D
@onready var detect_area = $Detector

var target = null
var is_dead = false
var is_attacking = false
var health = 90
var damage = 25

func _ready():
	add_to_group("enemies")
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	if is_dead:
		velocity.x = 0
		move_and_slide()
		return

	if target:
		var direction = (target.global_position - global_position).normalized()
		var distance = global_position.distance_to(target.global_position)

		if distance > ATTACK_DISTANCE:
			if not is_attacking:
				velocity.x = direction.x * SPEED
				sprite.flip_h = velocity.x < 0
				if sprite.animation != "Walk":
					sprite.play("Walk")
		else:
			velocity.x = 0
			if not is_attacking:
				start_attack()
	else:
		velocity.x = 0
		if sprite.animation != "Idle":
			sprite.play("Idle")

	move_and_slide()

func _on_body_entered(body):
	if body is Player:
		target = body
		print("Обнаружен игрок")

func _on_body_exited(body):
	if body is Player and body == target:
		target = null
		is_attacking = false
		print("Игрок ушёл")

func start_attack():
	is_attacking = true
	sprite.play("Attack")
	print("Враг атакует!")

func _on_animation_finished():
	if sprite.animation == "Attack":
		if target and not target.is_dead and target.has_method("take_damage"):
			target.take_damage(damage)
		start_attack_cooldown()
	elif sprite.animation == "Death":
		queue_free()

func start_attack_cooldown():
	is_attacking = true
	var timer = Timer.new()
	timer.wait_time = ATTACK_COOLDOWN
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(_on_attack_cooldown_timeout.bind(timer))

func _on_attack_cooldown_timeout(timer):
	is_attacking = false
	timer.queue_free()

func take_damage(amount):
	if is_dead:
		return
	
	# Визуальная обратная связь
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	health -= amount
	print("Враг получил урон: ", amount, " | Осталось HP: ", health)
	
	if health <= 0:
		die()

func die():
	is_dead = true
	velocity.x = 0
	sprite.play("Death")
	set_collision_layer_value(1, false)  # Отключаем коллизии
