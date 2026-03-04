extends Area2D

@export var damage := 10

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 4

func set_disabled(is_disabled: bool) -> void:
	_collision_shape.set_deferred("disabled", is_disabled)
