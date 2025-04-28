---
layout: page
title: Unassigned
---

{% for service in site.pages -%}
{%- if service.type == "task" -%}
{%- unless service.assigned -%}
* [{{ service.title }}]({{ service.url | relative_url }})
{% endunless -%}
{%- endif -%}
{% endfor %}
