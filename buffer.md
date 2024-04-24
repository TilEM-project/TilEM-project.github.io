---
title: Tile Upload Buffer
layout: page
receives:
    - tile.processed
sends:
    - buffer.status
---

The purpose of the upload buffer service is to allow the microscope to continue imaging when the internet connection is insufficient for real-time tile upload.
A functional internet connection is still required for [pyTEM](/pytem.html) to run.
The buffer service has four primary responsibilities:

1. Upload each tile with appropriate metadata to the [aloha](/aloha.html) lambda function.
1. Check that aloha successfully processed the tile.
1. Delete the tile (and intermediate files) from the SSD.

This process should be triggered whenever a tile is finished processing by the [image processing pipeline](/pipeline.html), via a message through the [broker](/broker.md).
Additionally, messages should be regularly published on the [`buffer.status`](/topics.html#buffer-status) topic about the state of the buffer.