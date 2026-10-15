class_name PropChest
extends StaticBody2D

# prop_chest.gd — Cofre de tesoro interactivo para el Vertical Slice (T5.5)

signal chest_opened(item_name: String, quantity: int)

@export var is_opened: bool = false
@export var item_reward_name: String = "Poción Menor"
@export var item_reward_count: int = 2
@export var gold_reward: int = 50

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt_label: Label = $PromptLabel

var tex_closed: Texture2D
var tex_open: Texture2D


func _ready() -> void:
	tex_closed = load("res://art_samples/prop_chest_closed.png")
	tex_open = load("res://art_samples/prop_chest_open.png")
	
	if is_opened and tex_open:
		sprite.texture = tex_open
	elif tex_closed:
		sprite.texture = tex_closed
		
	prompt_label.visible = false


func interact(player: Node) -> void:
	if is_opened:
		_spawn_floating_text("El cofre ya está vacío", Color(0.7, 0.7, 0.7))
		return
		
	is_opened = true
	if tex_open:
		sprite.texture = tex_open
		
	prompt_label.visible = false
	
	# Entregar recompensa al jugador (2 de HP y 2 de MP)
	if "inventory_potions_hp" in player:
		player.inventory_potions_hp += 2
	if "inventory_potions_mp" in player:
		player.inventory_potions_mp += 2
	if player.has_signal("potions_updated"):
		player.emit_signal("potions_updated", player.inventory_potions_hp, player.inventory_potions_mp)
		
	_spawn_floating_text("¡Obtenido: +2 Poción HP y +2 Poción MP!", Color(0.2, 1.0, 0.4))
	emit_signal("chest_opened", "Pociones", 4)
	
	# Efecto visual de rebote
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.85), 0.08)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.12)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if not is_opened and body.is_in_group("player"):
		prompt_label.visible = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		prompt_label.visible = false


func _spawn_floating_text(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.modulate = color
	label.z_index = 100
	label.position = Vector2(-50, -60)
	add_child(label)
	
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 40, 0.9)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tween.tween_callback(label.queue_free)
