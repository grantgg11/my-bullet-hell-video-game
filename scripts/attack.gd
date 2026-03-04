extends Area2D

@export var speed := 1000.0
@export var lifetime := 3.0

var direction: Vector2 = Vector2.RIGHT


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

func _on_body_hit(_body: Node2D) -> void:
	queue_free()

func _on_area_hit(_area: Area2D) -> void:
	queue_free()
