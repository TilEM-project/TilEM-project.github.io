---
title: Broker
layout: page
type: task
assigned: Cameron
---

To enable messages to be passed between different services, a message broker is used.
The message broker seleced with [ActiveMQ Artemis](https://activemq.apache.org/components/artemis/) built by Apache.
This message broker has some very useful featues such as fixed size Journal which provides persistence, and possibly error recovery in the future.
It is also set up to provide one to many message passing which is essential for our application.

To communicate through the broker, services can use the [STOMP protocol](https://stomp.github.io/) using a [Python library](https://pypi.org/project/stomp-py/).
The broker will also be set up to allow anonymous connections.