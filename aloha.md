---
title: Aloha
layout: page
---

Aloha is an AWS Lambda Function which takes raw tile images uploaded from the [tile upload buffer](/buffer.html), and saves downsampled and compressed image to AWS S3 for use in [Neuroglancer](https://github.com/google/neuroglancer) and other tools.
This service performs the downsampling and compression, saves the compressed images to S3, and places the S3 URIs in [TEM DB](/tem_db.html).