extends Node2D

@onready var animation_player = $DeathScreen/DeathAnimation
@onready var restart_button = $DeathScreen/Restart
@onready var quit_button = $DeathScreen/Quit

func _ready():
	# Настройки для корректного отображения
	process_mode = Node.PROCESS_MODE_ALWAYS  # Работает даже на паузе
	
	hide()
	
func _on_restart_pressed():
	print("Начало перезагрузки уровня")
	
	# 1. Полностью снимаем паузу
	get_tree().paused = false
	
	# 2. Очищаем текущую сцену
	get_tree().current_scene.queue_free()
	
	# 3. Альтернативный способ загрузки с проверкой
	var level_scene = load("res://level.tscn") as PackedScene
	if level_scene:
		print("Сцена level.tscn успешно загружена")
		var new_level = level_scene.instantiate()
		
		# 4. Добавляем новую сцену
		get_tree().root.add_child(new_level)
		get_tree().current_scene = new_level
		
		# 5. Удаляем экран смерти
		queue_free()
		print("Уровень успешно перезагружен")
	else:
		printerr("Ошибка: Не удалось загрузить level.tscn!")

func _on_quit_pressed():
	get_tree().quit()

func show_death_screen():
	print("Функция show_death_screen вызвана")
	show()
	
	# Для AnimatedSprite2D в DeathScreen (если он есть)
	if has_node("DeathAnimation"):
		var death_sprite = $DeathScreen
		if death_sprite.sprite_frames.has_animation("Death"):
			print("Запускаю анимацию смерти на экране")
			death_sprite.play("Death")
		else:
			printerr("Анимация Death не найдена в AnimatedSprite2D! Доступные анимации:", death_sprite.sprite_frames.get_animation_names())
	
	get_tree().paused = true
	print("Игра поставлена на паузу")
