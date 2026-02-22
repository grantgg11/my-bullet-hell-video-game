extends Node2D

const speed = 100


func _process(delta: float) -> void:
	# Just making the bullet go foward 
	position += transform.x * speed * delta

func _on_KillTimer_timeout() -> void:
	queue_free()
