---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
title: TEM Architecture
---

Welcome to the documentation for the [Allen Institute](https://alleninstitute.org/) next generation TEM data acquisition system.
This is an event driven system with various components running in docker containers, along with other services running on other machines.
Below, is a diagram showing a general overview of this system.

{% diagram %}
from diagrams.aws.database import Dynamodb
from diagrams.aws.storage import S3
from diagrams.onprem.queue import Activemq
from diagrams.programming.language import Cpp, Python
from diagrams.onprem.client import Client
from diagrams.custom import Custom

with Cluster("AWS", graph_attr={"bgcolor": "#FFE0B2"}):
    db = Dynamodb("DynamoDB", pin="true", pos="0, 0.375")
    s3 = S3("S3 Bucket", pin="true", pos="0.25, -0.125")

    tem_db = Python("TEM DB", pin="true", pos="0.25, 0.375", href="/tem_db.html")

    ac_qc = Python("AC/QC", pin="true", pos="0, -0.125")

    aloha = Python("Aloha", pin="true", pos="0.25, 0.125", href="/aloha.html")

client = Client("AC/QC user", pin="true", pos="-0.25, -0.125")
operator = Client("Microscope Operator", pin="true", pos="1.25, 0.25")

with Cluster("Docker Compose", graph_attr={"bgcolor": "#E0F2F1"}):
    event_bus = Activemq("ActiveMQ", pin="true", pos="1, -0.25", href="/broker.html")

    state_machine = Python(
        "pyTEM", pin="true", pos="0.75, 0.25"
    )
    microscope_service = Python("Microscope\nService", pin="true", pos="1, 0.5")
    camera_service = Python("Camera\nService", pin="true", pos="0.5, 0.5")
    stage_service = Python("Stage\nService", pin="true", pos="0.75, 0.5")
    cpp_pipeline = Cpp("C++ Pipeline\n(OpenCV, CUDA)", pin="true", pos="0.75, 0", href="/pipeline.html")
    buffer = Python("Buffer\nService", pin="true", pos="0.5, 0", href="/buffer.html")
    ui_server = Python("UI Server", pin="true", pos="1, 0.25")

microscope = Custom("Microscope", "_my_icons/TEM.png", pin="true", pos="1, 0.75")
stage = Custom("Stage", "_my_icons/stage.png", pin="true", pos="0.75, 0.75")
camera = Custom("Camera", "_my_icons/camera.png", pin="true", pos="0.5, 0.75")

s3 >> ac_qc
tem_db << Edge() >> db
tem_db << Edge() >> ac_qc
tem_db >> state_machine
client << Edge() >> ac_qc
state_machine << Edge() >> microscope_service
state_machine << Edge() >> camera_service
state_machine << Edge() >> stage_service
state_machine >> cpp_pipeline
cpp_pipeline >> buffer >> s3
state_machine << Edge() >> ui_server
operator << Edge() >> ui_server
microscope << Edge() >> microscope_service
stage << Edge() >> stage_service
camera << Edge() >> camera_service
s3 << Edge() >> aloha << Edge() >> tem_db
cpp_pipeline >> ui_server
camera_service >> cpp_pipeline
{% enddiagram %}

Many of the nodes in this diagram are hyperlinks to further documentation on this system.