--[[
    Snowboard Kids Item-Mapper (BizHawk 2.10)
    - Keine Event-Handler-Fehler
    - Robuste Positionskontrolle
--]]

local NEXT_ITEM_ADDR = 0x122298
--local PLAYER_POS_ADDR = 0x122289
local CURRENT_ITEM_ADDR = 0x122295 -- 0x122292 for Red Items | 0x122295 for blue items
local FRAMES_NEEDED = 35
local MEM_DOMAIN = "RDRAM"

-- local positions = {0x00, 0x01, 0x02, 0x03}  -- Plätze 1-4

local function mem_write(addr, val)
    memory.write_u8(addr, val, MEM_DOMAIN)
end

local function mem_read(addr)
    return memory.read_u8(addr, MEM_DOMAIN)
end

local function test_combination(next_item)--(pos, next_item)
    -- Save State laden und stabilisieren
    savestate.loadslot(1)
    for _ = 1, 3 do emu.frameadvance() end
    
    -- Werte setzen
    mem_write(NEXT_ITEM_ADDR, next_item)
    
    -- Position jedes Frame MANUELL setzen (ohne Event-Handler)
    for _ = 1, FRAMES_NEEDED do
    --    mem_write(PLAYER_POS_ADDR, pos)
        emu.frameadvance()
    end
    
    -- Ergebnis auslesen
    local item = mem_read(CURRENT_ITEM_ADDR)
    console.log(string.format(
        "Next_value: %03d → Item: 0x%02X",
        next_item, item
    ))
    
    return item
end

-- Hauptlogik mit Fehlerabfang
local results = {}
--for _, pos in ipairs(positions) do
    --console.log(string.format("Starte Position 0x%02X...", pos))
    
    for item_dec = 0, 255 do
        local success, item = pcall(test_combination, item_dec)
        if success then
            table.insert(results, {
                NextItem = item_dec,
                Item = item
            })
        end
    end
--end

-- CSV-Export
local file = io.open("item_map_blue_4th.csv", "w")
file:write("NextItem_Dec;Item_Hex\n")
for _, entry in ipairs(results) do
    file:write(string.format(
        "0x%02X\n",
        entry.Item
    ))
end
file:close()

console.log("Mapping erfolgreich! Datei: item_map_blue_4th.csv")
