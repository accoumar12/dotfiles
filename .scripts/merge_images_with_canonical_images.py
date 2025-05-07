from __future__ import annotations

import shutil
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import os


def copy_images(
    images_dir: str | os.PathLike,
    canonical_images_dir: str | os.PathLike,
    dest_dir: str | os.PathLike,
) -> None:
    dest_dir.mkdir(parents=True, exist_ok=True)

    # Copy the images from the first directory
    for image_file in images_dir.iterdir():
        if image_file.is_file():
            shutil.copy(image_file, dest_dir)

    # Copy the images from the second directory and append "_canonical" to the file names
    for image_file in canonical_images_dir.iterdir():
        if image_file.is_file():
            suffix = image_file.suffix
            new_file_name = f"{image_file.name.split('.')[0]}_canonical.stp{suffix}"
            shutil.copy(image_file, dest_dir / new_file_name)


def main() -> None:
    images_dir = Path(
        "/home/maccou/stage_maccou/deep_mesh/data/renault_ca_components/images",
    )
    canonical_images_dir = Path(
        "/home/maccou/stage_maccou/deep_mesh/data/renault_ca_components/images_canonical",
    )
    dest_dir = Path(
        "/home/maccou/stage_maccou/deep_mesh/data/renault_ca_components/all_images",
    )
    copy_images(images_dir, canonical_images_dir, dest_dir)


if __name__ == "__main__":
    main()
