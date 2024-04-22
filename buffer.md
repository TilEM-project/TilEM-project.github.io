---
title: Upload Buffer
layout: page
---

The purpose of the upload buffer service is to allow the microscope to continue running when the internet connection is insufficient for real-time tile upload.
The buffer service has four primary responsibilities:

1. Move processed tiles from SSD storage to a large hard disk drive.
1. Delete intermediate files from SSD storage.
1. Upload the tiles to the appropriate S3 bucket.
1. Update TEM DB with the appropriate S3 URI.
1. Delete the tile from the HDD.

This process should be triggered whenever a tile is finished processing by the [image processing pipeline](/pipeline.html), via a message through the [broker](/broker.md).