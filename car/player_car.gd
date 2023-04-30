extends Node2D
class_name PlayerCar

signal destination_reached
signal score_changed(salary: float, rating: float)
signal game_over(final_salary: float)

const _MAX_SPEED = 1000
const _THROTTLE_FORCE = 1250000
const _TURN_TORQUE = 10000

const SCORE_GAIN = preload("res://score_gain/score_gain.tscn")


@onready var _car: Car = get_node("Car")
@onready var _map: MapScene = get_parent()
@onready var _direction_marker: Sprite2D = get_node("direction_marker")

var _current_destination: Vector2 = Vector2.ZERO

var _salary: float = 0
var _rating: float = 0
var _rating_count: int = 0

var _starting_position: Vector2
var _starting_rotation: float

func _ready():
    _starting_position = _car.position
    _starting_rotation = _car.rotation
    _map.new_destination.connect(_on_new_destination)
    _map.game_state_changed.connect(_on_game_state_changed)
    _on_game_state_changed(_map._is_game_running)


func _process(delta):
    if Input.is_action_pressed("turn_left"):
        _car.turn(-delta)
    if Input.is_action_pressed("turn_right"):
        _car.turn(delta)
    if Input.is_action_pressed("throttle"):
        _car.throttle(delta)
    if Input.is_action_pressed("brake"):
        _car.throttle(-delta)
    
    var destination_vector = _current_destination - _car.global_position
    _direction_marker.global_position = _car.global_position
    _direction_marker.rotation = destination_vector.angle()
    if destination_vector.length_squared() < 128**2:
        destination_reached.emit()

func _on_new_destination(pos: Vector2):
    _current_destination = pos
    
func _on_game_state_changed(is_running: bool):
    var target_zoom = 0.25
    if is_running:
        target_zoom = 0.5
    var camera = get_node("Car/Camera2D") as Camera2D
    var zoom_tween = create_tween()
    zoom_tween.tween_property(camera, "zoom", Vector2(target_zoom, target_zoom), 1.0)
    zoom_tween.set_loops(1)
    
func _check_game_over():
    var rounded_rating = round(_rating * 10) / 10
    if _rating_count < 5 || rounded_rating >= 4:
        return
    game_over.emit(_salary)

func get_distance_from(pos: Vector2) -> float:
    return (pos - _car.global_position).length()

func receive_delivery_result(salary: float, rating: int):
    _rating_count += 1
    _rating += (rating - _rating) / _rating_count
    _salary += salary
    score_changed.emit(_salary, _rating)
    _check_game_over()
    var gain = SCORE_GAIN.instantiate()
    gain.salary = salary
    gain.rating = rating
    gain.position = _car.position
    add_child(gain)

func restart():
    _car.position = _starting_position
    _car._speed = 0
    _car.rotation = _starting_rotation
    _salary = 0
    _rating = 0
    _rating_count = 0
    score_changed.emit(_salary, _rating)
