extends Node2D

const bullet_scene = preload("res://scenes/bullet.tscn")
@onready var shoot_timer = $ShootTimer
@onready var rotater = $Rotater

const rotate_speed = 100
const shooter_timer_wait_time = 0.2
const spawn_point_count = 6
const radius = 0.25

var direction = 1 
var speed = 100
var walk_length = 2000
var last_turn = 0

func _ready():
	var step = 2 * PI / spawn_point_count
	last_turn = Time.get_ticks_msec()
	
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)
		
	shoot_timer.wait_time = shooter_timer_wait_time
	shoot_timer.start()
	
func _physics_process(delta):
	position.x += direction * speed * delta
	var current_time = Time.get_ticks_msec()
	if (current_time - last_turn > walk_length):
		last_turn = current_time
		direction *= -1
		
func _process(delta: float) -> void: 
	var new_roation = rotater.rotation_degrees + rotate_speed * delta
	rotater.rotation_degrees = fmod(new_roation, 360)

func _on_shoot_timer_timeout() -> void:
	for s in rotater.get_children():
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = s.global_position
		bullet.global_rotation = s.global_rotation
