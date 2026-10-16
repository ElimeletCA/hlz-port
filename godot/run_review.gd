extends SceneTree

func _init() -> void:
	print("[Launcher] Cargando escena AnimReview.tscn en tiempo real...")
	change_scene_to_file("res://scenes/AnimReview.tscn")
