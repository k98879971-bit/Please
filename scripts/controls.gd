extends Node
## Глобальное состояние управления (мост между UI-виджетами и игроком).

var move_vector := Vector2.ZERO  # направление джойстика, длина 0..1
var sprint := false              # удержана кнопка бега
var attack_queued := false       # одиночный флаг: нажата кнопка удара
