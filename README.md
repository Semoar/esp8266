Code files for my projects involving an ESP8266 and NodeMCU that need a
working wifi connection.

* Split in multiple files
  * config: Global variables for all nodes, updateable via MQTT?
  * init: Connect to wifi and then call lamp code
  * multiple modules for different projects, see below for a description

# Modules

Each module file implements a function to indicate when the next step of the
startup is reached and a function to start.

* lamp: Control the color of WS2812 LEDs (like in a NeoPixel Ring) via MQTT.

# Feature ideas

* Updates over-the-air
  * Either over MQTT (nice for many nodes) or HTTP
  * Checksum / Signature: No asymmteric crypto available, maximum is HMAC
  * At least updatable config
* Configurable via web interface
