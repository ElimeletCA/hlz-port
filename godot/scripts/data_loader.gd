extends Node

# DataLoader.gd — Cargador oficial de datos extraídos (T4.4)
# Lee mapas, colisiones, eventos, textos y recursos desde out/ para alimentar
# el motor de juego manteniendo los datos de lógica independientes del arte final.

var out_dir: String = ""
var _map_cache: Dictionary = {}
var _text_cache: Dictionary = {}

func _ready() -> void:
	out_dir = ProjectSettings.globalize_path("res://../out")
	print("[DataLoader] Inicializado. Directorio de datos: ", out_dir)


## Carga un mapa por nombre o identificador (ej. "m_m_00" o "m/m/00.m")
func load_map(map_id: String) -> Dictionary:
	var clean_id = map_id.replace("m/m/", "m_").replace("m/m2/", "m2_").replace(".m", "")
	if not clean_id.begins_with("m_") and not clean_id.begins_with("m2_"):
		clean_id = "m_m_" + clean_id
		
	if _map_cache.has(clean_id):
		return _map_cache[clean_id]
		
	var file_path = out_dir + "/maps/" + clean_id + ".json"
	if not FileAccess.file_exists(file_path):
		# Intentar buscar por coincidencia directa
		file_path = out_dir + "/maps/" + map_id + ".json"
		if not FileAccess.file_exists(file_path):
			printerr("[DataLoader] No se encontró el mapa: ", file_path)
			return {}
			
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		printerr("[DataLoader] Error al abrir mapa: ", file_path)
		return {}
		
	var txt = f.get_as_text()
	f.close()
	
	var data = JSON.parse_string(txt)
	if data is Dictionary:
		_map_cache[clean_id] = data
		return data
	return {}


## Carga una tabla de textos por nombre (ej. "gm", "it", "qm")
func load_text_table(table_name: String) -> Array:
	var clean_name = table_name.replace("t/", "").replace(".tdf", "")
	if _text_cache.has(clean_name):
		return _text_cache[clean_name]
		
	var file_path = out_dir + "/text/" + clean_name + ".json"
	if not FileAccess.file_exists(file_path):
		printerr("[DataLoader] No se encontró la tabla de texto: ", file_path)
		return []
		
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		return []
		
	var txt = f.get_as_text()
	f.close()
	
	var data = JSON.parse_string(txt)
	if data is Array:
		_text_cache[clean_name] = data
		return data
	return []


## Carga los marcadores de misión para un mapa
func load_mmi(map_index: int) -> Dictionary:
	var file_path = "%s/mmi/mmi_%d.json" % [out_dir, map_index]
	if not FileAccess.file_exists(file_path):
		return {}
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		return {}
	var txt = f.get_as_text()
	f.close()
	var data = JSON.parse_string(txt)
	return data if data is Dictionary else {}


## Carga un frame de tile original de out/sprites/m/tXX/ como ImageTexture
func load_raw_tile_texture(tileset_id: int, frame_idx: int) -> ImageTexture:
	var file_path = "%s/sprites/m/t%02d/frame_%03d.png" % [out_dir, tileset_id, frame_idx]
	return _load_texture_from_file(file_path)


## Carga un frame de sprite original desde out/sprites/<rel_path>.png
func load_raw_sprite_texture(rel_path: String) -> ImageTexture:
	var file_path = out_dir + "/sprites/" + rel_path
	if not file_path.ends_with(".png"):
		file_path += ".png"
	return _load_texture_from_file(file_path)


## Carga un PNG externo y crea un ImageTexture en tiempo de ejecución
func _load_texture_from_file(path: String) -> ImageTexture:
	if not FileAccess.file_exists(path):
		return null
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(img)
