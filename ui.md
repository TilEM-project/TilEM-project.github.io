---
layout: page
title: User Interface
type: task
receives:
    - camera.status
    - stage.aperture.status
    - stage.rotation.status
    - stage.motion.status
    - tile.statistics.min_max_mean
    - tile.statistics.focus
    - buffer.status
    - scope.status
sends:
    - ui.setup
    - ui.edit
    - ui.run
---

The microscope user interface is a webpage available from the [UI server](/ui_server.html).
This webpage include JavaScript code running in the browser.
This code uses the [Vue.js](https://vuejs.org/) framework, and [STOMP.js](https://github.com/stomp-js/stompjs) for communication with the rest of the system via the [message broker](/broker.html).
It also receives image data from the [UI server](/ui_server.html) using websockets.
