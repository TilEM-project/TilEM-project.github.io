---
layout: page
title: TEM Architecture
---

Welcome to the documentation for the [Allen Institute](https://alleninstitute.org/) next generation TEM data acquisition system.
This system is used at the Allen Institute for Brain Science to do large-scale high-throughput TEM imaging of brain tissue.
The system is primarily comprised of a number of Docker containers communicating via a message broker.
Using this architecture, the system is modular, high performance, and stable.

An overview of the architecture is as follows, the [pyTEM]({{ site.baseurl }}/pytem.html) service is a hierarchical state machine that coordinates the entire system.
This service includes the routines for auto-focusing the microscope, centering the beam, etc, all encoded as state machines.
Communication is handled by a [message broker]({{ site.baseurl }}/broker.html) and our [Pigeon](https://pypi.org/project/pigeon-client/) client library.
Under the hood this uses the [STOMP](https://stomp.github.io/) protocol for communication.
There are also services which handle communication with a single piece of hardware, such as the [scope]({{ site.baseurl }}/scope.html), [stage]({{ site.baseurl }}/stage.html), and [camera]({{ site.baseurl }}/camera.html).
Once an image (tile) is collected from the camera it is saved to disk and a message is sent to the [image processing pipeline]({{ site.baseurl }}/pipeline.html).
This pipeline performs some simple image processing such as flatfield correction and contrast enhancement, calculates some statistics, such as min, max, and mean image values, a histogram, and a focus quality metric, and finally checks that there is overlap between tiles.
These metrics are received by two services, the first of which is the [QC]({{ site.baseurl }}/qc.html) which monitors the tile statistics to ensure there are no errors in the acquisition.
If any errors are detected, a message will be sent to pyTEM instructing it to either immediately stop imaging, or stop imaging at the end of the montage.
The second service is the [buffer]({{ site.baseurl }}/buffer.html) which collects the processed images, and the statistics.
After a montage is completed successfully, this service sends the tiles and metadata to [aloha]({{ site.baserul }}/aloha.html) via HTTP.
This service

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
    tem_db = Python("TEM DB", pin="true", pos="-0.25, 0.25", href="/tem_db.html")

aloha = LambdaFunction("Aloha", pin="true", pos="-0.25, -0.375", href="/aloha.html")
s3 = S3("Storage Bucket", pin="true", pos="0, -0.375")

client = Client("AC/QC user", pin="true", pos="0.25, 0.125")
operator = Client("Microscope Operator", pin="true", pos="-1.25, 0.125", href="/ui.html")

with Cluster("Docker Compose", graph_attr={"bgcolor": "#E0F2F1"}):
    event_bus = Activemq("ActiveMQ", pin="true", pos="-1, -0.375", href="/broker.html")

    pyTEM = Python(
        "pyTEM", pin="true", pos="-0.75, 0.25", href="/pytem.html"
    )
    microscope_service = Python("Microscope\nService", pin="true", pos="-0.5, 0.5", href="/scope.html")
    camera_service = Python("Camera\nService", pin="true", pos="-1, 0.5", href="/camera.html")
    stage_service = Python("Stage\nService", pin="true", pos="-0.75, 0.5", href="/stage.html")
    cpp_pipeline = Cpp("Image Processing\nPipeline", pin="true", pos="-0.75, 0", href="/pipeline.html")
    buffer = Python("Buffer\nService", pin="true", pos="-0.5, -0.375", href="/buffer.html")
    QC_service = Python("QC Service", pin="true", pos="-0.5, 0.125", href="/qc.html")
    montage_fit = Python("Montage Fit", pin="true", pos="-0.5, -0.125", href="/montage_fit.html")

microscope = Custom("Microscope", "_my_icons/TEM.png", pin="true", pos="-0.5, 0.75")
stage = Custom("Stage", "_my_icons/stage.png", pin="true", pos="-0.75, 0.75")
camera = Custom("Camera", "_my_icons/camera.png", pin="true", pos="-1, 0.75")

with Cluster("Platform9", graph_attr={"bgcolor": "#b2ffc7"}):
    log = Loki("Log Server", pin="true", pos="0.25, -0.125", href="/log.html")
    ac_qc = Python("AC/QC", pin="true", pos="0, -0.125")

registry = Docker("Container Registry", pin="true", pos="-0.25, 0.5", href="/registry.html")
runner = Github("GitHub Actions", pin="true", pos="0, 0.5", href="/runner.html")

runner >> registry
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
operator << Edge() >> pyTEM
microscope << Edge() >> microscope_service
stage << Edge() >> stage_service
camera << Edge() >> camera_service
s3 << aloha >> tem_db
cpp_pipeline >> operator
cpp_pipeline >> QC_service >> pyTEM
cpp_pipeline >> montage_fit >> QC_service
montage_fit >> buffer

{% enddiagram %}

Most of the nodes in this diagram are hyperlinks to further documentation of this system.

This system primarily sends messages between services using the [STOMP protocul](https://stomp.github.io/) with the [Pigeon](https://pypi.org/project/pigeon-client/) library.
The configuration for this system as a whole is stored on GitHub at [AllenInstitute/TEM_config](https://github.com/AllenInstitute/TEM_config).
This repository includes both a Docker compose file for starting all the services that are part of the system, and the configuration files for the services.
