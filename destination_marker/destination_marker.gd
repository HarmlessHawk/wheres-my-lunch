extends Sprite2D


func _ready():
    var tween = create_tween()
    tween.tween_property(self, "position", to_global(Vector2(0, -4)), 0.5)
    tween.tween_property(self, "position", to_global(Vector2(0, 0)), 0.5)
    tween.set_loops()

