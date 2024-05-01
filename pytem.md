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
    - scope.command
receives:
    - camera.image
    - camera.status
    - stage.aperture.status
    - stage.rotation.status
    - stage.motion.status
    - scope.status
owner: Derrick
---

{% diagram layout=neato %}
from diagrams import Diagram, Cluster, Node, Edge

with Cluster("pyTEM States"):
    preview_mode = Node("Preview/Setup State", shape="rectangle", style="rounded", labelloc="c", width="3", height="0.5", pin="true", pos="0,4",  href="#preview-state")
    change_aperture = Node("Change Aperture State", shape="rectangle", style="rounded", labelloc="c", width="3", height="0.5", pin="true", pos="-2,2.5",  href="#change-aperture-state")
    acquisition = Node("Acquisition State", shape="rectangle", style="rounded", labelloc="c", width="3", height="0.5",pin="true", pos="0,0",  href="#acquisition-state")
    error = Node("Error State", shape="diamond", style="solid", labelloc="c", width="2", height="0.75", pin="true", pos="3,2.5",  href="#error-state")

preview_mode >> change_aperture >> acquisition
acquisition >> Edge(xlabel="Repeat", minlen="2") >> change_aperture

acquisition >> Edge(color="red", xlabel="Error", style="dashed", minlen="2") >> error
change_aperture >> Edge(color="red", xlabel="Error", style="dashed", minlen="2") >> error

acquisition >> Edge(color="blue", label="Abort", style="dashed", minlen="2") >> preview_mode
{% enddiagram %}

## Preview State

This state is is the entry point to the system. It is the default state at start up and will also be the state that the system will revert to upon detecting an error that does not crash the system.

### Preview State Logic

Upon entering this state the system will continuously acquire images from the XIMEA camera and each image frame will be minimally processed. The images are then JPEG encoded and sent to python which pushes them to a websocket to display on a browser based UI.

{% diagram %}
from diagrams import Diagram, Cluster, Edge
from diagrams.programming.flowchart import Action, InputOutput, Decision
from diagrams.programming.language import Cpp, Python
from diagrams.onprem.client import User

with Cluster("opencv_graph"):
    get_image = Cpp("Acquire Image")
    corrections = Cpp("Flat Field Correction\nand CLAHE (CUDA)")

    calc_stats = Cpp("Calculate Stats\n(Min/Max/Mean)")
    calc_fft = Cpp("Calculate FFT Focus Score")
    jpeg_compress = Cpp("JPEG Compress")

    send_pybind = Cpp("Send to Python\nvia pybind11")

with Cluster("pyTEMCA"):
    encode = Python("Encode Image")
    publish = Python("Publish Image")

web_ui = User("Web UI")
check_state = Decision("State Changed?")
get_image >> corrections >> jpeg_compress >> send_pybind
corrections >> calc_stats >> send_pybind
corrections >> calc_fft >> send_pybind
send_pybind >> encode >> publish >> web_ui

check_state >> Edge(xlabel="Repeat", minlen="2") >> check_state >> get_image
{% enddiagram %}

## Change Aperture State

The Change Aperture State represents a state for moving to an aperture on a grid tape or stick16.

### Change Aperture State Logic

Upon entering this state it handles the entry logic for the state and initializes tape_ranges if it is None. It tries to fetch barcode values from TEM_db (if using tape); otherwise, it sets default values.

Next the code performs the following:

1. Initialization and Logging:
    Clears lists related to aperture critical and error events.
    Logs the action of changing the aperture.

2. State Check for Pause:
    Checks if the current montage state is PAUSE. If yes, it schedules the _change_aperture method to run again after 0.2 seconds and exits the current execution.

3. Preparatory Actions:
    Updates beam center results and informs the system that a new montage is starting.

4. Abort Conditions Check:
    Checks several conditions to decide whether to abort the operation:
    - If required media information is missing.
    - If environmental conditions are not suitable.
    - If there's a pending request to abort at the end of the montage.
    - If there is insufficient disk space.
    - If too many errors have accumulated (default is 3).

5. Handling of Tape and Aperture:
    Retrieves the next task object (TAO) from the montage controller.
    If a valid TAO is found:
    - Checks if the destination directory exists or needs to be created.
    - Checks for existing data that might require an abort.
    - Performs adjustments based on the first Region of Interest (ROI) from tao.

6. Aperture Movement and Correction:
    Manages movement to the correct grid or aperture based on the tape controller status.
    Deals with potential barcode errors and adjusts based on confidence levels in the barcode readings.

7. Lens and Beam Adjustments:
    Adjusts the beam's brightness and attempts to find a centroid for the aperture if needed.
    Conducts a quality check on the beam's brightness and might abort if the beam mean value is too low.
    Manages autocentering of the beam if necessary.

8. Brightfield Imaging:
    Handles brightfield imaging conditions and might abort based on the quality of consecutive brightfield images.

9. Lens Correction Montage:
    Decides whether a new lens correction montage is necessary based on time intervals and changes in lens conditions.

10. Finalizing and Error Handling:
    If no ROIs are found in tao, logs the event but continues processing.
    If there are still tasks (taos) left in the montage queue, it triggers the start of another attempt.
    Sets the montage state to NONE if no tasks are left.

{% diagram rankdir=LR%}

from diagrams import Diagram, Cluster
from diagrams.programming.flowchart import Action, InputOutput, Decision, StartEnd

