---
layout: page
title: Stage Service
sends:
    - stage.motion.status
    - stage.aperture.status
receives:
    - stage.motion.command
    - stage.aperture.command
---

The stage service abstracts the interfaces of the various hardware components related to positioning and transitioning between aperatures.
This service can be split into three components, moving between aperatures, rotating samples, and positioning samples.

For changing between aperatures, two topics are used, [`stage.aperature.command`](/topics.html#stage-aperature-command) and [`stage.aperature.status`](/topics.html#stage-aperature-status).
The `stage.aperature.command` topic is used to send commands to the hardware to change the aperature, and/or optionally calibrate the hardware.
The `stage.aperature.status` topic normally has a message published at a frequency of no less than 1 Hz, at a frequency of no less than 20 Hz when in motion, and immediately once any motion is complete.
This message contains the status of the hardware including the ID of the current aperature, if the hardware is calibrated, along with any errors.

For moving the stages, two topics are used, [`stage.motion.command`](/topics.html#stage-motion-command) and [`stage.motion.status`](/topics.html#stage-motion-status).
The `stage.motion.command` topic is used to send commands to the stages.
The `stage.motion.status` topic normally has a message published at a frequency of no less than 1 Hz, at a frequency of no less the 50 Hz when in motion, and immediately once motion is complete.
This message contains the status of the hardware including the current locations of the stages, along with other information.