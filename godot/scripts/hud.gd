class_name GameHUD
extends CanvasLayer

# hud.gd — Interfaz de usuario (HUD) para el Vertical Slice de Heroes Lore: Zero
# Muestra:
#   - Barras de HP, MP y EXP con valores numéricos
#   - Barra de 6 SLOTS DE ACCIÓN con keybindings, iconos, costes de MP y cooldowns en tiempo real:
#       Slot 1: [1] Golpe Brutal (12 MP)
#       Slot 2: [2] Embestida (15 MP)
#       Slot 3: [3] Onda Ígnea (10 MP)
#       Slot 4: [4] Rayo 360° (14 MP)
#       Slot 5: [5/Q] Poción HP (+50 HP)
#       Slot 6: [6/R] Poción MP (+25 MP)
#   - Panel de diálogos narrativo

signal dialogue_advanced()
signal dialogue_closed()

@onready var hp_bar: ProgressBar = $StatusPanel/VBox/HPContainer/HPBar
@onready var hp_label: Label = $StatusPanel/VBox/HPContainer/HPLabel
@onready var mp_bar: ProgressBar = $StatusPanel/VBox/MPContainer/MPBar
@onready var mp_label: Label = $StatusPanel/VBox/MPContainer/MPLabel
@onready var exp_bar: ProgressBar = $StatusPanel/VBox/EXPBar
@onready var name_label: Label = $StatusPanel/VBox/NameLabel

# Las 6 barras de cooldown de los slots
@onready var cd_bar_1: ProgressBar = $ActionBar/Slots/Slot1/CooldownOverlay
@onready var cd_bar_2: ProgressBar = $ActionBar/Slots/Slot2/CooldownOverlay
@onready var cd_bar_3: ProgressBar = $ActionBar/Slots/Slot3/CooldownOverlay
@onready var cd_bar_4: ProgressBar = $ActionBar/Slots/Slot4/CooldownOverlay
@onready var cd_bar_5: ProgressBar = $ActionBar/Slots/Slot5/CooldownOverlay
@onready var cd_bar_6: ProgressBar = $ActionBar/Slots/Slot6/CooldownOverlay

@onready var badge_hp: Label = $ActionBar/Slots/Slot5/VBox/CountBadge
@onready var badge_mp: Label = $ActionBar/Slots/Slot6/VBox/CountBadge

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
	
	# Inicializar overlays de cooldown a 0
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
	hp_label.text = "%d / %d" % [current, max_hp]


func update_mp(current: int, max_mp: int) -> void:
	mp_bar.max_value = max_mp
	mp_bar.value = current
	mp_label.text = "%d / %d" % [current, max_mp]


func update_exp(current: int, next: int) -> void:
	exp_bar.max_value = next
	exp_bar.value = current


func update_level(lvl: int, character_name: String = "Lucian") -> void:
	name_label.text = "%s (Nv. %d · Guerrero)" % [character_name, lvl]


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
