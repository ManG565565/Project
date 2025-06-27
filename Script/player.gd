class_name Player
extends CharacterBody2D

@onready var death_screen = preload("res://death_screen.tscn")

signal health_changed (new_health)

const SPEED = 200.0
const DASH_SPEED = 400.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 900.0

@onready var sprite = $AnimatedSprite2D
@onready var attack_area_right = $AttackAreaRight
@onready var attack_area_left = $AttackAreaLeft

var is_dashing = false
var dash_time = 0.2
var dash_timer = 0.0
var dash_direction = 0

var health = 120
var attack_damage = 25
var is_dead = false
var active_attack_area: Area2D = null

func _ready():
	sprite.connect("animation_finished", Callable(self, "_on_AnimatedSprite2D_animation_finished"))
	attack_area_right.monitoring = false
	attack_area_left.monitoring = false
	attack_area_right.body_entered.connect(_on_attack_area_body_entered)
	attack_area_left.body_entered.connect(_on_attack_area_body_entered)

func _physics_process(delta):
	if is_dead:
		return

	# Движение и даш
	var direction = 0.0
	if Input.is_action_just_pressed("Dash") and sprite.animation != "Attack" and not is_dashing:
		is_dashing = true
		dash_timer = dash_time
		dash_direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
		if dash_direction == 0:
			dash_direction = 1
		sprite.play("Dash")

	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		if sprite.animation != "Attack":
			direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
		velocity.x = direction * SPEED

	# Гравитация и прыжок
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("Jump") and is_on_floor() and sprite.animation != "Attack" and not is_dashing:
		velocity.y = JUMP_VELOCITY

	# Атака
	if Input.is_action_just_pressed("Attack") and sprite.animation != "Attack" and not is_dashing:
		sprite.play("Attack")
		if sprite.flip_h:
			active_attack_area = attack_area_left
		else:
			active_attack_area = attack_area_right
		print("Атака начата, активна зона: ", active_attack_area.name)

	# Поворот спрайта
	if direction != 0 and not is_dashing:
		sprite.flip_h = direction < 0

	# Активация зоны атаки
	if sprite.animation == "Attack" and sprite.frame >= 2:
		if not active_attack_area.monitoring:
			active_attack_area.monitoring = true
	elif sprite.animation != "Attack":
		attack_area_right.monitoring = false
		attack_area_left.monitoring = false

	move_and_slide()

	# Анимации
	if sprite.animation != "Attack" and not is_dashing:
		if not is_on_floor():
			sprite.play("Jump")
		elif abs(velocity.x) > 0:
			sprite.play("Run")
		else:
			sprite.play("Idle")

func _on_AnimatedSprite2D_animation_finished():
	if is_dead:
		queue_free()
		return

	if sprite.animation == "Attack":
		attack_area_right.monitoring = false
		attack_area_left.monitoring = false
		
		if not is_on_floor():
			sprite.play("Jump")
		elif abs(velocity.x) > 0:
			sprite.play("Run")
		else:
			sprite.play("Idle")
	elif sprite.animation == "Dash":
		if not is_on_floor():
			sprite.play("Jump")
		elif abs(velocity.x) > 0:
			sprite.play("Run")
		else:
			sprite.play("Idle")
	elif sprite.animation == "Death":
		queue_free()

func _on_attack_area_body_entered(body):
	if body is Enemy or Enemy2 and not body.is_dead:
		print("Попадание по врагу: ", body.name)
		body.take_damage(attack_damage)

func take_damage(amount):
	if is_dead:
		return
	
	health -= amount
	print("Игрок получил урон: ", amount, " | Осталось HP: ", health)
	emit_signal("health_changed", health)
	if health <= 0:
		die()
		

func die():
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("Death")
	
	await sprite.animation_finished
	print("Анимация смерти завершена")
	
	# Создаем экран смерти
	var death_screen_scene = load("res://death_screen.tscn")
	if death_screen_scene:
		var death_screen_instance = death_screen_scene.instantiate()
		get_tree().root.add_child(death_screen_instance)
		death_screen_instance.show_death_screen()
		print("Экран смерти добавлен и показан")
	else:
		printerr("Не удалось загрузить сцену смерти!")
	
	# Скрываем healthbar
	get_tree().call_group("health_bar", "hide")
	
	# Удаляем игрока после всего
	queue_free()
	print("Игрок удален")
