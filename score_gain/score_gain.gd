extends Node2D
class_name ScoreGain

const _MOVE_SPEED = 1200

var salary: float = 0
var rating: int = 0


func _ready():
    (get_node("rating_label") as Label).text = str(rating)
    (get_node("salary_label") as Label).text = "$%.02f" % salary
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.6)
    tween.tween_callback(queue_free)

func _process(delta):
    translate(Vector2.UP * _MOVE_SPEED * delta)
