---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
---

This is an overview diagram of the system:

{% diagram %}
from diagrams.aws.database import Dynamodb
from diagrams.aws.storage import S3
from diagrams.onprem.queue import Activemq
from diagrams.programming.language import Cpp, Python
from diagrams.onprem.client import Client
from diagrams.custom import Custom

with Cluster("AWS", graph_attr={"bgcolor": "#FFE0B2"}):
    db = Dynamodb("DynamoDB", pin="true", pos="0, 0.5")
    s3 = S3("S3 Bucket", pin="true", pos="0.5, 0")

    tem_db = Python("TEM DB\nService\n(FastAPI)", pin="true", pos="0.5, 0.5")

    ac_qc = Python("AC/QC Service\n(Python/Vue.js)", pin="true", pos="0, 0")

client = Client("AC/QC user", pin="true", pos="-0.5, 0")
operator = Client("Microscope Operator", pin="true", pos="2.5, 0.5")

with Cluster("Docker Compose", graph_attr={"bgcolor": "#E0F2F1"}):
    event_bus = Activemq("ActiveMQ", pin="true", pos="1, -0.5")

    state_machine = Python(
        "State Machine\n(Business Logic)", pin="true", pos="1.5, 0.5"
    )
    microscope_service = Python("Microscope\nService", pin="true", pos="2, 1")
    camera_service = Python("Camera\nService", pin="true", pos="1, 1")
    stage_service = Python("Stage\nService", pin="true", pos="1.5, 1")
    cpp_pipeline = Cpp("C++ Pipeline\n(OpenCV, CUDA)", pin="true", pos="2, 0", href="/pipeline.html")
    buffer = Python("Buffer\nService", pin="true", pos="1.5, 0")
    ui_server = Python("UI Server", pin="true", pos="2, 0.5")

microscope = Custom("Microscope", "_my_icons/TEM.png", pin="true", pos="2, 1.5")
stage = Custom("Stage", "_my_icons/stage.png", pin="true", pos="1.5, 1.5")
camera = Custom("Camera", "_my_icons/camera.png", pin="true", pos="1, 1.5")

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
{% enddiagram %}

You can click on nodes to find more docs.