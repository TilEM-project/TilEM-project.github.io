---
layout: page
title: UI Server
type: task
receives:
    - tile.jpeg
    - tile.minimap
    - tile.statistics.histogram
---

The UI Server is a service which provides a web based user interface for the microscope.
It primarily serves HTML and JavaScript files to the client.
Additionally, the downsampled JPEG tiles and minimap recieved on the [`tile.jpeg`](/topics.html#tile-jpeg) and [`tile.minimap`](/topics.html#tile-minimap) topics are sent to the [client](/ui.html) via a websocket.

The JavaScript code running in the client's browser is written using [Vue.js](https://vuejs.org/) and uses [STOMP.js](https://github.com/stomp-js/stompjs) to communicate with the [message broker](/broker.html).
Further documentation on the UI is available [here](/ui.html).