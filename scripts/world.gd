extends TileMapLayer
## Мир-срез (вид сбоку, как в Terraria): небо, трава, земля, камень, руда, пещеры.
## Твёрдые тайлы имеют коллайдер; их можно копать. Seed задаётся снаружи (generate).

const TILE_SIZE := 16
const WORLD_W := 256
const WORLD_H := 128

enum ST { AIR, GRASS, DIRT, STONE, ORE }

const ATLAS := {
	ST.GRASS: Vector2i(0, 0),
	ST.DIRT: Vector2i(1, 0),
	ST.STONE: Vector2i(2, 0),
	ST.ORE: Vector2i(3, 0),
}

const COLORS := {
	ST.GRASS: Color(0.36, 0.61, 0.27),
	ST.DIRT: Color(0.45, 0.30, 0.18),
	ST.STONE: Color(0.47, 0.45, 0.42),
	ST.ORE: Color(0.32, 0.58, 0.62),
}

const SOLID := [ST.GRASS, ST.DIRT, ST.STONE, ST.ORE]

var _grid: Array = []
var _surface := FastNoiseLite.new()
var _cave := FastNoiseLite.new()
var _ore := FastNoiseLite.new()


func _ready() -> void:
	add_to_group("world")
	tile_set = _make_tile_set()


func generate(seed: int) -> void:
	_surface.seed = seed
	_surface.frequency = 0.05
	_cave.seed = seed + 1
	_cave.frequency = 0.10
	_ore.seed = seed + 2
	_ore.frequency = 0.18
	_generate()


func _generate() -> void:
	_grid.resize(WORLD_W)
	var base := int(WORLD_H * 0.4)
	for x in range(WORLD_W):
		var col: Array = []
		col.resize(WORLD_H)
		var surf := clampi(base + int(_surface.get_noise_1d(float(x)) * 18), 4, WORLD_H - 20)
		for y in range(WORLD_H):
			var t := ST.AIR
			if y == surf:
				t = ST.GRASS
			elif y > surf and y < surf + 6:
				t = ST.DIRT
			elif y >= surf + 6:
				t = ST.STONE
			if t == ST.DIRT or t == ST.STONE:
				if _cave.get_noise_2d(float(x), float(y)) > 0.5:
					t = ST.AIR
			if t == ST.STONE and _ore.get_noise_2d(float(x), float(y)) > 0.62:
				t = ST.ORE
			col[y] = t
			if t != ST.AIR:
				set_cell(Vector2i(x, y), 0, ATLAS[t])
		_grid[x] = col


func _in_bounds(c: Vector2i) -> bool:
	return c.x >= 0 and c.x < WORLD_W and c.y >= 0 and c.y < WORLD_H


func is_solid_cell(c: Vector2i) -> bool:
	if not _in_bounds(c):
		return false
	return _grid[c.x][c.y] in SOLID


# Копает тайл, возвращает id ресурса ("stone" или "").
func mine_cell(c: Vector2i) -> String:
	if not _in_bounds(c):
		return ""
	var t: int = _grid[c.x][c.y]
	if t == ST.AIR:
		return ""
	_grid[c.x][c.y] = ST.AIR
	set_cell(c, -1)
	if t == ST.STONE or t == ST.ORE:
		return "stone"
	return ""


func find_spawn() -> Vector2:
	var cx := WORLD_W / 2
	for x in range(cx - 30, cx + 30):
		if x < 0 or x >= WORLD_W:
			continue
		for y in range(WORLD_H):
			if _grid[x][y] == ST.GRASS:
				return map_to_local(Vector2i(x, y)) - Vector2(0, 26)
	return map_to_local(Vector2i(cx, 4))


func random_grass_tile(rng: RandomNumberGenerator) -> Vector2i:
	for _i in range(3000):
		var c := Vector2i(rng.randi_range(0, WORLD_W - 1), rng.randi_range(0, WORLD_H - 1))
		if _in_bounds(c) and _grid[c.x][c.y] == ST.GRASS:
			return c
	return Vector2i(WORLD_W / 2, 0)


func _make_tile_set() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)

	var img := Image.create(TILE_SIZE * 4, TILE_SIZE, false, Image.FORMAT_RGBA8)
	for t in COLORS:
		var a: Vector2i = ATLAS[t]
		img.fill_rect(Rect2i(int(a.x) * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE), COLORS[t])
	var tex := ImageTexture.create_from_image(img)

	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	ts.add_source(src)

	var pts := PackedVector2Array([
		Vector2(0, 0), Vector2(TILE_SIZE, 0),
		Vector2(TILE_SIZE, TILE_SIZE), Vector2(0, TILE_SIZE)])
	for t in ATLAS:
		var a: Vector2i = ATLAS[t]
		src.create_tile(a)
		var td: TileData = src.get_tile_data(a, 0)
		td.set_collision_polygons_count(0, 1)
		td.set_collision_polygon_points(0, 0, pts)

	return ts
