extends CharacterBody2D

@export var speed = 400
@onready var animated_sprite = $AnimatedSprite2D
signal died
var is_dead := false

func get_input():
	if is_dead:
		return
		
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	
	# Flip based on horizontal movement only
	if input_direction.x > 0.0:
		animated_sprite.flip_h = false
	elif input_direction.x < 0.0:
		animated_sprite.flip_h = true

	# play animations
	if input_direction.x == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("walk")

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	emit_signal("died")

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()
	
