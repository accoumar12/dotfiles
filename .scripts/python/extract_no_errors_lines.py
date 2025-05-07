#!/usr/bin/env -S uv run --script
import json

# Define the input and output file names
input_file = "/home/maccou/work/3d/3d-analytics/tests/full/scopes/machining_airbus/expected.jsonl"
output_file = (
    "/home/maccou/work/3d/3d-analytics/tests/full/scopes/machining_airbus/new_cads.json"
)

# Initialize an empty list to store valid pns
valid_pns = []

# Open the input file and process each line
with open(input_file) as f:
    for line in f:
        line = line.strip()  # Remove any surrounding whitespace
        if "errors" in line:
            continue
        data = json.loads(line)
        pn = data["pn"]
        valid_pns.append(pn)


# Write the valid_pns list to the output JSON file
with open(output_file, "w") as f:
    json.dump(valid_pns, f, indent=2)

print(f"Successfully saved {len(valid_pns)} part numbers to {output_file}")
