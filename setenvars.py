#!/usr/bin/env python3
import os
import json

# Function to set variables if not already set
def set_variable(key, value):
    if key not in os.environ:
        os.environ[key] = value

# Check if the JSON file exists
json_file = "envars.json"  # Change this to your JSON file path
if os.path.exists(json_file) and os.path.isfile(json_file):
    # Read JSON file and set variables for the "system" scope
    with open(json_file, "r") as f:
        data = json.load(f)
        system_variables = data.get("system", {})
        for key, value in system_variables.items():
            set_variable(key, value)
else:
    print(f"JSON file not found: {json_file}")
    exit(1)

