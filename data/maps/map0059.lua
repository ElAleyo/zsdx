local map = ...
-- Dungeon 4 B1

function map:on_started(destination_point)

  -- evil tiles
  map:set_doors_open("evil_tiles_door", true)
  init_evil_tiles()
end

function map:on_hero_on_sensor(sensor_name)

  if sensor_name == "close_door_a_sensor"
      and door_a:is_open() then
    map:close_doors("door_a")
  elseif sensor_name:find("^evil_tiles_sensor") then
    if evil_tiles_door:is_open()
        and not map:enemy_is_dead("evil_tile_1") then
      map:close_doors("evil_tiles_door")
      sol.timer.start(2000, start_evil_tiles)
    end
  elseif sensor_name == "sensor_1" and sensor_1_off:is_enabled() then
    sol.audio.play_sound("switch")
    map:set_entities_enabled("sensor_1_on", true)
    map:set_entities_enabled("sensor_1_off", false)
  elseif sensor_name == "sensor_2" and sensor_2_off:is_enabled() then
    sol.audio.play_sound("switch")
    map:set_entities_enabled("sensor_2_on", true)
    map:set_entities_enabled("sensor_2_off", false)
  elseif sensor_name == "sensor_3" and sensor_3_off:is_enabled() then
    sol.audio.play_sound("switch")
    map:set_entities_enabled("sensor_3_off", false)
  elseif sensor_name == "sensor_4" then
    sol.audio.play_sound("switch")
    map:set_entities_enabled("sensor_4_on", not sensor_4_on:is_enabled())
  elseif sensor_name == "sensor_5" and sensor_2_on:is_enabled() then
    sol.audio.play_sound("switch")
    map:set_entities_enabled("sensor_2_on", false)
  end
end

-- Initializes evil tiles (this function should be called
-- from on_map_started)
function init_evil_tiles()
  map:set_entities_enabled("evil_tile", false)
  map:set_entities_enabled("evil_tile_after", false)
end

-- Starts the attack of evil tiles
-- (this function can be called when the hero enters the room of evil tiles)
function start_evil_tiles()

  local total = map:get_entities_count("evil_tile")
  local next = 1 -- number of the next evil tile to spawn
  local spawn_delay = 1500 -- delay between two tiles

  map:set_entities_enabled("evil_tile", false)
  map:set_entities_enabled("evil_tile_after", false)

  -- spawns a tile and schedules the next one
  function repeat_spawn()

    map:get_entity("evil_tile_"..next):set_enabled(true)
    map:get_entity("evil_tile_after_"..next):set_enabled(true)
    next = next + 1
    if next <= total then
      sol.timer.start(spawn_delay, repeat_spawn)
    end
  end

  -- plays a sound repeatedly as long as at least one tile is moving
  function repeat_sound()

    sol.audio.play_sound("walk_on_grass")

    -- repeat the sound until the last tile starts animation "destroy"
    local again = false
    local remaining = map:get_entities_count("evil_tile")
    if remaining > 1 then
      again = true
    elseif remaining == 1 then
      local sprite = map:enemy_get_sprite("evil_tile_"..total)
      again = sprite:get_animation() ~= "destroy"
    end

    if again then
      sol.timer.start(150, repeat_sound)
    else
      finish_evil_tiles()
    end
  end

  repeat_spawn()
  repeat_sound()
end

function finish_evil_tiles()

  map:open_doors("evil_tiles_door")
end

