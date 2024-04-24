---
layout: page
title: Github Actions Runner
---

To allow automated building and testing of primarily the [image processing pipeline](/pipeline.html), a GitHub Actions runner with a GPU is required.
As these are not available from GitHub, a self-hosted GitHub runner was set up.
A Docker image [registry](/registry.html) is also running on the same machine.