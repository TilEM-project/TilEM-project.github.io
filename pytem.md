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
This library can also create a state transition diagrams of the state machine:

![State Diagram]({{ '/graph.png' | relative_url }})

## Simplified State Diagram

A simplified version of this schematic is:

{% diagram layout=dot %}
from diagrams import Cluster, Node, Edge

preview = Cluster("Preview")

with preview:
    update = Node("UpdateImage", href="#updateimage")
    brightfield = Node("Brightfield", href="#brightfield")
    darkfield = Node("Darkfield", href="#darkfield")
    auto_focus = Node("AutoFocus", href="#autofocus")
    auto_exposure = Node("AutoExposure", href="#autoexposure")
    beam_center = Node("BeamCenter", href="#beamcenter")
    beam_spread = Node("BeamSpread", href="#beamspread")
    change_aperture = Node("ChangeAperture", href="#changeaperture")
    lens_correction = Node("LensCorrection", href="#lenscorrection")
    find_aperture = Node("FindAperture", href="#findaperture")

update << Edge() >> brightfield
update << Edge() >> darkfield
update << Edge() >> auto_focus
update << Edge() >> auto_exposure
update << Edge() >> beam_center
update << Edge() >> beam_spread
update << Edge() >> change_aperture
update << Edge() >> lens_correction
update << Edge() >> find_aperture

acquisition = Cluster("Acquisition")

with acquisition:
    change_aperture = Node("ChangeAperture", href="#changeaperture")
    find_aperture = Node("FindAperture", href="#findaperture")
    auto_exposure = Node("AutoExposure", href="#autoexposure")
    beam_center = Node("BeamCenter", href="#beamcenter")
    beam_spread = Node("BeamSpread", href="#beamspread")
    brightfield = Node("Brightfield", href="#brightfield")
    darkfield = Node("Darkfield", href="#darkfield")
    auto_focus = Node("AutoFocus", href="#autofocus")
    lens_correction = Node("LensCorrection", href="#lenscorrection")

    montage = Cluster("Montage")

    with montage:
        move = Node("MoveStage", href="#movestage")
        capture = Node("CaptureTile", href="#capturetile")

    change_aperture >> find_aperture >> auto_exposure >> beam_center >> beam_spread >> brightfield >> darkfield >> auto_focus >> lens_correction >> move
    auto_focus >> move
    move << Edge() >> capture

    capture >> change_aperture

shutdown = Node("Shutdown", href="#shutdown")

update >> change_aperture
capture >> shutdown
update << Edge() >> shutdown

{% enddiagram %}

Below, the functionality of each of "states" shown above is detailed.
In reality, each of these "states" is a state machine in and of itself.

#### Preview

The `Preview` machine is used for previewing the image data, and checking that the microscope functions as expected.

#### Acquisition

The `Acquisition` machine is used to set up and capture a montage.

#### Montage

The `Montage` machine collects the required tiles.

#### UpdateImage

The `UpdateImage` machine requests an image from the [camera]({{ 'camera.html' | relative_url }}), and sends it to the [image processing pipeline]({{ 'pipeline.html' | relative_url }}).
Ultimately, this image will then be shown on the [UI]({{ 'ui.html' | relative_url}}).

#### Darkfield

The `Darkfield` machine collects a darkfield image by lowering the screen on the [microcope]({{ 'scope.html' | relative_url }}), collecting a series of images, averaging them, then raising the screen again.

#### Brightfield

The `Brightfield` machine collects a brightfield image by moving the [stage]({{ 'stage.html' | relative_url }}) while collecting a series of images, then averaging them.

#### AutoFocus

The `AutoFocus` machine optimizes the focus by maximizing the focus score produced by the [image processing pipeline]({{ 'pipeline.html' | relative_url }}).

#### AutoExposure

The `AutoExposure` machine optimizes the exposure by finding the [camera]({{ 'camera.html' | relative_url }}) exposure which produces a mean value within the correct range as calculated by the [image processing pipeline]({{ 'pipeline.html' | relative_url }}).

#### BeamCenter

The `BeamCenter` machine centers the electron beam in the [microscope's]({{ 'scope.html' | relative_url }}) field of view.

#### BeamSpread

The `BeamSpread` machine spreads the beam to get an even density of electrons over the field of view.

#### ChangeAperture

The `ChangeAperture` machine changes the current aperture of the tape or stick that is being imaged.

#### LensCorrection

The `LensCorrection` machine collects a lens correction montage.

#### FindAperture

The `FindAperture` machine finds the bounds of the current aperture by moving the [stage]({{ 'stage.html' | relative_url }}) and processing images.

#### MoveStage

The `MoveStage` machine moves the [stage]({{ 'stage.html' | relative_url }}) to the location of the next tile.

#### CaptureTile

The `CaptureTile` machine captures a single tile using the [camera]({{ 'camera.html' | relative_url }}).

#### Shutdown

In the `Shutdown` machine, the microscope is placed into a safe state.
Ideally, the beam is turned off, and the screen is lowered.

> ##### Note:
> Historically, orchestration of all components was accomplished using [pytemca](https://github.com/AllenInstitute/pytemca) documented [here]({{ '/pytemca.html'  | relative_url }}).
