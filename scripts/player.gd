extends CharacterBody2D

@export var speed := 400
@export var projectile_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $ShootPoint
@onready var game: Node2D = get_parent() as Node2D

signal died

var is_dead := false
var is_hurt := false
var is_attacking := false
var can_attack := true

const MAX_HEALTH := 5
var health := MAX_HEALTH

var last_aim_dir: Vector2 = Vector2.RIGHT
@export var attack_cooldown := 0.2

func _ready() -> void:
	print("PLAYER READY. paused=", get_tree().paused, " process_mode=", process_mode)

func _physics_process(_delta: float) -> void:
	if Engine.get_physics_frames() % 60 == 0:
		print("PLAYER TICK")
	if Input.is_action_just_pressed("attack"):
		print("ATTACK PRESSED")
		attack()
		
	get_input()
	move_and_slide()

func get_input():
	if is_dead or is_hurt or is_attacking:
		return
	#get the user directional input 
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction != Vector2.ZERO:
		last_aim_dir = input_direction.normalized()
	velocity = input_direction * speed
	
	# Flip based on horizontal movement only
	if input_direction.x > 0.0:
		animated_sprite.flip_h = false
	elif input_direction.x < 0.0:
		animated_sprite.flip_h = true
	
	# play animations
	if input_direction == Vector2.ZERO:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("walk")

func attack() -> void:
	print("attack() dead=", is_dead,
		" hurt=", is_hurt,
		" attacking=", is_attacking,
		" can_attack=", can_attack,
		" proj_null=", projectile_scene == null,
		" has_attack_anim=", animated_sprite.sprite_frames.has_animation("attack"))
	if is_dead or is_hurt or is_attacking or not can_attack:
		return
	if projectile_scene == null:
		return

	can_attack = false
	is_attacking = true

	# Stop moving during attack (optional, but common)
	velocity = Vector2.ZERO

	# Face the aim direction if you want attack to match direction
	if last_aim_dir.x > 0.0:
		animated_sprite.flip_h = false
	elif last_aim_dir.x < 0.0:
		animated_sprite.flip_h = true

	animated_sprite.play("attack")

	# Spawn projectile (simple: spawn right away)
	_spawn_projectile(last_aim_dir)

	# Wait until attack animation ends
	await animated_sprite.animation_finished

	is_attacking = false

	# Small cooldown to prevent spamming
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _spawn_projectile(dir: Vector2) -> void:
	var proj := projectile_scene.instantiate()

	if proj.has_method("set_direction"):
		proj.call("set_direction", dir)
	else:
		proj.direction = dir.normalized()

	get_tree().current_scene.add_child(proj)
	proj.global_position = muzzle.global_position
	print("spawn", muzzle.global_position, "dir", last_aim_dir)

func damage() -> void: 
	if is_dead or is_hurt:
		return
	health -= 1
	# Update UI
	game.set_health_label()
	game.set_health_bar()
	# If dead, play death and stop here
	if health <= 0:
		die()
		return
	# Otherwise play hurt and temporarily block input animation
	is_hurt = true
	velocity = Vector2.ZERO
	animated_sprite.play("hurt")
	await animated_sprite.animation_finished
	is_hurt = false

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	emit_signal("died")


	
