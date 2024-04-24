---
title: Aloha
layout: page
---

Aloha is a service that takes raw tile images from the S3 bucket, and saves downsampled and compressed image for use in [Neuroglancer](https://github.com/google/neuroglancer) and other tools.
This service finds tiles without downsampled images in [TEM DB](/tem_db.html), performs the downsampling and compression, saves the compressed images to S3, and places the S3 URIs in [TEM DB](/tem_db.html).