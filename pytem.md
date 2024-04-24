---
layout: page
title: pyTEM
sends:
    - tile.raw
    - camera.command
    - camera.settings
    - stage.aperature.command
    - stage.rotation.command
    - stage.motion.command
receives:
    - camera.image
    - camera.status
    - stage.aperature.status
    - stage.rotation.status
    - stage.motion.status
---