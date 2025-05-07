#!/usr/bin/env -S uv run --script
from pathlib import Path


def main() -> None:
    reference_dir_path = Path("/home/maccou/work/3d/data/3D/stp/Renault_parts")
    target_dir_path = Path(
        "/home/maccou/work/3d/3d_segmentation/data/stp/sheet_metal",
    )
    # we list the files in the reference directory, and we remove them inside the target directory
    reference_files = {file.name for file in reference_dir_path.iterdir()}
    for file in reference_files:
        target_file = target_dir_path / file
        if target_file.exists():
            target_file.unlink()
            print(f"Removed {target_file}")


if __name__ == "__main__":
    main()
