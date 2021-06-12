class_name Helper

static func is_in_square(vector: Vector2, square_radius: int) -> bool:
    return abs(vector.x) <= square_radius and abs(vector.y) <= square_radius
