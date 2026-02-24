extends Area2D

@export var speed := 600.0


func _physics_process(delta: float) -> void:
	global_position += Vector2.RIGHT.rotated(global_rotation) * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("You died")
		get_tree().reload_current_scene()

func _on_KillTimer_timeout() -> void:
	queue_free()
