class_name Fireball
extends Area2D

# fireball.gd — Proyectil de Habilidad Elemental 1 (Onda Ígnea)

@export var speed: float = 450.0
@export var damage: int = 24
@export var max_distance: float = 400.0

var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0

@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	var move_step := direction * speed * delta
	global_position += move_step
	distance_traveled += move_step.length()
	
	if distance_traveled >= max_distance:
		_explode()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage, true, global_position)
		if body.has_method("spawn_floating_text"):
			body.spawn_floating_text("¡FUEGO!", Color(1.0, 0.5, 0.1))
			
	_explode()


func _explode() -> void:
	set_physics_process(false)
	# Efecto visual de explosión
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.1)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
