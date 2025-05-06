#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pandas",
# ]
# ///

from pathlib import Path

import pandas as pd


def main() -> None:
    items_to_remove = ["D5451621620000", "U520A3015203_--A_DEF01_RH UPPER REAR RAIL", "U671A6001232_--A_DEF01_COUPLING TUBE", "V3611121922000", "V4712005120000", "V5311679220000", "V5711075300000", "V9241639220000", "V9241709820200", "V9241741520400", "V9241974020000", "V9241975320200", "V9242609120800"]
    csv_filepath = Path(
        "/home/maccou/work/3d/3d_segmentation/data/models_list/sheet_metal_subset.csv"
    )
    delete_csv_lines(csv_filepath, items_to_remove)


def delete_csv_lines(csv_filepath: Path, items_to_remove: list[str]) -> None:
    data = pd.read_csv(csv_filepath)
    # Remove rows where 'pn' is in items_to_remove
    data = data[~data["pn"].isin(items_to_remove)]
    data.to_csv(csv_filepath, index=False)


if __name__ == "__main__":
    main()