with Cluster("Change Aperture State"):
    entry = StartEnd("Enter State")
    init_tape = Decision("Initialize tape_ranges")
    fetch_barcode = Action("Fetch Barcode\nfrom TEM_db")

    init_logging = Action("Initialization\n& Logging")
    state_check = Decision("Check if State\nis PAUSE")
    retry_later = Action("Retry after 0.2s")

    preparatory = Action("Preparatory Actions")
    abort_checks = Action("Check Abort\nConditions")

    handle_tape = Action("Handle Tape\n& Aperture")
    move_correct = Action("Aperture Movement\n& Correction")
    beam_adjust = Action("Lens & Beam\nAdjustments")
    brightfield_img = Action("Brightfield Imaging")
    lens_correction = Action("Lens Correction\nMontage")

    finalize = Action("Finalizing & Error\nHandling")
    set_state_none = Action("Set State to NONE")

entry >> init_tape >> fetch_barcode
init_tape >> init_logging
init_logging >> state_check
state_check >> preparatory
state_check >> retry_later
retry_later >> state_check

preparatory >> abort_checks
abort_checks >> handle_tape
handle_tape >> move_correct
move_correct >> beam_adjust
beam_adjust >> brightfield_img
brightfield_img >> lens_correction

lens_correction >> finalize
finalize >> set_state_none

{% enddiagram %}

## Acquisition State

The Acquisition State represents the overall state of the acquisition loop in the system for imaging and processing data. It manages tasks related to moving the stage, capturing images, processing metadata, and handling various states during the acquisition process.

### Acquisition State Logic

#### Main Acquisition Loop Activation

The acquisition starts if both the main_acquisition_loop_active_event is set and _start_new_aperture() returns True.
Initialize variables and prepare for the acquisition sequence within a specific aperture.

#### ROI Acquisition Process

Iterate over each ROI in roi_list.

For each ROI:

- Initialize the ROI and calculate the starting position.
- Move the stage to the initial position and wait for it to stabilize.
- Enter a nested loop to handle image capture for each tile in the ROI until there are no more positions to move to.
  - Set metadata for the image.
  - Start camera exposure.
  - If there was a previous image, wait for asynchronous processes to complete and possibly write metadata.
  - Wait for the current exposure to complete.
  - Get the next position and move the stage.
  - Handle synchronization and stabilization of the stage.

- After completing all tiles in the ROI, perform final processing such as writing metadata and resetting the stage to the starting position.

#### Lens Correction Process

If lens correction is part of the current montage, attempt to correct lens distortions using template matching and solving algorithms. Multiple attempts are made, and if unsuccessful, a critical error event is logged.

#### Completion and Metadata Handling

Finalize the metadata file and write results to a database.
Create a robocopy file if not aborting.

#### Abort or Switch Event

If an abort signal is received or it's time to switch to another aperture, the loop is terminated or adjusted accordingly.

#### Event Scheduling

Schedule callbacks for events like "BACK_TO_SETUP" or "NEXT_APERTURE" based on the conditions met during the loop.

{% diagram layout=neato %}

from diagrams import Cluster
from diagrams.programming.flowchart import Action, Decision, StartEnd, PredefinedProcess

with Cluster("Outer Infinite Loop"):
    start_outer = StartEnd("Start Outer Loop", pin="true", pos="-3, 2")
    end_outer = StartEnd("End Outer Loop", pin="true", pos="-2, 2")

with Cluster("Main Acquisition"):
    check_activation = Decision("Check Activation\n& Start", pin="true", pos="-3, 1")
    initialize_acquisition = Action("Initialize & Prepare\nAcquisition", pin="true", pos="-2, 1")

with Cluster("ROI Acquisition Process"):
    roi_loop = Action("For Each ROI", pin="true", pos="-2, 0")
    initialize_roi = Action("Initialize ROI &\nCalculate Position", pin="true", pos="-2, -1")
    move_stage = Action("Move &\nStabilize Stage", pin="true", pos="-1, -1")
    roi_end = Action("Finalize ROI", pin="true", pos="-1, 0")

with Cluster("Per-Tile"):
    set_metadata = Action("Set Metadata\nfor Each Tile", pin="true", pos="0, -1")
    start_exposure = Action("Start Camera\nExposure", pin="true", pos="1, -1")
    handle_async = Action("Handle Async &\nWrite Metadata", pin="true", pos="2, -1")
    complete_exposure = Action("Complete\nExposure", pin="true", pos="3, -0.5")
    next_position = Action("Get Next Position", pin="true", pos="2, 0")
    stabilize_stage = Action("Stabilize Stage", pin="true", pos="1, 0")
    check_tile_end = Decision("More Tiles?", pin="true", pos="0, 0")

with Cluster("Lens Correction\nProcess"):
    lens_correction = Action("Correct Lens\nDistortions", pin="true", pos="-1, 1")

with Cluster("Completion & Metadata Handling"):
    finalize_metadata = PredefinedProcess("Finalize Metadata", pin="true", pos="0, 1")
    create_robocopy = Action("Create Robocopy\nFile", pin="true", pos="1, 1")

with Cluster("Abort or\nSwitch Event"):
    check_abort = Decision("Check for\nAbort or Switch", pin="true", pos="1, 2")
    handle_abort = Action("Handle Abort", pin="true", pos="0, 2")

with Cluster("Event Scheduling"):
    schedule_events = Action("Schedule Events", pin="true", pos="-1, 2")

start_outer >> check_activation
check_activation >> initialize_acquisition
initialize_acquisition >> roi_loop
roi_loop >> initialize_roi >> move_stage

move_stage >> set_metadata
set_metadata >> start_exposure >> handle_async >> complete_exposure >> next_position >> stabilize_stage >> check_tile_end
check_tile_end >> set_metadata  
check_tile_end >> roi_end

roi_end >> lens_correction
lens_correction >> finalize_metadata >> create_robocopy >> check_abort
check_abort >> handle_abort >> schedule_events >> end_outer
end_outer >> start_outer

{% enddiagram %}

## Error State

