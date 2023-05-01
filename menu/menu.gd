extends CanvasLayer
class_name MenuOverlay

signal new_game

@onready var items_container: VBoxContainer = get_node("Panel/menu_items_container")
@onready var credits_container: VBoxContainer = get_node("Panel/credits_container")
@onready var click_player: AudioStreamPlayer = get_node("click_player")

const _CREDITS_REVEAL_DURATION = 0.5


func _ready():
    add_to_group("menu")


func _process(delta):
    if Input.is_action_just_pressed("back"):
        if _is_credits_visible():
            _toggle_credits()
        else:
            get_tree().quit()
    
func _is_credits_visible() -> bool:
    return credits_container.modulate.a > 0
    
func _are_items_visible() -> bool:
    return items_container.modulate.a > 0

func _toggle_credits():
    var target_alpha = 0
    if !_is_credits_visible():
        target_alpha = 1
    var credits_tween = create_tween()
    credits_tween.tween_property(credits_container, "modulate:a", target_alpha, _CREDITS_REVEAL_DURATION)
    credits_tween.set_loops(1)
    var items_tween = create_tween()
    items_tween.tween_property(items_container, "modulate:a", 1 - target_alpha, _CREDITS_REVEAL_DURATION)
    items_tween.set_loops(1)

func _on_new_game_gui_input(event):
    if event is InputEventMouse:
        if event.is_pressed() && !event.is_echo():
            if _are_items_visible():
                click_player.play()
                new_game.emit()
            else:
                click_player.play()
                _toggle_credits()


func _on_credits_gui_input(event):
    if event is InputEventMouse:
        if event.is_pressed() && !event.is_echo():
            click_player.play()
            _toggle_credits()


func _on_panel_gui_input(event):
    if event is InputEventMouse:
        if event.is_pressed() && !event.is_echo() && _is_credits_visible():
            click_player.play()
            _toggle_credits()


func _on_sounds_1_gui_input(event):
    _open_url_on_click(event, "https://shapeforms.itch.io/")


func _on_music_gui_input(event):
    _open_url_on_click(event, "https://davidkbd.itch.io/")


func _on_graphics_2_gui_input(event):
    _open_url_on_click(event, "https://www.dafont.com/khurasan.d5849")


func _on_graphics_1_gui_input(event):
    _open_url_on_click(event, "https://kenney.nl/")


func _on_sounds_2_gui_input(event):
    _open_url_on_click(event, "https://kenney.nl/")


func _on_design_programming_gui_input(event):
    _open_url_on_click(event, "https://pshegger.github.io/")

func _open_url_on_click(event, url):
    if event is InputEventMouse:
        if event.is_pressed() && !event.is_echo() && _is_credits_visible():
            click_player.play()
            OS.shell_open(url)
