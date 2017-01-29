Code files for a shoji lamp respectively the lighting of it.

It consists of WS2812 LEDs in a ring (like NeoPixel Ring) and the color can be
set via MQTT.

* Split in multiple files
  * lamp: MQTT und LEDs
  * config: Global variables for all nodes, updateable via MQTT?
  * init: Connect to wifi and then call lamp code

# Feature ideas

* Updates over-the-air
  * Either over MQTT (nice for many nodes) or HTTP
  * Checksum / Signature: No asymmteric crypto available, maximum is HMAC
  * At least updatable config
* Configurable via web interface
