import pandas as pd


def modify_csv(file_path: str, export_path: str) -> None:
    df = pd.read_csv(file_path)
    df = df.rename(
        columns={
            "anchor": "reference_id",
            "positive": "left_id",
            "negative": "right_id",
        },
    )

    df["label"] = "left"

    # Write the DataFrame back to CSV
    df.to_csv(export_path, index=False)


def main() -> None:
    file_path = "/home/maccou/Bureau/stage-maccou/data/labelizer_data/downloaded_triplets/triplets_map_10000.csv"
    export_path = "/home/maccou/Bureau/stage-maccou/data/labelizer_data/downloaded_triplets/triplets_modified.csv"
    modify_csv(file_path, export_path)


if __name__ == "__main__":
    main()
