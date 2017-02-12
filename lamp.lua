local module = {}

-- Specific config
local clientname = "shoji-lamp"
local topic = "/shoji-lamp/light"
-- Note: Strangely ws2812 uses green-red-blue
local startcolor = string.char(0, 128, 0)

-- Initialize LEDs
ws2812.init()
local buffer = ws2812.newBuffer(12, 3)

-- Indicate current step of startup
-- One LED lights up in startcolor after each of:
--   * Power on
--   * Connecting to wifi
--   * Connecting to MQTT server
--   * Subsribing to topic
function module.indicateNextStep()
    buffer:shift(1)
    buffer:set(1, startcolor)
    ws2812.write(buffer)
end

function module.start()
    connectMQTT()
end

-- MQTT
-- Here without username and password: lamp is not security critical and only
-- accessible inside my LAN.
local m = mqtt.Client(clientname, 120)

-- Connect to MQTT server after we got an IP
local function connectMQTT()
    print("Trying to connect MQTT...")
    m:connect(MQTT_SERVER, MQTT_PORT, 0, function(client) subscribeTopic() end,
                                         function(client, reason) print("failed for reason: "..reason) end)
end

-- Subscribe after we connected to MQTT server
--m:on("connect", function(client)
local function subscribeTopic()
    print ("Connected to MQTT server")
    indicateNextStep()

    m:subscribe(topic, 0, function(client)
        print("Subscribed successfully")
        indicateNextStep()
    end)
end

-- Handle incoming message and set received color to all LEDs
m:on("message", function(client, topic, data)
    print(topic .. ":" .. data)
    local r = 0
    local g = 0
    local b = 0
    -- The message could be...
    if string.sub(data, 1, 1) == "#" then
        -- ...a hex value
        r = tonumber(string.sub(data, 2, 3), 16)
        g = tonumber(string.sub(data, 4, 5), 16)
        b = tonumber(string.sub(data, 6, 7), 16)
    elseif tonumber(data) then
        -- ...a numeric value
        x = tonumber(data)
        b = x % 256
        x = x / 256
        g = x % 256
        x = x / 256
        r = x % 256
    elseif string.len(data) == 3 then
        -- ... or binary encoding
        r = string.byte(data, 1)
        g = string.byte(data, 2)
        b = string.byte(data, 3)
    else
        print("Unknown message format")
    end
    if not r then r = 0 end
    if not g then g = 0 end
    if not b then b = 0 end
    print("parsed to " .. r .. ", " .. g .. ", " ..b)
    buffer:fill(g, r, b)
    ws2812.write(buffer)
end)

return module
