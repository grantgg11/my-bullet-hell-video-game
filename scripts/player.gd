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
	update_mouse_aim()
	if Input.is_action_just_pressed("attack"):
		attack()
		
	get_input()
	update_animation()
	move_and_slide()

func update_mouse_aim() -> void:
	var mouse_dir := get_global_mouse_position() - global_position
	if mouse_dir.length() >0.0: 
		last_aim_dir = mouse_dir.normalized()
	if last_aim_dir.x >0.0:
		animated_sprite.flip_h = false
	elif last_aim_dir.x < 0.0:
		animated_sprite.flip_h = true
	
func get_input():
	if is_dead or is_hurt:
		velocity = Vector2.ZERO
		return
	#get the user directional input 
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed

func attack() -> void:
	if is_dead or is_hurt or is_attacking or not can_attack:
		return
	if projectile_scene == null:
		return
		
	can_attack = false
	is_attacking = true
	# Update aim right before firing
	update_mouse_aim()
	
	animated_sprite.play("attack")
	_spawn_projectile(last_aim_dir)
	# Wait until attack animation ends
	await animated_sprite.animation_finished
	is_attacking = false
	
	# Small cooldown to prevent spamming
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _spawn_projectile(dir: Vector2) -> void:
	var proj := projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = muzzle.global_position + dir * 8.0
	
	if proj.has_method("set_direction"):
		proj.set_direction(dir)
	else:
		proj.direction = dir.normalized()
		
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

func update_animation() -> void:
	if is_dead:
		return
		
	if is_hurt:
		if animated_sprite.animation != "hurt":
			animated_sprite.play("hurt")
		return
		
	if is_attacking:
		if animated_sprite.animation != "attack":
			animated_sprite.play("attack")
		return
		
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("walk")


	
