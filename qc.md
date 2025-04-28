---
layout: page
title: QC Service
type: task
sends:
    - qc.status
receives:
    - tile.statistics.focus
    - tile.statistics.histogram
    - tile.statistics.min_max_mean
    - tile.transform
assigned: Cameron
---

To allow [pyTEM](pyTEM.html) to easily determine if the quality of tiles is good, this service regularly sends status message to [pyTEM](pyTEM.html) on the [qc.status](topics.html#qc-status) topic.
This topic takes one of three values, `GOOD` meaning that imaging should continue, `STOP_AT_END` meaning that imaging should be stopped once the current montage is complete, and `STOP_NOW` when imaging should be stopped immediately.
This service determines which value to send by looking at the statistical values sent by the [image processing pipeline](pipeline.html).
In the future, the measurements from the multi-system monitoring system could be included as well.
