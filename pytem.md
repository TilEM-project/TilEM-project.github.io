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
---
### Current System

{% diagram %}
from diagrams import Diagram, Cluster, Node, Edge

with Cluster("pyTEM States"):
    preview_mode = Node("Preview/Setup State", shape="rectangle", style="rounded", labelloc="c", width="3", height="0.5", pin="true", pos="0,4",  href="/preview_state.html")
    change_aperture = Node("Change Aperture State", shape="rectangle", style="rounded", labelloc="c", width="3", height="0.5", pin="true", pos="-2,2.5",  href="/change_aperture_state.html")
    acquisition = Node("Acquisition State", shape="rectangle", style="rounded", labelloc="c", width="3", height="0.5",pin="true", pos="0,0",  href="/acquisition_state.html")
    error = Node("Error State", shape="diamond", style="solid", labelloc="c", width="2", height="0.75", pin="true", pos="3,2.5",  href="/error_state.html")

preview_mode >> change_aperture >> acquisition
acquisition >> Edge(xlabel="Repeat", minlen="2") >> change_aperture

acquisition >> Edge(color="red", xlabel="Error", style="dashed", minlen="2") >> error
change_aperture >> Edge(color="red", xlabel="Error", style="dashed", minlen="2") >> error

acquisition >> Edge(color="blue", label="Abort", style="dashed", minlen="2") >> preview_mode
{% enddiagram %}
