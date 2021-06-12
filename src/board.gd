extends Node2D


enum ActionType { NOT_SET, MOVE, SKILL }


export var width := 8
export var height := 8

var selected_player: Player = null
var action_type: int = ActionType.NOT_SET


func _input(event: InputEvent) -> void:
    if event.is_action_released("select"):
        var clicked_board_position: Vector2 = to_board_position(to_local(event.position))
        if !is_in_board(clicked_board_position):
            return
        print("Board clicked: ", clicked_board_position)

        var player := get_player(clicked_board_position)
        if player != null:
            select_player(player)
        elif selected_player != null and action_type != ActionType.NOT_SET:
            match action_type:
                ActionType.MOVE:
                    if selected_player.try_move(clicked_board_position) == true:
                        select_player(null)
                        action_type = ActionType.NOT_SET
                ActionType.SKILL:
                    if selected_player.try_do_action(clicked_board_position) == true:
                        select_player(null)
                        action_type = ActionType.NOT_SET

    elif event.is_action_pressed("move"):
        if selected_player != null:
            action_type = ActionType.MOVE
            $OverlayTileMap.clear()
            selected_player.show_move_overlay()

    elif event.is_action_pressed("skill"):
        if selected_player != null:
            action_type = ActionType.SKILL
            $OverlayTileMap.clear()
            selected_player.show_overlay()


func to_board_position(position: Vector2) -> Vector2:
    return $TileMap.world_to_map(position)


func to_local_position(board_position: Vector2) -> Vector2:
    return $TileMap.map_to_world(board_position) + Vector2(0, 32)


func is_in_board(board_position: Vector2) -> bool:
    return 0 <= board_position.x and board_position.x < width and \
            0 <= board_position.y and board_position.y < height


func is_in_square(board_position: Vector2, square_center: Vector2, square_radius: int) -> bool:
    var center_to_position := board_position - square_center
    return abs(center_to_position.x) <= square_radius and abs(center_to_position.y) <= square_radius


func get_action_type(board_position: Vector2) -> int:
    var index: int = $SkillsTileMap.get_cellv(board_position)
    return 0 if index == TileMap.INVALID_CELL else index


func get_player(board_position: Vector2) -> Player:
    for c in get_children():
        if c is Player and to_board_position(c.position) == board_position:
            return c
    return null


func get_enemy(board_position: Vector2) -> Enemy:
    for c in get_children():
        if c is Enemy and to_board_position(c.position) == board_position:
            return c
    return null


func get_enemies_in_square(square_center: Vector2, square_radius: int) -> Array:
    var enemies := []
    for c in get_children():
        if c is Enemy and is_in_square(to_board_position(c.position), square_center, square_radius):
            enemies.append(c)
    return enemies


func set_overlay(board_position: Vector2, overlay: int):
    $OverlayTileMap.set_cellv(board_position, overlay)


func set_overlay_in_square(square_center: Vector2, square_radius: int, overlay: int):
    for x in range(-square_radius, square_radius + 1):
        for y in range(-square_radius, square_radius + 1):
            var v := Vector2(x, y)
            if v == Vector2.ZERO or !is_in_board(square_center + v):
                continue
            set_overlay(square_center + v, overlay)


func select_player(player: Player) -> void:
    if selected_player != null:
        selected_player.state = Player.State.IDLE
    selected_player = player
    if selected_player != null:
        selected_player.state = Player.State.SELECTED
    $OverlayTileMap.clear()
