extends CanvasLayer
class_name GameOverOverlay

signal back_to_menu
signal retry

@onready var final_salary_label: Label = get_node("Panel/final_salary_label")

var final_salary: float = 0

func _ready():
    add_to_group("game_over_overlay")
    final_salary_label.text = "Total Salary: $%.02f" % final_salary


func _process(delta):
    if Input.is_action_just_pressed("back"):
        back_to_menu.emit()
    elif Input.is_action_just_pressed("retry"):
        retry.emit()
