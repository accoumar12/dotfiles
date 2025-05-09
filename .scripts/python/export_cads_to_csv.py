#!/usr/bin/env -S uv run --script

import json
import csv
import os
from pathlib import Path

def main():
    json_file_path = Path('./cads.json')
    csv_file_path = Path('./cads.csv')
    
    # Read the JSON file
    try:
        with open(json_file_path, 'r') as json_file:
            cad_data = json.load(json_file)
    except FileNotFoundError:
        print(f"Error: Could not find {json_file_path}")
        return
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON format in {json_file_path}")
        return
    
    # Extract manufacturer and part number from each file path
    csv_data = []
    for file_path in cad_data:
        parts = file_path.split('/')
        if len(parts) >= 2:
            manufacturer = parts[0]
            # Extract part number by removing file extension
            part_number = os.path.splitext(parts[1])[0]
            csv_data.append([manufacturer, part_number])
    
    # Write to CSV file
    try:
        with open(csv_file_path, 'w', newline='') as csv_file:
            # Configure CSV writer to quote all fields
            csv_writer = csv.writer(csv_file, quoting=csv.QUOTE_ALL)
            # Write header
            csv_writer.writerow(['manufacturer', 'pn'])
            # Write data rows
            csv_writer.writerows(csv_data)
        
        print(f"Successfully created CSV file: {csv_file_path}")
        print(f"Exported {len(csv_data)} records")
    except Exception as e:
        print(f"Error writing to CSV file: {e}")

if __name__ == "__main__":
    main()