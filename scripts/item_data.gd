extends RefCounted
## Общие данные предметов: названия и цвета для ячеек.

const NAMES := {
	"wood": "Дерево", "meat": "Мясо", "fish": "Рыба", "stone": "Камень",
	"axe": "Топор", "sword": "Меч", "bow": "Лук", "crossbow": "Арб", "rod": "Удочка", "pickaxe": "Кирка",
	"stone_axe": "К.топор", "stone_sword": "К.меч", "stone_bow": "К.лук",
	"stone_crossbow": "К.арб", "stone_rod": "К.удочка", "stone_pickaxe": "К.кирка",
	"workbench": "Верстак",
}

const COLORS := {
	"wood": Color(0.50, 0.34, 0.18), "meat": Color(0.85, 0.25, 0.25),
	"fish": Color(0.30, 0.60, 0.90), "stone": Color(0.55, 0.55, 0.58),
	"axe": Color(0.50, 0.50, 0.52), "sword": Color(0.82, 0.82, 0.88),
	"bow": Color(0.32, 0.60, 0.32), "crossbow": Color(0.30, 0.30, 0.35),
	"rod": Color(0.72, 0.60, 0.40), "pickaxe": Color(0.55, 0.45, 0.35),
	"stone_axe": Color(0.45, 0.45, 0.48), "stone_sword": Color(0.60, 0.60, 0.65),
	"stone_bow": Color(0.40, 0.50, 0.40), "stone_crossbow": Color(0.35, 0.35, 0.40),
	"stone_rod": Color(0.60, 0.55, 0.45), "stone_pickaxe": Color(0.50, 0.45, 0.40),
	"workbench": Color(0.55, 0.40, 0.25),
}
