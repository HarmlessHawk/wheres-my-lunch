extends Node2D

const MODEL = preload("res://car/model.gd")

@export var direction: MODEL.Direction = MODEL.Direction.Right
@export var body_color: MODEL.BodyColor = MODEL.BodyColor.Green
@export var max_speed: int = 600
@export var route: Array[Vector2] = []
@export var debug: bool = false

@onready var _car: Car = get_node("Car")

var _current_target: int = 0
var _turning: bool = false

var _starting_direction: MODEL.Direction
var _starting_position: Vector2

func _ready():
    _starting_direction = direction
    _starting_position = _car.position
    restart()
    add_to_group("ai_car")
    if debug:
        for r in route:
            var s = Sprite2D.new()
            s.texture = load("res://icon.svg")
            s.global_position = r - global_position
            add_child(s)


func _process(delta):
    var target = route[_current_target]
    var move_vector = target - _car.global_position
    var target_rotation = rad_to_deg(_car.velocity.angle_to(move_vector))
    if abs(target_rotation) > 85:
        _turning = true
    if _turning:
        if target_rotation < 0:
            _car.turn(-delta)
        elif target_rotation > 0:
            _car.turn(delta)
        else:
            _turning = false
    if move_vector.length_squared() > 100:
        _car.throttle(delta)
    else:
        _current_target = (_current_target + 1) % len(route)

func restart():
    _car.direction = _starting_direction
    _car.position = _starting_position
    if _starting_direction == MODEL.Direction.Up:
        _car.rotation_degrees = -90
    elif _starting_direction == MODEL.Direction.Left:
        _car.rotation_degrees = -180
    elif _starting_direction == MODEL.Direction.Down:
        _car.rotation_degrees = 90
    else:
        _car.rotation_degrees = 0
    _car.body_color = body_color
    _car.max_speed = max_speed
    _car._speed = 0
    _current_target = 0
    _turning = false
