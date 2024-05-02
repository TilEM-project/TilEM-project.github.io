---
layout: page
title: Camera Service
type: task
receives:
    - camera.settings
    - camera.command
sends:
    - camera.image
    - camera.status
github: AllenInstitute/XIMEA_service
assigned: Cameron
---

The camera service takes care of interacting with the camera using the [XIMEA](https://www.ximea.com/) [xiAPI](https://www.ximea.com/support/wiki/apis/XiAPI).
This service accepts messages from two topics, [`camera.settings`](/topics.html#camera-settings) and [`camera.command`](/topics.html#camera-command).
The `camera.settings` topic is used for changing settings on the camera such as exposure or resolution, while the `camera.command` topic is used to signal the camera to get an image which is then saved to disk and the path sent on the [`camera.image`](/topics.html#camera-image) topic.
The `camera.command` message includes the tile ID, and the image should be saved to disk, using this ID is the filename.
A message should be sent on the [`camera.status`](/topics.html#camera-status) topic at a rate of no less than 1 Hz.