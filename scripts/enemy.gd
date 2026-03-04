extends CharacterBody2D

const bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

@onready var shoot_timer = $ShootTimer
@onready var rotater = $Rotater
@onready var timer: Timer = $Timer

#For bullets
const rotate_speed: float = 100.0
const shooter_timer_wait_time: float = 0.2
const spawn_point_count: int = 6
const radius: float = 16.0

#Movement
var direction: Vector2 = Vector2.LEFT
const speed: float = 100.0
var is_enemy_chase: bool = false


func _ready():
	# Create spawn points around the rotater
	var step := TAU / spawn_point_count
	
	for i in range(spawn_point_count):
		var spawn_point := Node2D.new()
		var pos := Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)
		
	# Start timers
	shoot_timer.wait_time = shooter_timer_wait_time
	shoot_timer.start()
	
func _physics_process(delta: float) -> void:
	# movement belongs in _physics_process for CharacterBody2D
	if not is_enemy_chase:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# rotate the bullet spawner
	var new_rotation: float = rotater.rotation_degrees + rotate_speed * delta
	rotater.rotation_degrees = fmod(new_rotation, 360.0)

func _on_shoot_timer_timeout() -> void:
	for s in rotater.get_children():
		var bullet := bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = s.global_position
		bullet.global_rotation = s.global_rotation
		
		
func _on_timer_timeout() -> void:
	#random time for enemy movement
	timer.wait_time = choose([1.0, 1.5, 2.0])
	if !is_enemy_chase:
		direction = choose([Vector2.RIGHT,Vector2.UP, Vector2.DOWN, Vector2.LEFT])

func choose(array):
	array.shuffle()
	return array.front()
