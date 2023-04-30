extends Panel
class_name ScorePanel

@onready var _rating_label: Label = get_node("VBoxContainer/HBoxContainer/rating_label")
@onready var _rating_bar: TextureProgressBar = get_node("VBoxContainer/HBoxContainer/rating_bar")
@onready var _salary_label: Label = get_node("VBoxContainer/HBoxContainer2/salary_label")

var _is_game_running: bool = false

func _ready():
    var map = get_tree().current_scene as MapScene
    _is_game_running = map._is_game_running
    map.game_state_changed.connect(_on_game_state_changed)
    
func _process(delta):
    visible = _is_game_running

func _on_game_state_changed(is_running: bool):
    _is_game_running = is_running

func update_rating(rating: float):
    _rating_label.text = "%.1f" % rating
    _rating_bar.value = round(rating * 2)

func update_salary(salary: float):
    _salary_label.text = "$%.02f" % salary
