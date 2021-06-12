extends Node2D


enum ActionType { NOT_SET, MOVE, SKILL }

enum Turn { PLAYER, ENEMY }


export var width := 8
export var height := 8

var selected_player: Player = null
var action_type: int = ActionType.NOT_SET
var turn: int = Turn.PLAYER


func _input(event: InputEvent) -> void:
    if turn == Turn.ENEMY:
        return

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
                    if selected_player.try_do_action(
                            Player.ActionType.MOVE,
                            clicked_board_position) == true:
                        selected_player.state = Player.State.ACTION_DONE
                        select_player(null)
                ActionType.SKILL:
                    if selected_player.try_do_action(
                            get_selected_player_action_type(),
                            clicked_board_position) == true:
                        selected_player.state = Player.State.ACTION_DONE
                        select_player(null)

    elif event.is_action_pressed("move"):
        if selected_player != null:
            action_type = ActionType.MOVE
            $OverlayTileMap.clear()
            selected_player.show_overlay(Player.ActionType.MOVE)

    elif event.is_action_pressed("skill"):
        if selected_player != null:
            action_type = ActionType.SKILL
            $OverlayTileMap.clear()
            selected_player.show_overlay(get_selected_player_action_type())
    
    elif event.is_action_pressed("end_turn"):
        select_player(null)
        turn = Turn.ENEMY
        $Enemies.do_turn()


func to_board_position(position: Vector2) -> Vector2:
    return $TileMap.world_to_map(position)


func to_local_position(board_position: Vector2) -> Vector2:
    return $TileMap.map_to_world(board_position) + Vector2(0, 32)


func is_in_board(board_position: Vector2) -> bool:
    return 0 <= board_position.x and board_position.x < width \
            and 0 <= board_position.y and board_position.y < height


func is_in_square(board_position: Vector2, square_center: Vector2, square_radius: int) -> bool:
    var center_to_position := board_position - square_center
    return abs(center_to_position.x) <= square_radius and abs(center_to_position.y) <= square_radius


func is_available(board_position: Vector2) -> bool:
    return get_player(board_position) == null and get_enemy(board_position) == null


func get_selected_player_action_type() -> int:
    var index: int = $SkillsTileMap.get_cellv(to_board_position(selected_player.position))
    return Player.ActionType.MOVE if index == TileMap.INVALID_CELL else index


func get_player(board_position: Vector2) -> Player:
    for player in $Players.get_children():
        if to_board_position(player.position) == board_position:
            return player
    return null


func get_enemy(board_position: Vector2) -> Enemy:
    for enemy in $Enemies.get_children():
        if to_board_position(enemy.position) == board_position:
            return enemy
    return null


func get_enemies_in_square(square_center: Vector2, square_radius: int) -> Array:
    var enemies := []
    for enemy in get_children():
        if is_in_square(to_board_position(enemy.position), square_center, square_radius):
            enemies.append(enemy)
    return enemies


func set_overlay(board_position: Vector2, overlay: int):
    $OverlayTileMap.set_cellv(board_position, overlay)


func set_overlay_in_square(
        square_center: Vector2, square_radius: int,
        overlay: int,
        only_set_available: bool = false):
    for x in range(-square_radius, square_radius + 1):
        for y in range(-square_radius, square_radius + 1):
            var v := Vector2(x, y)
            if v == Vector2.ZERO or !is_in_board(square_center + v):
                continue
            if only_set_available and !is_available(square_center + v):
                continue
            set_overlay(square_center + v, overlay)


func select_player(player: Player) -> void:
    if player != null and player.state == Player.State.ACTION_DONE:
        return

    if selected_player != null and selected_player.state == Player.State.SELECTED:
        selected_player.state = Player.State.IDLE
    selected_player = player
    if selected_player != null:
        selected_player.state = Player.State.SELECTED

    action_type = ActionType.NOT_SET
    $OverlayTileMap.clear()


func start_player_turn() -> void:
    for player in $Players.get_children():
        player.state = Player.State.IDLE
    turn = Turn.PLAYER
