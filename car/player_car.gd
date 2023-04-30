extends Node2D

const _MAX_SPEED = 1000
const _THROTTLE_FORCE = 1250000
const _TURN_TORQUE = 10000


@onready var _car: Car = get_node("Car")

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_pressed("turn_left"):
        _car.turn(-delta)
    if Input.is_action_pressed("turn_right"):
        _car.turn(delta)
    if Input.is_action_pressed("throttle"):
        _car.throttle(delta)
    if Input.is_action_pressed("brake"):
        _car.throttle(-delta)

func _input(event):
    if event is InputEventMouse && event.is_pressed() && !event.is_echo():
        print(to_global(event.position))
