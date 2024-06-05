---
title: Aloha
layout: page
type: task
assigned: Russel
github: AllenInstitute/aloha
---

Aloha is an AWS Lambda Function which takes raw tile images uploaded from the [tile upload buffer]({{ '/buffer.html' | relative_url }}), and saves down-sampled and compressed image to AWS S3 for use in [Neuroglancer](https://github.com/google/neuroglancer) and other tools.
This service performs the down-sampling and compression, saves the compressed images to S3, and places the S3 URIs in [TEM DB]({{ '/tem_db.html' | relative_url }}). It is also responsible for updating image metadata in TEM DB.