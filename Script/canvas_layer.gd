extends CanvasLayer

func _ready():
	# Проверка наличия кнопок с выводом ошибки в консоль
	if not $Continue:
		push_error("Кнопка Continue не найдена! Проверьте имя нода.")
	if not $Exit:
		push_error("Кнопка Exit не найдена! Проверьте имя нода.")
	
	# Подключение сигналов
	$Continue.pressed.connect(_on_continue_pressed)
	$Exit.pressed.connect(_on_quit_pressed)
	
	hide()
	get_tree().paused = false

func _input(event):
	if event.is_action_pressed("cancel"):
		toggle_pause_menu()

func toggle_pause_menu():
	visible = not visible
	get_tree().paused = visible

func _on_continue_pressed():
	toggle_pause_menu()

func _on_quit_pressed():
	get_tree().paused = false
	# Проверка существования сцены без assert
	if ResourceLoader.exists("res://menu.tscn"):
		get_tree().change_scene_to_file("res://menu.tscn")
	else:
		push_error("Файл главного меню не найден!")
