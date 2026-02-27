extends Area2D

@export var speed := 600.0
var hit := false

func _physics_process(delta: float) -> void:
	global_position += Vector2.RIGHT.rotated(global_rotation) * speed * delta

func _on_body_entered(body: Node) -> void:
	if hit:
		return
	if not body.is_in_group("player"):
		return
	
	hit = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	if body.has_method("damage"):
		body.call("damage")
		
	# Remove the bullet so it can't hit again
	queue_free()
