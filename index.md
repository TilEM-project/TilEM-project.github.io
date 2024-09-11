---
layout: page
title: TEM Architecture
---

Welcome to the documentation for the [Allen Institute](https://alleninstitute.org/) next generation TEM data acquisition system.
This is an event driven system with various components running in docker containers, along with other services running on other machines.
Below, is a diagram showing a general overview of this system.

{% diagram layout=neato %}
from diagrams.aws.database import Database
from diagrams.aws.storage import S3
from diagrams.aws.compute import LambdaFunction
from diagrams.onprem.queue import Activemq
from diagrams.programming.language import Cpp, Python
from diagrams.onprem.client import Client
from diagrams.custom import Custom
from diagrams.onprem.logging import Loki
from diagrams.onprem.vcs import Github
from diagrams.onprem.container import Docker

with Cluster("AWS", graph_attr={"bgcolor": "#FFE0B2"}):
    db = Database("Database", pin="true", pos="0, 0.25")
    s3 = S3("S3 Bucket", pin="true", pos="-0.25, -0.25")

    tem_db = Python("TEM DB", pin="true", pos="-0.25, 0.25", href="{{ '/tem_db.html' | relative_url }}")

    ac_qc = Python("AC/QC", pin="true", pos="0, -0.25")

    aloha = LambdaFunction("Aloha", pin="true", pos="-0.25, 0", href="{{ '/aloha.html' | relative_url }}")

client = Client("AC/QC user", pin="true", pos="0.25, -0.25")
operator = Client("Microscope Operator", pin="true", pos="-1.25, 0.125", href="{{ '/ui.html' | relative_url }}")

with Cluster("Docker Compose", graph_attr={"bgcolor": "#E0F2F1"}):
    event_bus = Activemq("ActiveMQ", pin="true", pos="-1, -0.25", href="{{ '/broker.html' | relative_url }}")

    pyTEM = Python(
        "pyTEM", pin="true", pos="-0.75, 0.25", href="{{ '/pytem.html' | relative_url }}"
    )
    microscope_service = Python("Microscope\nService", pin="true", pos="-0.5, 0.5", href="{{ '/scope.html' | relative_url }}")
    camera_service = Python("Camera\nService", pin="true", pos="-1, 0.5", href="{{ '/camera.html' | relative_url }}")
    stage_service = Python("Stage\nService", pin="true", pos="-0.75, 0.5", href="{{ '/stage.html' | relative_url }}")
    cpp_pipeline = Cpp("Image Processing\nPipeline", pin="true", pos="-0.75, 0", href="{{ '/pipeline.html' | relative_url }}")
    buffer = Python("Buffer\nService", pin="true", pos="-0.5, 0", href="{{ '/buffer.html' | relative_url }}")
    ui_server = Python("UI Server", pin="true", pos="-1, 0.125", href="{{ '/ui_server.html' | relative_url }}")

microscope = Custom("Microscope", "_my_icons/TEM.png", pin="true", pos="-0.5, 0.75")
stage = Custom("Stage", "_my_icons/stage.png", pin="true", pos="-0.75, 0.75")
camera = Custom("Camera", "_my_icons/camera.png", pin="true", pos="-1, 0.75")

with Cluster("Platform9", graph_attr={"bgcolor": "#b2ffc7"}):
    log = Loki("Log Server", pin="true", pos="-0.25, 0.5", href="{{ '/log.html' | relative_url }}")

with Cluster("Lab Server", graph_attr={"bgcolor": "#ffb2b2"}):
    registry = Docker("Container Registry", pin="true", pos="0, 0.5", href="{{ '/registry.html' | relative_url }}")
    runner = Github("GitHub Actions\nRunner", pin="true", pos="0.25, 0.5", href="{{ '/runner.html' | relative_url }}")

s3 >> ac_qc
tem_db << Edge() >> db
tem_db << Edge() >> ac_qc
tem_db >> pyTEM
client << Edge() >> ac_qc
pyTEM << Edge() >> microscope_service
pyTEM << Edge() >> camera_service
pyTEM << Edge() >> stage_service
pyTEM >> cpp_pipeline
cpp_pipeline >> buffer >> aloha
pyTEM << Edge() >> ui_server
operator << Edge() >> ui_server
microscope << Edge() >> microscope_service
stage << Edge() >> stage_service
camera << Edge() >> camera_service
s3 << aloha >> tem_db
cpp_pipeline >> ui_server
{% enddiagram %}

Most of the nodes in this diagram are hyperlinks to further documentation of this system.

This system primarily sends messages between services using the [STOMP protocul](https://stomp.github.io/) with the [Pigeon](https://pypi.org/project/pigeon-client/) library.
The configuration for this system as a whole is stored on GitHub at [AllenInstitute/TEM_config](https://github.com/AllenInstitute/TEM_config).
This repository includes both a Docker compose file for starting all the services that are part of the system, and the configuration files for the services.
