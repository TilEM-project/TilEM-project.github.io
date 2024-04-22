---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
---

This is an overview diagram of image processing system:

{% diagram %}
from diagrams.programming.language import Cpp, Python

with Cluster("Intel TBB", graph_attr={"bgcolor": "#FFE0B2"}):
    input = Python("Message Reciever", pin="true", pos="0, 0", href="#message-reciever")
    process = Cpp("Load Image", pin="true", pos="0.5, 0", href="#load-image")
    output = Python("Message Sender", pin="true", pos="1, 0")

input >> process >> output
{% enddiagram %}

### Message Reciever

This node recieves the metadata for a tile to process and passes the filename to the load image node.

### Load Image

This node uses openCV to load an image based on a recieved file path.