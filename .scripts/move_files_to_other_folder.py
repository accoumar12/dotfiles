import shutil
from pathlib import Path


def move_files_to_other_folder(
    source_directory: Path,
    destination_directory: Path,
) -> None:
    destination_directory.mkdir(parents=True, exist_ok=True)

    for file in source_directory.iterdir():
        if file.is_file():
            shutil.move(file, destination_directory)


def main() -> None:
    source_directory = Path(
        "/home/maccou/stage_maccou/deep_mesh/data/renault_ca_components/all_images",
    )
    destination_directory = Path(
        "/home/maccou/stage_maccou/deep_mesh/data/renault_ca_components/filtered_images",
    )
    move_files_to_other_folder(source_directory, destination_directory)


if __name__ == "__main__":
    main()
