---
layout: page
title: Topics
type: task
github: AllenInstitute/TEM_comms
assigned: Cameron
---

Messages in this system are sent and received using our [Pigeon](https://pypi.org/project/pigeon-client/) library.
The message definitions for each topic are listed below, and implemented in the library linked above.
These are also available on the Python package index as [`pigeon-tem-comms`](https://pypi.org/project/pigeon-tem-comms/).

{% assign versions = site.data.topics.TEM_comms | sort %}

{% for version in versions %}

# {{ version[0] }}

{% assign topics = version[1] | sort %}

<div class="mdl-card__supporting-text mdl-card--border">
    {{ content }}
    <ul>
        {% for topic in topics %}
            <li><a href="#{{ topic[0] | replace: '.', '-' }}">{{ topic[0] }}</a></li>
        {% endfor %}
    </ul>
</div>

{% for topic in topics %}
<div class="mdl-card__supporting-text mdl-card--border topic-container">
{{ topic[1] | markdownify }}

<h4>Sender</h4>
<ul>
{% for page in site.pages %}
{% if page.sends contains topic[0] %}
<li><a href="{{ page.url | relative_url }}">{{ page.title }}</a></li>
{% endif %}
{% endfor %}
</ul>

<h4>Receivers</h4>
<ul>
{% for page in site.pages %}
{% if page.receives contains topic[0] %}
<li><a href="{{ page.url | relative_url }}">{{ page.title }}</a></li>
{% endif %}
{% endfor %}
</ul>
</div>
{% endfor %}

{% endfor %}
