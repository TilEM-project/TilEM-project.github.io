---
layout: page
title: Container Registry
type: task
assigned: Cameron
---

As Docker containers are already automatically built and tested in the lab using a self-hosted GitHub Actions [runner](/runner.html), it is beneficial to keep the containers stored on site as well.
The same machine used for the GitHub runner, is also running a [container registry](https://hub.docker.com/_/registry).
This allows images to be pulled quickly as they are only transferred over the local network.