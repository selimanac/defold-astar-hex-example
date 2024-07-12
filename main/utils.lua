local camera          = require "orthographic.camera"
local hexagon         = require("hexagon.hexagon") -- -> https://github.com/selimanac/defold-hexagon

local utils           = {}

local CAMERA_ID       = hash("/camera")
local hex_size        = { w = 65, h = 89 }
local hex_map         = {}
local cursor_position = vmath.vector3(0, 0, 0)
local world_position  = vmath.vector3()

-- Since the hex sprite image is not a perfect hexagon, we have to manually add the correct size and offset.
-- See: https://www.redblobgames.com/grids/hexagons/#basics
local layout          = hexagon.Layout(hexagon.layout_pointy, hexagon.Point(37.5, 35), hexagon.Point(0, 14))

local layout_type     = hexagon.ODD
local hex_point       = hexagon.Point()
local hex             = hexagon.Hex(0, 0, 0)
local hex_coord       = hexagon.OffsetCoord()
local map_width       = 0
local map_height      = 0
local path_start      = { x = 0, y = 0 }
local factories       = {
	hex_url  = msg.url('hex', '/factories', 'hex'),
	hero_url = msg.url('hex', '/factories', 'hero'),
	item_url = msg.url('hex', '/factories', 'item')
}

local function camera_screen_to_hex(screen)
	world_position = camera.screen_to_world(CAMERA_ID, screen)
	hex_point = hexagon.Point(world_position.x, world_position.y)
	hex = hexagon.hex_round(hexagon.pixel_to_hex(layout, hex_point))
	hex_coord = hexagon.roffset_from_cube(layout_type, hex)
	hex_coord.col = hex_coord.col + 1
	hex_coord.row = hex_coord.row + 1
	return hex_coord
end

function utils.generate_map(world, map_type, _map_width, _map_height)
	map_width             = _map_width
	map_height            = _map_height

	local item_z          = 0.01
	local offset          = { x = 0, y = 36 }
	local tile_count      = 1
	local tile_type       = 0
	local posX            = 0
	local posY            = 0
	local hero_position   = vmath.vector3(0, 0, 1)
	local target_position = vmath.vector3(0, 0, 1)
	local target_id       = hash('')

	if map_type == astar.HEX_EVENR then
		layout_type = hexagon.EVEN
	end

	for y = 0, map_height - 1 do
		hex_map[y + 1] = {}

		if map_type == astar.HEX_ODDR then
			offset.x = y % 2 == 0 and 0 or hex_size.w / 2
		elseif map_type == astar.HEX_EVENR then
			offset.x = y % 2 == 0 and 0 or -(hex_size.w / 2)
		end

		for x = 0, map_width - 1 do
			posX                  = x * hex_size.w + offset.x
			posY                  = y * hex_size.h - (offset.y * y)
			tile_type             = world[tile_count]

			local hex_position    = vmath.vector3(posX, posY, item_z)
			local hex_id          = factory.create(factories.hex_url, hex_position)
			local hex_label       = msg.url('hex', hex_id, 'label')
			local hex_sprite      = msg.url('hex', hex_id, 'sprite')
			local hex_tile_sprite = msg.url('hex', hex_id, 'tile')

			hex_map[y + 1][x + 1] = {
				tile_type = tile_type,
				position = hex_position,
				hex_id = hex_id,
				hex_sprite = hex_sprite,
				hex_tile_sprite = hex_tile_sprite,
				x = x + 1,
				y = y + 1
			}

			if tile_type == 1 then
				sprite.play_flipbook(hex_sprite, hash('tileStone'))
				sprite.play_flipbook(hex_tile_sprite, hash('tileStone_tile'))
				factory.create(factories.item_url, hex_position)
			elseif tile_type == 3 then
				sprite.play_flipbook(hex_sprite, hash('tileWater_full'))
				sprite.play_flipbook(hex_tile_sprite, hash('tileWater_tile'))
			elseif tile_type == 2 then
				path_start.x = x + 1
				path_start.y = y + 1
				hero_position.x = hex_position.x
				hero_position.y = hex_position.y
				factory.create(factories.hero_url, hero_position)
			elseif tile_type == 4 then
				target_position.x = hex_position.x
				target_position.y = hex_position.y
				target_id = factory.create(factories.hero_url, target_position)
				local target_sprite = msg.url('hex', target_id, 'sprite')
				sprite.play_flipbook(target_sprite, hash('alienYellow'))
			elseif tile_type == 5 then
				sprite.play_flipbook(hex_sprite, hash('tileAutumn'))
				sprite.play_flipbook(hex_tile_sprite, hash('tileAutumn_tile'))
				local item_id = factory.create(factories.item_url, hex_position)
				local item_sprite_url = msg.url(nil, item_id, 'sprite')
				sprite.play_flipbook(item_sprite_url, hash('rockStone_moss2'))
			end

			label.set_text(hex_label, x + 1 .. ' - ' .. y + 1)

			tile_count = tile_count + 1
		end
		item_z = item_z - 0.001
	end

	collectgarbage('collect')
end

function utils.get_path_start()
	return path_start
end

function utils.get_hex(tile_x, tile_y)
	if tile_x >= 1 and tile_x <= map_width and tile_y >= 1 and tile_y <= map_height then
		return hex_map[tile_y][tile_x]
	end
	return nil
end

function utils.coords_to_index(x, y)
	return x * hex_size.w + y + 1
end

function utils.input(action)
	cursor_position.x = action.x
	cursor_position.y = action.y
	local current_hex = camera_screen_to_hex(cursor_position)
	return utils.get_hex(current_hex.col, current_hex.row)
end

return utils
