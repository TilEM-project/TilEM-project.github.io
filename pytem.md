---
layout: page
title: pyTEM
type: task
sends:
    - tile.raw
    - camera.command
    - camera.settings
    - stage.aperture.command
    - stage.rotation.command
    - stage.motion.command
    - scope.command
    - montage.start
    - montage.finished
receives:
    - camera.image
    - camera.status
    - stage.aperture.status
    - stage.rotation.status
    - stage.motion.status
    - scope.status
    - qc.status
assigned: Cameron
github: AllenInstitute/pytem
---

pyTEM is the main hierarchical state machine orchestrating all the components.
This service uses the [Pigeon](https://pigeon.readthedocs.io/en/latest/) client for communication via the [message broker]({{ '/broker.html' | relative_url }}).
Furthermore, a [library](https://github.com/AllenInstitute/pigeon-transitions) integrating Pigeon and the Python [Transitions](https://github.com/pytransitions/transitions) library to allow easy creation of the state machine.
This library can also create state transition diagrams of the state machine:

![State Diagram]({{ '/graph.png' | relative_url }})

Historically, orchestration of all components was accomplished using [pytemca](https://github.com/AllenInstitute/pytemca) documented [here]({{ '/pytemca.html'  | relative_url }}).
