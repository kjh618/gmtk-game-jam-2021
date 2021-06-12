extends Node2D


enum ActionType { NOT_SET, MOVE, SKILL }

const TILE_MAP_SCALE := 2
const TILE_SIZE := 32 * TILE_MAP_SCALE

export var width := 8
export var height := 8

var selected_player: Player = null
var action_type: int = ActionType.NOT_SET


func _input(event: InputEvent) -> void:
    if event.is_action_released("select"):
        var clicked_board_position: Vector2 = to_board_position(event.position)
        if !is_in_board(clicked_board_position):
            return

        print("Board clicked: ", clicked_board_position)

        var player := get_player(clicked_board_position)
        if player != null:
            select_player(player)
        elif selected_player != null and action_type != ActionType.NOT_SET:
            match action_type:
                ActionType.MOVE:
                    if selected_player.try_move_to(clicked_board_position) == true:
                        select_player(null)
                        action_type = ActionType.NOT_SET
                ActionType.SKILL:
                    if selected_player.try_do_action(clicked_board_position) == true:
                        select_player(null)
                        action_type = ActionType.NOT_SET

    elif event.is_action_pressed("move"):
        if selected_player != null:
            action_type = ActionType.MOVE

    elif event.is_action_pressed("skill"):
        if selected_player != null:
            action_type = ActionType.SKILL


func to_board_position(position: Vector2) -> Vector2:
    return ($TileMap.world_to_map(position) / TILE_MAP_SCALE).floor()


func to_local_position(board_position: Vector2) -> Vector2:
    return $TileMap.map_to_world(board_position) * TILE_MAP_SCALE + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)


func is_in_board(board_position: Vector2) -> bool:
    return 0 <= board_position.x and board_position.x < width and \
            0 <= board_position.y and board_position.y < height


func get_player(board_position: Vector2) -> Player:
    for c in get_children():
        if c is Player and to_board_position(c.position) == board_position:
            return c
    return null


func get_action_type(board_position: Vector2) -> int:
    var index: int = $SkillsTileMap.get_cellv(board_position)
    return 0 if index == TileMap.INVALID_CELL else index


func get_enemy(board_position: Vector2) -> Enemy:
    for c in get_children():
        if c is Enemy and to_board_position(c.position) == board_position:
            return c
    return null


func get_enemies_in_square(board_position: Vector2, square_radius: int) -> Array:
    var enemies := []
    for c in get_children():
        if c is Enemy and Helper.is_in_square(to_board_position(c.position) - board_position, square_radius):
            enemies.append(c)
    return enemies


func select_player(player: Player) -> void:
    if selected_player != null:
        selected_player.state = Player.State.IDLE
    selected_player = player
    if selected_player != null:
        selected_player.state = Player.State.SELECTED
