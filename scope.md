---
layout: page
title: Microscope Service
sends:
    - scope.status
receives:
    - scope.command
---

The microscope service interacts with the microscope, sending status information on the [`scope.status`](/topics.html#scope-status) topic, and accepting commands on the [`scope.command`](/topics.html#scope-command) topic.