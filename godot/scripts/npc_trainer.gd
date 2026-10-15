class_name NPCTrainer
extends StaticBody2D

# npc_trainer.gd — NPC Instructor de Combate para el Vertical Slice (T5.4)
# Dispara diálogos en español, orientación hacia el jugador y tutorial interactivo.

signal dialogue_started(npc_name: String, text_lines: Array[String])
signal dialogue_finished()

@export var npc_name: String = "Maestro de Armas Aldren"
@export var dialogue_lines: Array[String] = [
	"¡Saludos, Lucian! El sendero exterior hacia Chelen ya no es seguro.",
	"Una manada de lobos salvajes se ha establecido al este de la aldea.",
	"Empuña tu espada con [Espacio / Botón X] para atacar con precisión.",
	"Si recibes daño, bebe una Poción Menor con [Q / Botón Y].",
	"Hay un cofre de suministros a la derecha. ¡Ábrelo con [E] antes de partir!"
]

var interaction_count: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt_label: Label = $PromptLabel


func _ready() -> void:
	prompt_label.visible = false
	var aldren_path := "res://art_samples/npc_aldren.png"
	if ResourceLoader.exists(aldren_path):
		var tex := load(aldren_path) as Texture2D
		if tex:
			sprite.texture = tex
			sprite.modulate = Color.WHITE


func interact(player: Node) -> void:
	# Orientar al NPC hacia el jugador
	if player != null:
		sprite.flip_h = (player.global_position.x < global_position.x)
		
	var lines_to_show: Array[String]
	if interaction_count == 0:
		lines_to_show = dialogue_lines
	else:
		lines_to_show = [
			"¡Tu postura mejora, Lucian! Recuerda esquivar las embestidas directas de los lobos.",
			"Mantén la calma y ataca justo después de que fallen su salto."
		]
		
	interaction_count += 1
	emit_signal("dialogue_started", npc_name, lines_to_show)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		prompt_label.visible = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		prompt_label.visible = false
