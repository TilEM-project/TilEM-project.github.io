---
layout: page
title: pyTEM
sends:
    - tile.raw
    - camera.command
    - camera.settings
    - stage.aperture.command
    - stage.rotation.command
    - stage.motion.command
receives:
    - camera.image
    - camera.status
    - stage.aperture.status
    - stage.rotation.status
    - stage.motion.status
---