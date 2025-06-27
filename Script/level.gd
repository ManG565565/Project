extends Node2D

@onready var health_bar = $CanvasLayer/HealthBar
@onready var player = $Player/Player


# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.max_value = player.health
	health_bar.value = health_bar.max_value
	print("Уровень инициализирован")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_health_changed(new_health):
	health_bar.value = new_health
