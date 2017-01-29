-- Config variables
require("config")
-- Load lamp and MQTT
require("lamp")

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
    connectMQTT()
end)

-- Start up
connectWifi()
