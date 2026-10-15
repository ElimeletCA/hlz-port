class_name GameHUD
extends CanvasLayer

# hud.gd — Interfaz de usuario unificada (HUD) inspirada fielmente en Heroes Lore: Zero
# Integra en UNA SOLA TARJETA INFERIOR:
#   - Barra de Salud (HP - Rojo)
#   - Barra de Habilidades de Clase (SP - Azul)
#   - Barra de Habilidades Elementales (EP - Verde)
#   - Línea fina de Experiencia (EXP - Amarillo)
#   - Los 6 Slots de Acción organizados debajo:
#       [1] Clase 1 (Azul)  |  [2] Clase 2 (Azul)
#       [3] Elem 1 (Verde)  |  [4] Elem 2 (Verde)
#       [5] Poción HP       |  [6] Poción SP

signal dialogue_advanced()
signal dialogue_closed()

# Referencias a la tarjeta unificada inferior
@onready var name_label: Label = $CombatCard/VBox/Header/NameLabel
@onready var hp_bar: ProgressBar = $CombatCard/VBox/Bars/HPBar
@onready var sp_bar: ProgressBar = $CombatCard/VBox/Bars/ResourceRow/SPBar
@onready var ep_bar: ProgressBar = $CombatCard/VBox/Bars/ResourceRow/EPBar
@onready var exp_bar: ProgressBar = $CombatCard/VBox/Bars/EXPBar

# Las 6 barras de cooldown de los slots
@onready var cd_bar_1: ProgressBar = $CombatCard/VBox/Slots/Slot1/CooldownOverlay
@onready var cd_bar_2: ProgressBar = $CombatCard/VBox/Slots/Slot2/CooldownOverlay
@onready var cd_bar_3: ProgressBar = $CombatCard/VBox/Slots/Slot3/CooldownOverlay
@onready var cd_bar_4: ProgressBar = $CombatCard/VBox/Slots/Slot4/CooldownOverlay
@onready var cd_bar_5: ProgressBar = $CombatCard/VBox/Slots/Slot5/CooldownOverlay
@onready var cd_bar_6: ProgressBar = $CombatCard/VBox/Slots/Slot6/CooldownOverlay

@onready var badge_hp: Label = $CombatCard/VBox/Slots/Slot5/VBox/CountBadge
@onready var badge_mp: Label = $CombatCard/VBox/Slots/Slot6/VBox/CountBadge

# Diálogos
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Margin/VBox/SpeakerLabel
@onready var dialogue_text: Label = $DialoguePanel/Margin/VBox/DialogueText
@onready var prompt_next: Label = $DialoguePanel/Margin/VBox/PromptNext

var is_dialogue_active: bool = false
var current_dialogue_lines: Array[String] = []
var current_line_idx: int = 0


func _ready() -> void:
	dialogue_panel.visible = false
	prompt_next.visible = true
	
	for bar in [cd_bar_1, cd_bar_2, cd_bar_3, cd_bar_4, cd_bar_5, cd_bar_6]:
		if bar:
			bar.max_value = 1.0
			bar.value = 0.0
			bar.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if is_dialogue_active:
		if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
			advance_dialogue()
			get_viewport().set_input_as_handled()


func update_hp(current: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current


func update_sp(current: int, max_sp: int) -> void:
	sp_bar.max_value = max_sp
	sp_bar.value = current


func update_ep(current: int, max_ep: int) -> void:
	ep_bar.max_value = max_ep
	ep_bar.value = current


# Compatibilidad
func update_mp(current: int, max_mp: int) -> void:
	update_sp(current, max_mp)


func update_exp(current: int, next: int) -> void:
	exp_bar.max_value = next
	exp_bar.value = current


func update_level(lvl: int, character_name: String = "Lucian") -> void:
	name_label.text = "%s  ·  Nv. %d Guerrero" % [character_name, lvl]


func update_potions(hp_count: int, mp_count: int) -> void:
	badge_hp.text = "x%d" % hp_count
	badge_mp.text = "x%d" % mp_count


func update_slot_cooldown(slot_idx: int, cur_cd: float, max_cd: float) -> void:
	var target_bar: ProgressBar = null
	match slot_idx:
		1: target_bar = cd_bar_1
		2: target_bar = cd_bar_2
		3: target_bar = cd_bar_3
		4: target_bar = cd_bar_4
		5: target_bar = cd_bar_5
		6: target_bar = cd_bar_6
		
	if target_bar:
		if cur_cd > 0.0:
			target_bar.visible = true
			target_bar.max_value = max_cd
			target_bar.value = cur_cd
		else:
			target_bar.value = 0.0
			target_bar.visible = false


# ==============================================================================
# DIÁLOGOS
# ==============================================================================

func start_dialogue(speaker: String, lines: Array[String]) -> void:
	if lines.is_empty():
		return
	is_dialogue_active = true
	current_dialogue_lines = lines
	current_line_idx = 0
	speaker_label.text = speaker
	dialogue_panel.visible = true
	_show_current_line()


func _show_current_line() -> void:
	if current_line_idx < current_dialogue_lines.size():
		dialogue_text.text = current_dialogue_lines[current_line_idx]
	else:
		close_dialogue()


func advance_dialogue() -> void:
	current_line_idx += 1
	if current_line_idx >= current_dialogue_lines.size():
		close_dialogue()
	else:
		_show_current_line()
		emit_signal("dialogue_advanced")


func close_dialogue() -> void:
	is_dialogue_active = false
	dialogue_panel.visible = false
	emit_signal("dialogue_closed")
