extends Node2D
## Tela inicial: arte do jogo + menu NOVO JOGO / CONTINUAR / OPÇÕES + seletor de idioma.
## A arte (Assets/UI/title.png) já traz o título e a caixa do menu em português.
## Em inglês, o jogo cobre o texto do menu com a mesma cor da caixa e escreve
## NEW GAME / CONTINUE / OPTIONS por cima. Se existir Assets/UI/title_en.png
## (arte própria em inglês, mesmo tamanho 960x640), ela é usada no lugar.
##
## Idioma: botões PT-BR / EN-US no canto superior esquerdo (toque, clique) ou tecla L.

const Style := preload("res://UI/Style.gd")

const OPTION_Y := [435.0, 478.0, 521.0]   # centro de cada opção na arte (960x640)
const OPTION_KEYS := ["menu_new", "menu_continue", "menu_options"]
const CURSOR_X := 656.0
const TEXT_X := 686.0
const MENU_X_MIN := 636.0                 # caixa do menu na arte (para tocar nas opções)
const MENU_X_MAX := 930.0
const SELECT_SCENE := "res://UI/CharacterSelect.tscn"
const WORLD_SCENE := "res://World/World.tscn"

const ART := "res://Assets/UI/title.png"
const ART_EN := "res://Assets/UI/title_en.png"          # opcional
const MENU_COVER := Rect2(648, 402, 272, 148)           # interior da caixa do menu na arte
const MENU_COVER_COLOR := Color(0.937, 0.925, 0.906)
const MENU_TEXT_COLOR := Color(0.13, 0.12, 0.14)

var index: int = 0
var locked: bool = true
var showing_msg: bool = false
var bg: TextureRect
var cursor: Polygon2D
var menu_cover: ColorRect
var menu_labels: Array = []
var lang_buttons: Dictionary = {}
var lang_hint: Label
var msg_panel: Panel
var msg_label: Label
var fade: ColorRect


func _ready() -> void:
	bg = TextureRect.new()
	bg.texture = load(ART)
	bg.size = Vector2(960, 640)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(bg)

	# texto do menu em inglês (cobre o texto em português da arte)
	menu_cover = ColorRect.new()
	menu_cover.color = MENU_COVER_COLOR
	menu_cover.position = MENU_COVER.position
	menu_cover.size = MENU_COVER.size
	menu_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_cover.visible = false
	add_child(menu_cover)
	for i in OPTION_Y.size():
		var l := Style.label("", 26, MENU_TEXT_COLOR)
		l.position = Vector2(TEXT_X, float(OPTION_Y[i]) - 16.0)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.visible = false
		add_child(l)
		menu_labels.append(l)

	cursor = Polygon2D.new()
	cursor.polygon = PackedVector2Array([Vector2(0, 0), Vector2(0, 26), Vector2(18, 13)])
	cursor.color = Color(0.12, 0.12, 0.16)
	add_child(cursor)
	_place_cursor()

	# seletor de idioma (canto superior esquerdo)
	var x := 20.0
	for c in Lang.CODES:
		var b := Button.new()
		b.text = str(Lang.NAMES[c])
		b.position = Vector2(x, 16)
		b.size = Vector2(118, 46)
		b.focus_mode = Control.FOCUS_NONE
		Style.style_button(b)
		b.add_theme_font_size_override("font_size", 22)
		b.pressed.connect(_on_lang_pressed.bind(str(c)))
		add_child(b)
		lang_buttons[str(c)] = b
		x += 126.0
	lang_hint = Style.label("", 18)
	Style.outlined(lang_hint)
	lang_hint.position = Vector2(22, 66)
	add_child(lang_hint)

	var ui := CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	msg_panel = Style.panel(Rect2(150, 170, 660, 300))
	msg_panel.visible = false
	ui.add_child(msg_panel)
	msg_label = Style.label("", 24)
	msg_label.position = Vector2(24, 18)
	msg_label.size = Vector2(612, 260)
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_panel.add_child(msg_label)

	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 20
	add_child(fade_layer)
	fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.size = Vector2(960, 640)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(fade)

	_apply_language()
	Lang.changed.connect(_apply_language)

	var tw := create_tween()
	tw.tween_property(fade, "color:a", 0.0, 0.6)
	await tw.finished
	locked = false


