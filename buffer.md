---
title: Upload Buffer
layout: page
receives:
    - tile.processed
---

The purpose of the upload buffer service is to allow the microscope to continue imaging when the internet connection is insufficient for real-time tile upload.
A functional internet connection is still required for [pyTEM](/pytem.html) to run.
The buffer service has four primary responsibilities:

1. Upload the tiles to the appropriate S3 bucket.
1. Update TEM DB with the appropriate S3 URI.
1. Delete the tile (and intermediate files) from the SSD.

This process should be triggered whenever a tile is finished processing by the [image processing pipeline](/pipeline.html), via a message through the [broker](/broker.md).