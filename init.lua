-- Config variables
SSID = ""
PASSWORD = "****"
MQTT_SERVER = ""
MQTT_PORT = 1883

-- Initialize LEDs
-- Note: Strangely ws2812 uses green-red-blue
START_COLOR = string.char(0, 128, 0)
ws2812.init()
buffer = ws2812.newBuffer(12, 3)

-- Indicate current step of startup
-- One LED lights up in startcolor after each of:
--   * Power on
--   * Connecting to wifi
--   * Connecting to MQTT server
--   * Subsribing to topic
function indicateNextStep()
    buffer:shift(1)
    buffer:set(1, startcolor)
    ws2812.write(buffer)
end

-- MQTT
-- Here without username and password: lamp is not security critical and only
-- accessible inside my LAN.
m = mqtt.Client("shoji-lamp", 120)

-- Functions are called in the following order.
-- First connect to wifi
function connectWifi()
    -- Turn on first LED
    indicateNextStep()

    wifi.setmode(wifi.STATION)
    station_cfg={}
    station_cfg.ssid=SSID
    station_cfg.pwd=PASSWORD
    station_cfg.save=true
    wifi.sta.config(station_cfg)
end

-- Connect to MQTT server after we got an IP
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    -- Turn on second LED
    print("Connected to WiFi")
    indicateNextStep()
    wifi.sta.eventMonStop(1)
    -- Start MQTT
    m:connect(MQTT_SERVER, MQTT_PORT, 0, function(client) subscribeTopic() end,
                                         function(client, reason) print("failed reason: "..reason) end)
end)

-- Subscribe after we connected to MQTT server
--m:on("connect", function(client)
function subscribeTopic()
    print ("Connected to server")
    indicateNextStep()

    m:subscribe("/shoji-lamp/light", 0, function(client)
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


-- Start up
connectWifi()