## Atualiza arte, textos e botões para o idioma atual.
func _apply_language() -> void:
	var own_art: bool = Lang.is_en() and ResourceLoader.exists(ART_EN)
	bg.texture = load(ART_EN if own_art else ART)
	var overlay: bool = Lang.is_en() and not own_art
	menu_cover.visible = overlay
	for i in menu_labels.size():
		(menu_labels[i] as Label).text = Lang.t(str(OPTION_KEYS[i]))
		(menu_labels[i] as Label).visible = overlay
	for c in lang_buttons:
		_style_lang_button(lang_buttons[c] as Button, str(c) == Lang.code)
	lang_hint.text = Lang.t("lang_hint")
	lang_hint.visible = not Game.touch_on


func _style_lang_button(b: Button, active: bool) -> void:
	if active:
		b.add_theme_stylebox_override("normal", Style.box(Style.ACCENT, Style.BORDER))
		b.add_theme_stylebox_override("hover", Style.box(Style.ACCENT, Style.BORDER))
		b.add_theme_color_override("font_color", Style.DARK_TEXT)
		b.add_theme_color_override("font_hover_color", Style.DARK_TEXT)
	else:
		b.add_theme_stylebox_override("normal", Style.box(Style.BG_LIGHT))
		b.add_theme_stylebox_override("hover", Style.box(Style.BG_LIGHT, Style.ACCENT))
		b.add_theme_color_override("font_color", Style.TEXT)
		b.add_theme_color_override("font_hover_color", Style.TEXT)


func _on_lang_pressed(code: String) -> void:
	if locked:
		return
	Lang.set_language(code)


## Toque / clique direto nas opções do menu (celular e mouse).
func _input(event: InputEvent) -> void:
	if locked:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if showing_msg:
		showing_msg = false
		msg_panel.visible = false
		return
	var p: Vector2 = event.position
	if p.x < MENU_X_MIN or p.x > MENU_X_MAX:
		return
	for i in OPTION_Y.size():
		if absf(p.y - float(OPTION_Y[i])) <= 21.5:
			index = i
			_place_cursor()
			_choose()
			return


func _place_cursor() -> void:
	cursor.position = Vector2(CURSOR_X, float(OPTION_Y[index]) - 13.0)


func _process(_delta: float) -> void:
	if locked:
		return
	if showing_msg:
		if Game.just("interact") or Game.just("cancel"):
			showing_msg = false
			msg_panel.visible = false
		return
	if Game.just("language"):
		Lang.toggle()
	elif Game.just("move_up"):
		index = (index + OPTION_Y.size() - 1) % OPTION_Y.size()
		_place_cursor()
	elif Game.just("move_down"):
		index = (index + 1) % OPTION_Y.size()
		_place_cursor()
	elif Game.just("interact"):
		_choose()


func _choose() -> void:
	match index:
		0:
			Game.new_game()
			_go(SELECT_SCENE)
		1:
			if Game.load_game():
				_go(WORLD_SCENE)
			else:
				_show_message(Lang.t("no_save", [Game.dica(Lang.t("close_z"), Lang.t("close_tap"))]))
		2:
			if Game.touch_on:
				_show_message(Lang.t("controls_touch"))
			else:
				_show_message(Lang.t("controls_kb"))


func _show_message(text: String) -> void:
	msg_label.text = text
	msg_panel.visible = true
	showing_msg = true


func _go(path: String) -> void:
	locked = true
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 1.0, 0.4)
	await tw.finished
	get_tree().change_scene_to_file(path)
