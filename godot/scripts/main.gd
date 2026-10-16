extends Node2D

# main.gd — Punto de entrada del juego
# Redirige de forma transparente al Menú Principal (MainMenu.tscn)

func _ready() -> void:
	print("[Main] Iniciando juego, transicionando al Menú Principal...")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
