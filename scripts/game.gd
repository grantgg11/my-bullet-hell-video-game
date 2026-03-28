extends Node2D

@onready var death_overlay: CanvasLayer = $DeathOverlay
@onready var player: CharacterBody2D = $Player
@onready var victory_screen: CanvasLayer = $VictoryScreen
@onready var enemy = $enemy

var dead := false
var win := false 

	
func _ready() -> void:
	set_health_label()
	set_health_bar()
	get_tree().paused = false
	Engine.time_scale = 1.0

	process_mode = Node.PROCESS_MODE_ALWAYS
	death_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	victory_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	death_overlay.visible = false
	victory_screen.visible = false 

	player.died.connect(on_player_died)
	enemy.win.connect(on_enemy_died)
#when player dies, show death overlay and slow down time. 
func on_player_died() -> void:
	if dead:
		return
	dead = true

	Engine.time_scale = 0.5
	await get_tree().create_timer(0.6).timeout
	Engine.time_scale = 1.0

	get_tree().paused = true
	death_overlay.visible = true
	
func on_enemy_died() -> void:
	if win: 
		return 
	win = true
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.6).timeout
	Engine.time_scale = 1.0
	get_tree().paused = true
	victory_screen.visible = true
	victory()

func victory() -> void: 
	if victory_screen.visible == true and Input.is_action_pressed("Start"):
		get_tree().change_scene_to_file("res://scenes/Title/TitleScreen.tscn")

func _input(event: InputEvent) -> void:
	if dead and event.is_action_pressed("restart"):
		get_tree().paused = false
		death_overlay.visible = false
		get_tree().reload_current_scene()

func set_health_label() -> void: 
	$HealthBar/MarginContainer/VBoxContainer/HealthLabel.text = "Health: %s" % player.health

func set_health_bar() -> void: 
	$HealthBar/MarginContainer/VBoxContainer/HealthBar.value = player.health
