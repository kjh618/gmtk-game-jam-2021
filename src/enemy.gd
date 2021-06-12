extends Area2D
class_name Enemy


export var health := 100 setget set_health


func set_health(new_health: int) -> void:
    health = new_health
    $HealthBar.value = health
    if (health < 0):
        queue_free()
