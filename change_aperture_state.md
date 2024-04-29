---
title: Change Aperture State
layout: page
---
## Current Functionality

Return to pyTEM [here](/pytem.html).

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

{% diagram %}

from diagrams import Diagram, Cluster
from diagrams.programming.flowchart import Action, InputOutput, Decision, StartEnd

with Cluster("Change Aperture State"):
    entry = StartEnd("Enter State")
    init_tape = Decision("Initialize tape_ranges")
    fetch_barcode = Action("Fetch Barcode from TEM_db")

    init_logging = Action("Initialization & Logging")
    state_check = Decision("Check if State is PAUSE")
    retry_later = Action("Retry after 0.2s")

    preparatory = Action("Preparatory Actions")
    abort_checks = Action("Check Abort Conditions")

    handle_tape = Action("Handle Tape & Aperture")
    move_correct = Action("Aperture Movement & Correction")
    beam_adjust = Action("Lens & Beam Adjustments")
    brightfield_img = Action("Brightfield Imaging")
    lens_correction = Action("Lens Correction Montage")

    finalize = Action("Finalizing & Error Handling")
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
