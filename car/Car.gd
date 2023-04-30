extends CharacterBody2D
class_name Car

const _THROTTLE = 1000
const _MAX_SPEED = 1500
const _TURN_SPEED = 180
const _AUTO_BRAKE = 500

const MODEL = preload("res://car/model.gd")

@export var direction: MODEL.Direction = MODEL.Direction.Right
@export var body_color: MODEL.BodyColor = MODEL.BodyColor.Green
@export var max_speed: int = _MAX_SPEED

@onready var _sprite: Sprite2D = get_node("sprite")
@onready var _right_bounds: CollisionShape2D = get_node("right")
@onready var _up_bounds: CollisionShape2D = get_node("up")
@onready var _left_bounds: CollisionShape2D = get_node("left")
@onready var _down_bounds: CollisionShape2D = get_node("down")

var _prev_dir: MODEL.Direction = MODEL.Direction.Right
var _prev_color: MODEL.BodyColor = MODEL.BodyColor.Green
var _speed: float = 0
var _throttling: bool = false
var _is_game_running: bool = false

var _textures: Array[Texture] = [
    preload("res://car/sprites/green_up.png"),
    preload("res://car/sprites/green_right.png"),
    preload("res://car/sprites/green_down.png"),
    preload("res://car/sprites/green_left.png"),
    preload("res://car/sprites/grey_up.png"),
    preload("res://car/sprites/grey_right.png"),
    preload("res://car/sprites/grey_down.png"),
    preload("res://car/sprites/grey_left.png"),
    preload("res://car/sprites/orange_up.png"),
    preload("res://car/sprites/orange_right.png"),
    preload("res://car/sprites/orange_down.png"),
    preload("res://car/sprites/orange_left.png"),
]

func _ready():
    var map = get_tree().current_scene as MapScene
    _is_game_running = map._is_game_running
    map.game_state_changed.connect(_on_game_state_changed)


func _process(delta):
    if !_is_game_running:
        _update_texture()
        return
        
    var dir = Vector2(cos(rotation), sin(rotation)).normalized()
    if !_throttling:
        _speed = max(0, _speed - _AUTO_BRAKE * delta)
    velocity = dir * _speed
    _throttling = false
    move_and_slide()
    if (rotation_degrees >= 0 && rotation_degrees < 45) || (rotation_degrees < 0 && rotation_degrees > -45):
        direction = MODEL.Direction.Right
    elif rotation_degrees <= -45 && rotation_degrees > -135:
        direction = MODEL.Direction.Up
    elif rotation_degrees >= 45 && rotation_degrees < 135:
        direction = MODEL.Direction.Down
    else:
        direction = MODEL.Direction.Left
    _update_texture()
        
func _update_texture():
    if _prev_dir != direction || _prev_color != body_color:
        _sprite.texture = _get_texture()
        _down_bounds.disabled = direction != MODEL.Direction.Down
        _left_bounds.disabled = direction != MODEL.Direction.Left
        _up_bounds.disabled = direction != MODEL.Direction.Up
        _right_bounds.disabled = direction != MODEL.Direction.Right
        _prev_dir = direction
        _prev_color = body_color
        
func throttle(delta: float):
    if !_is_game_running:
        return
    _speed = clamp(_speed + _THROTTLE * delta, 0, max_speed)
    _throttling = true
    
func turn(delta: float):
    if !_is_game_running:
        return
    rotation_degrees += (_TURN_SPEED * (_speed / max_speed)) * delta

func _get_texture() -> Texture:
    var index: int
    if body_color == MODEL.BodyColor.Green:
        index = 0
    elif body_color == MODEL.BodyColor.Grey:
        index = 4
    elif body_color == MODEL.BodyColor.Orange:
        index = 8
    if direction == MODEL.Direction.Up:
        index += 0
    elif direction == MODEL.Direction.Right:
        index += 1
    elif direction == MODEL.Direction.Down:
        index += 2
    elif direction == MODEL.Direction.Left:
        index += 3
    return _textures[index]
    
func _on_game_state_changed(is_running: bool):
    _is_game_running = is_running
