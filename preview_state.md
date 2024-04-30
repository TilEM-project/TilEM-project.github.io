---
title: Preview State
layout: page
---
## Current Functionality

Return to pyTEM [here](/pytem.html).
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
