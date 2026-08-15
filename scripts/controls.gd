extends Node
## Глобальное состояние управления (мост между UI и игроком).

var move_vector := Vector2.ZERO  # джойстик (в(side-view) используется ось X)
var jump_queued := false         # одиночный флаг: нажата кнопка прыжка
var attack_queued := false       # одиночный флаг: нажата кнопка удара/копания
