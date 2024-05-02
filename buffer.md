---
title: Tile Upload Buffer
layout: page
type: task
receives:
    - tile.processed
    - tile.statistics.focus
    - tile.statistics.histogram
    - tile.statistics.min_max_mean
    - tile.transform
sends:
    - buffer.status
---

Tile images and metadata must be stored during montaging, then uploaded after montaging is complete.
If the montage is aborted, this data should then be discarded.
Uploads should happen asynchronously such that the microscope can continue imaging when the internet connection is insufficient for real-time tile upload.
An internet connection is still required for [pyTEM](/pytem.html) to function.

The buffer service is responsible for the following tasks:

1. Store tile metadata during montaging.
1. After montaging:
    1. Upload metadata to [TEM DB](/tem_db.html).
    1. Upload each tile to the [aloha](/aloha.html) service.
    1. Check that aloha successfully processed the tile.
    1. Delete the tile (and intermediate files) from the SSD.
1. If montaging is aborted: delete all tiles (and intermediate files).

Processed tiles and metadata should be received from the [image processing pipeline](/pipeline.html) via a multitude of topics listed above via the [broker](/broker.md).
Additionally, messages should be regularly published on the [`buffer.status`](/topics.html#buffer-status) topic about the state of the buffer.