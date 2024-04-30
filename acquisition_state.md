---
title: Acquisition State
layout: page
---
## Current Functionality

Return to pyTEM [here](/pytem.html).

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

{% diagram %}

from diagrams import Cluster
from diagrams.programming.flowchart import Action, Decision, StartEnd, PredefinedProcess

with Cluster("Outer Infinite Loop"):
    start_outer = StartEnd("Start Outer Loop")
    end_outer = StartEnd("End Outer Loop")

with Cluster("Main Acquisition"):
    check_activation = Decision("Check Activation & Start")
    initialize_acquisition = Action("Initialize & Prepare Acquisition")

with Cluster("ROI Acquisition Process"):
    roi_loop = Action("For Each ROI")
    initialize_roi = Action("Initialize ROI & Calculate Position")
    move_stage = Action("Move & Stabilize Stage")
    roi_end = Action("Finalize ROI")

with Cluster("Per-Tile"):
    set_metadata = Action("Set Metadata for Each Tile")
    start_exposure = Action("Start Camera Exposure")
    handle_async = Action("Handle Async & Write Metadata")
    complete_exposure = Action("Complete Exposure")
    next_position = Action("Get Next Position")
    stabilize_stage = Action("Stabilize Stage")
    check_tile_end = Decision("More Tiles?")

with Cluster("Lens Correction Process"):
    lens_correction = Action("Correct Lens Distortions")

with Cluster("Completion & Metadata Handling"):
    finalize_metadata = PredefinedProcess("Finalize Metadata")
    create_robocopy = Action("Create Robocopy File")

with Cluster("Abort or Switch Event"):
    check_abort = Decision("Check for Abort or Switch")
    handle_abort = Action("Handle Abort")

with Cluster("Event Scheduling"):
    schedule_events = Action("Schedule Events")

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
