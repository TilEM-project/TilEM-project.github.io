{% for topic in page.topics %}

### {{ topic[0] }}

{{ topic[1].description }}

#### Payload

{% for element in topic[1].payload -%}
* **{{ element[0] }}** ({{ element[1].type }}): {{ element[1].description }}
{% endfor %}

#### Example

```json
{
{%- for element in topic[1].payload -%}
{%- if element[1].type == "string" %}
    "{{ element[0] }}": "{{ element[1].example }}",
{%- else %}
    "{{ element[0] }}": {{ element[1].example }},
{%- endif -%}
{%- endfor %}
}
```

#### Senders

{% for page in site.pages %}
{%- if page.sends contains topic[0] -%}
* [{{ page.title }}]({{ page.url }})
{%- endif -%}
{% endfor %}

#### Recievers

{% for page in site.pages %}
{%- if page.recieves contains topic[0] -%}
* [{{ page.title }}]({{ page.url }})
{%- endif -%}
{% endfor %}
{% endfor %}