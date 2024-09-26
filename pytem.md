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

A simplified version of this schematic is:

{% diagram layout=fdp maxiter=1000 %}
from diagrams import Cluster, Node, Edge

preview = Cluster("Preview")

with preview:
    update = Node("UpdateImage")
    brightfield = Node("Brightfield")
    darkfield = Node("Darkfield")
    auto_focus = Node("AutoFocus")
    auto_exposure = Node("AutoExposure")
    beam_center = Node("BeamCenter")
    beam_spread = Node("BeamSpread")
    change_aperture = Node("ChangeAperture")

update << Edge() >> brightfield
update << Edge() >> darkfield
update << Edge() >> auto_focus
update << Edge() >> auto_exposure
update << Edge() >> beam_center
update << Edge() >> beam_spread
update << Edge() >> change_aperture

acquisition = Cluster("Acquisition")

with acquisition:
    change_aperture = Node("ChangeAperture")
    auto_exposure = Node("AutoExposure")
    beam_center = Node("BeamCenter")
    beam_spread = Node("BeamSpread")
    brightfield = Node("Brightfield")
    darkfield = Node("Darkfield")
    auto_focus = Node("AutoFocus")

    montage = Cluster("Montage")

    with montage:
        move = Node("MoveStage")
        capture = Node("CaptureTile")

    change_aperture >> auto_exposure >> beam_center >> beam_spread >> brightfield >> darkfield >> auto_focus >> move
    move << Edge() >> capture

    capture >> change_aperture

shutdown = Node("Shutdown")

update >> change_aperture
capture >> shutdown
update << Edge() >> shutdown

{% enddiagram %}

Historically, orchestration of all components was accomplished using [pytemca](https://github.com/AllenInstitute/pytemca) documented [here]({{ '/pytemca.html'  | relative_url }}).
