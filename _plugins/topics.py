from importlib.metadata import entry_points
import json
import jsonschema2md
import re

jsonschema2md.Parser.locale = "en_US"

parser = jsonschema2md.Parser(header_level=2)


def collect_messages():
    messages = {}
    for entrypoint in entry_points(group="pigeon.msgs"):
        messages.update(entrypoint.load())
    return messages


def main():
    try:
        messages = collect_messages()
        schemas = {topic: message.model_json_schema() for topic, message in messages.items()}
        for topic, schema in schemas.items():
            schema["title"] = topic
        documentation = {topic: "\n".join(parser.parse_schema(schema)) for topic, schema in schemas.items()}
        for topic in documentation:
            documentation[topic] = re.sub(r"\[\#\/\$defs\/(.*?)\]", r"[\1]", documentation[topic])
        print(json.dumps(documentation))
    except Exception as e:
        print("{}")
        raise e


if __name__ == "__main__":
    main()
