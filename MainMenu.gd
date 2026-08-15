extends Control

signal navigation_requested(destination: StringName)
signal social_action_requested(action: StringName)

const MAIN_MENU_BACKGROUND_PATH := "res://assets/ui/main_menu/main_menu_background.png"

@export var player_name: String = "VOIDRUNNER"
@export_range(1, 999, 1) var player_level: int = 24
@export_range(0, 100, 1) var xp_percent: int = 68
@export_range(0, 999999, 1) var credits: int = 12450
@export_range(0, 99999, 1) var tokens: int = 860
@export var destination_scenes: Dictionary = {}

@onready var player_name_label: Label = %PlayerName
@onready var level_label: Label = %LevelLabel
@onready var xp_bar: ProgressBar = %XPBar
@onready var credits_label: Label = %CreditsLabel
@onready var tokens_label: Label = %TokensLabel
@onready var status_label: Label = %StatusLabel
@onready var background_image: TextureRect = %BackgroundImage

var _base_minimum_sizes: Dictionary = {}


func _ready() -> void:
	_apply_background_artwork()
	_cache_minimum_sizes()
	_refresh_profile()
	_connect_menu_buttons()
	_connect_feature_cards()
	_connect_primary_action_hover()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()


func _apply_background_artwork() -> void:
	# Die in der Szene gespeicherte GradientTexture bleibt als sicherer Fallback.
	if not ResourceLoader.exists(MAIN_MENU_BACKGROUND_PATH, "Texture2D"):
		return
	var artwork: Resource = ResourceLoader.load(MAIN_MENU_BACKGROUND_PATH, "Texture2D")
	if artwork is Texture2D:
		background_image.texture = artwork as Texture2D


func _connect_menu_buttons() -> void:
	for node in get_tree().get_nodes_in_group("main_menu_navigation"):
		if node is Button:
			var button := node as Button
			button.pressed.connect(_on_navigation_button_pressed.bind(button))
	for node in get_tree().get_nodes_in_group("main_menu_social"):
		if node is Button:
			var button := node as Button
			button.pressed.connect(_on_social_button_pressed.bind(button))


func _connect_feature_cards() -> void:
	for node in get_tree().get_nodes_in_group("main_menu_card"):
		if node is PanelContainer:
			var card := node as PanelContainer
			card.mouse_entered.connect(_on_card_hover_changed.bind(card, true))
			card.mouse_exited.connect(_on_card_hover_changed.bind(card, false))


func _connect_primary_action_hover() -> void:
	for node in get_tree().get_nodes_in_group("primary_action_button"):
		if node is Button:
			var button := node as Button
			button.mouse_entered.connect(_on_primary_hover_changed.bind(button, true))
			button.mouse_exited.connect(_on_primary_hover_changed.bind(button, false))


func _refresh_profile() -> void:
	player_name_label.text = player_name
	level_label.text = "LEVEL %d" % player_level
	xp_bar.value = xp_percent
	xp_bar.tooltip_text = "%d%% bis zum nächsten Level" % xp_percent
	credits_label.text = "%s  CREDITS" % _format_number(credits)
	tokens_label.text = "%s  TOKENS" % _format_number(tokens)


func _on_navigation_button_pressed(button: Button) -> void:
	var route := StringName(str(button.get_meta("route", "")))
	if route == &"quit":
		get_tree().quit()
		return
	if bool(button.get_meta("selectable", false)):
		_set_active_navigation_button(button)

	status_label.text = "%s WIRD GELADEN …" % button.text.to_upper()
	navigation_requested.emit(route)

	var target_scene: Variant = destination_scenes.get(route)
	if target_scene is PackedScene:
		get_tree().change_scene_to_packed(target_scene as PackedScene)


func _on_social_button_pressed(button: Button) -> void:
	var action := StringName(str(button.get_meta("action", "")))
	status_label.text = "%s GEÖFFNET" % button.tooltip_text.to_upper()
	social_action_requested.emit(action)


func _set_active_navigation_button(active_button: Button) -> void:
	for node in get_tree().get_nodes_in_group("main_menu_navigation"):
		if node is Button and bool(node.get_meta("selectable", false)):
			(node as Button).button_pressed = node == active_button


func _on_card_hover_changed(card: PanelContainer, hovered: bool) -> void:
	var target_color := Color(1.08, 1.04, 1.14, 1.0) if hovered else Color.WHITE
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "self_modulate", target_color, 0.16)


func _on_primary_hover_changed(button: Button, hovered: bool) -> void:
	button.pivot_offset = button.size * 0.5
	var existing_tween: Variant = button.get_meta("hover_tween", null)
	if existing_tween is Tween:
		var old_tween := existing_tween as Tween
		if old_tween.is_valid():
			old_tween.kill()
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button.set_meta("hover_tween", tween)
	var target_scale := Vector2(1.035, 1.035) if hovered else Vector2.ONE
	tween.tween_property(button, "scale", target_scale, 0.14)


func _cache_minimum_sizes() -> void:
	for node in find_children("*", "Control", true, false):
		var control := node as Control
		if control.custom_minimum_size != Vector2.ZERO:
			_base_minimum_sizes[control] = control.custom_minimum_size


func _on_viewport_size_changed() -> void:
	# Containers übernehmen das eigentliche Layout. Die Skalierung schützt die
	# 1920x1080-Komposition zusätzlich bei kleineren Fenstergrößen.
	var viewport_size := get_viewport_rect().size
	var scale_factor: float = clampf(minf(viewport_size.x / 1920.0, viewport_size.y / 1080.0), 0.42, 1.15)
	if theme != null:
		theme.default_base_scale = scale_factor
	var minimum_size_scale := minf(scale_factor, 1.0)
	for control in _base_minimum_sizes.keys():
		if is_instance_valid(control):
			var base_size: Vector2 = _base_minimum_sizes[control]
			(control as Control).custom_minimum_size = base_size * minimum_size_scale


func _format_number(value: int) -> String:
	var source := str(value)
	var result := ""
	while source.length() > 3:
		result = "." + source.right(3) + result
		source = source.substr(0, source.length() - 3)
	return source + result
