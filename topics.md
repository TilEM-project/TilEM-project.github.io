---
layout: page
title: Topics
topics:
    tile.raw:
        description: This message is sent whenever a new tile is ready.
        payload:
            filepath:
                type: string
                description: The path where the raw tile is stored.
                example: /storage/tile.tiff
    tile.statistics.min_max_mean:
        description: This message contains simple statistics about a processed tile.
        payload:
            min:
                type: int
                description: The minimum pixel value
                example: 5
            max:
                type: int
                description: The maximum pixel value
                example: 249
            mean:
                type: int
                description: The mean pixel value
                example: 187
---

The topics are listed below.

{% include topics.md %}