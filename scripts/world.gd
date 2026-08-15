extends TileMapLayer
## Процедурная генерация мира + данные для миникарты и спавна сущностей.

const TILE_SIZE := 32
const WORLD_W := 128
const WORLD_H := 128

enum T { DEEP_WATER, SHALLOW_WATER, SAND, GRASS, FOREST, ROCK }

const ATLAS := {
	T.DEEP_WATER: Vector2i(0, 0),
	T.SHALLOW_WATER: Vector2i(1, 0),
	T.SAND: Vector2i(2, 0),
	T.GRASS: Vector2i(3, 0),
	T.FOREST: Vector2i(4, 0),
	T.ROCK: Vector2i(5, 0),
}

const COLORS := {
	T.DEEP_WATER: Color(0.12, 0.30, 0.60),
	T.SHALLOW_WATER: Color(0.27, 0.53, 0.82),
	T.SAND: Color(0.85, 0.79, 0.50),
	T.GRASS: Color(0.36, 0.61, 0.27),
	T.FOREST: Color(0.20, 0.42, 0.18),
	T.ROCK: Color(0.47, 0.45, 0.42),
}

const WATER := [T.DEEP_WATER, T.SHALLOW_WATER]

var _grid: Array = []
var _elevation := FastNoiseLite.new()
var _moisture := FastNoiseLite.new()


func _ready() -> void:
	add_to_group("world")
	tile_set = _make_tile_set()
	_setup_noise()
	_generate()


func _setup_noise() -> void:
	_elevation.seed = 1337
	_elevation.frequency = 0.012
	_elevation.fractal_type = FastNoiseLite.FRACTAL_FBM
	_elevation.fractal_octaves = 5
	_moisture.seed = 7331
	_moisture.frequency = 0.010


func _biome(e: float, m: float) -> int:
	if e < -0.35:
		return T.DEEP_WATER
	if e < -0.12:
		return T.SHALLOW_WATER
	if e < 0.0:
		return T.SAND
	if e > 0.62:
		return T.ROCK
	if m > 0.25:
		return T.FOREST
	return T.GRASS


func _generate() -> void:
	_grid.resize(WORLD_W)
	for x in range(WORLD_W):
		var col: Array = []
		col.resize(WORLD_H)
		for y in range(WORLD_H):
			var e := _elevation.get_noise_2d(float(x), float(y))
			var m := _moisture.get_noise_2d(float(x), float(y))
			var t: int = _biome(e, m)
			col[y] = t
			set_cell(Vector2i(x, y), 0, ATLAS[t])
		_grid[x] = col


func _is_water(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= WORLD_W or cell.y < 0 or cell.y >= WORLD_H:
		return true
	return _grid[cell.x][cell.y] in WATER


func is_water_at(world_pos: Vector2) -> bool:
	return _is_water(local_to_map(world_pos))


func tile_at(world_pos: Vector2) -> int:
	var c := local_to_map(world_pos)
	if c.x < 0 or c.x >= WORLD_W or c.y < 0 or c.y >= WORLD_H:
		return T.DEEP_WATER
	return _grid[c.x][c.y]


func find_spawn() -> Vector2:
	var center := Vector2i(WORLD_W / 2, WORLD_H / 2)
	for r in range(0, 80):
		for x in range(center.x - r, center.x + r + 1):
			for y in range(center.y - r, center.y + r + 1):
				var c := Vector2i(x, y)
				if not _is_water(c):
					return map_to_local(c)
	return map_to_local(center)


func random_land_tile(rng: RandomNumberGenerator) -> Vector2i:
	for _i in range(2000):
		var c := Vector2i(rng.randi_range(0, WORLD_W - 1), rng.randi_range(0, WORLD_H - 1))
		if not _is_water(c) and _grid[c.x][c.y] != T.ROCK:
			return c
	return Vector2i(WORLD_W / 2, WORLD_H / 2)


func random_water_tile(rng: RandomNumberGenerator) -> Vector2i:
	for _i in range(3000):
		var c := Vector2i(rng.randi_range(0, WORLD_W - 1), rng.randi_range(0, WORLD_H - 1))
		if _is_water(c):
			return c
	return Vector2i(WORLD_W / 2, WORLD_H / 2)


func make_minimap_texture() -> ImageTexture:
	var img := Image.create(WORLD_W, WORLD_H, false, Image.FORMAT_RGBA8)
	for x in range(WORLD_W):
		for y in range(WORLD_H):
			img.set_pixel(x, y, COLORS[_grid[x][y]])
	return ImageTexture.create_from_image(img)


func world_pixel_size() -> Vector2:
	return Vector2(WORLD_W * TILE_SIZE, WORLD_H * TILE_SIZE)


func _make_tile_set() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)

	var img := Image.create(TILE_SIZE * 6, TILE_SIZE, false, Image.FORMAT_RGBA8)
	for t in COLORS:
		var a: Vector2i = ATLAS[t]
		img.fill_rect(Rect2i(int(a.x) * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE), COLORS[t])
	var tex := ImageTexture.create_from_image(img)

	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	ts.add_source(src)

	for t in ATLAS:
		var a: Vector2i = ATLAS[t]
		src.create_tile(a)
		if t in WATER:
			var td: TileData = src.get_tile_data(a, 0)
			td.set_collision_polygons_count(0, 1)
			td.set_collision_polygon_points(0, 0, _tile_rect_points())

	return ts


func _tile_rect_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, 0),
		Vector2(TILE_SIZE, 0),
		Vector2(TILE_SIZE, TILE_SIZE),
		Vector2(0, TILE_SIZE),
	])
