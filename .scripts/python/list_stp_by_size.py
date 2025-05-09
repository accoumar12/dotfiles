#!/usr/bin/env -S uv run --script

import csv
import os
from pathlib import Path
import sys

def main():
    csv_file_path = Path('./cads.csv')
    stp_base_dir = Path("/home/maccou/work/3d/data/3D/stp")
    
    if not csv_file_path.exists():
        print(f"Error: CSV file {csv_file_path} not found.")
        return
        
    if not stp_base_dir.exists():
        print(f"Error: STP base directory {stp_base_dir} not found.")
        return
        
    # Read the CSV file
    file_info = []
    try:
        with open(csv_file_path, 'r', newline='') as f:
            reader = csv.reader(f)
            # Skip header
            next(reader, None)
            
            for row in reader:
                if len(row) >= 2:
                    manufacturer = row[0].strip('"')
                    part_number = row[1].strip('"')
                    
                    # Check for both .stp and .STP extensions
                    potential_paths = [
                        stp_base_dir / manufacturer / f"{part_number}.stp",
                        stp_base_dir / manufacturer / f"{part_number}.STP"
                    ]
                    
                    for file_path in potential_paths:
                        if file_path.exists():
                            size = file_path.stat().st_size
                            file_info.append((file_path, size))
                            break
                    
    except Exception as e:
        print(f"Error reading CSV file: {e}")
        return
        
    if not file_info:
        print("No matching STP files found.")
        return
        
    file_info.sort(key=lambda x: -x[1])
    
    # Print files with their sizes
    print("\nSTP Files sorted by size (smallest to largest):\n")
    print(f"{'File Path':<60} {'Size':<15}")
    print("-" * 75)
    
    for file_path, size in file_info:
        size_str = format_size(size)
        print(f"{str(file_path):<60} {size_str:<15}")
        
    print(f"\nTotal files: {len(file_info)}")
    
def format_size(size_bytes):
    """Format file size in human-readable format"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024 or unit == 'GB':
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024

if __name__ == "__main__":
    main()
