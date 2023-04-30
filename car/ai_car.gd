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

func _ready():
    _car.direction = direction
    if direction == MODEL.Direction.Up:
        _car.rotation_degrees = -90
    elif direction == MODEL.Direction.Left:
        _car.rotation_degrees = -180
    elif direction == MODEL.Direction.Down:
        _car.rotation_degrees = 90
    _car.body_color = body_color
    _car.max_speed = max_speed
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
