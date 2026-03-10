extends Area2D

@export var speed := 1000.0
@export var lifetime := 3.0
@export var damage := 25

var direction: Vector2 = Vector2.RIGHT
var has_hit := false

func _ready() -> void:
	top_level = true
	rotation = direction.angle()
	body_entered.connect(_on_body_hit)
	area_entered.connect(_on_area_hit)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _on_body_hit(body: Node2D) -> void:
	print("BODY HIT:", body.name)
	if has_hit:
		return
	if body.has_method("take_damage"):
		print("DAMAGING ENEMY:", body.name)
		has_hit = true
		body.take_damage(damage)
		queue_free()
		return
	var parent := body.get_parent()
	if parent and parent.has_method("take_damage"):
		print("DAMAGING BODY PARENT:", parent.name)
		has_hit = true
		parent.take_damage(damage)
		queue_free()

func _on_area_hit(area: Area2D) -> void:
	print("AREA HIT:", area.name)

	if has_hit:
		return

	if area.has_method("take_damage"):
		print("DAMAGING AREA:", area.name)
		has_hit = true
		area.take_damage(damage)
		queue_free()
		return

	var parent := area.get_parent()
	if parent and parent.has_method("take_damage"):
		print("DAMAGING AREA PARENT:", parent.name)
		has_hit = true
		parent.take_damage(damage)
		queue_free()
