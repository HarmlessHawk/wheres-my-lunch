extends Node2D
class_name MapScene

signal new_destination(pos: Vector2)
signal game_state_changed(is_running: bool)

@export var possible_destinations: Array[Vector2] = []

@onready var player: PlayerCar = get_node("player_car")
@onready var score_panel: ScorePanel = get_node("CanvasLayer/score_panel")
@onready var bg_music_player: AudioStreamPlayer = get_node("bg_music_player")

var _is_game_running: bool = false

var _possible_payment: float = 0
var _delivery_started: int = 0

const DESTINATION_MARKER = preload("res://destination_marker/destination_marker.tscn")
const GAME_OVER_OVERLAY = preload("res://game_over/game_over.tscn")

const _BASE_SALARY: float = 2.0
const _DISTANCE_PER_DOLLAR: int = 5000
const _BASE_DELIVERY_TIME: int = 6000
const _RATING_DROP_DURATION: int = 2000


func _ready():
    player.destination_reached.connect(_on_player_reaches_destination)
    player.score_changed.connect(_on_score_changed)
    player.game_over.connect(_on_game_over)
    (get_node("menu") as MenuOverlay).new_game.connect(_on_new_game)


func _new_destination():
    for n in get_tree().get_nodes_in_group("destination"):
        n.queue_free()
    var dest_coords = possible_destinations.pick_random()
    var marker = DESTINATION_MARKER.instantiate()
    marker.translate(dest_coords)
    marker.add_to_group("destination")
    add_child(marker)
    _possible_payment = _BASE_SALARY + round(player.get_distance_from(dest_coords) / (_DISTANCE_PER_DOLLAR / 100.0)) / 100.0
    _delivery_started = Time.get_ticks_msec()
    new_destination.emit(dest_coords)

func _on_player_reaches_destination():
    var delivery_time = Time.get_ticks_msec() - _delivery_started
    var rating = clamp(5 - (delivery_time - _BASE_DELIVERY_TIME) / _RATING_DROP_DURATION, 1, 5)
    player.receive_delivery_result(_possible_payment, rating)
    _new_destination()

func _on_score_changed(salary: float, rating: float):
    score_panel.update_rating(rating)
    score_panel.update_salary(salary)
    
func _on_new_game():
    get_node("menu").queue_free()
    _restart()

func _on_game_over(final_salary: float):
    var overlay = GAME_OVER_OVERLAY.instantiate()
    overlay.final_salary = final_salary
    overlay.back_to_menu.connect(_on_game_over_back_to_menu)
    overlay.retry.connect(_on_game_over_restart)
    add_child(overlay)
    _is_game_running = !_is_game_running
    game_state_changed.emit(_is_game_running)
    
func _restart():
    for n in get_tree().get_nodes_in_group("ai_car"):
        n.restart()
    player.restart()
    _new_destination()
    _is_game_running = true
    game_state_changed.emit(_is_game_running)
    bg_music_player.play(0)

func _on_game_over_back_to_menu():
    get_tree().reload_current_scene()

func _on_game_over_restart():
    for n in get_tree().get_nodes_in_group("game_over_overlay"):
        n.queue_free()
    _restart()
