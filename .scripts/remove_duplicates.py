import pandas as pd

def process_csv(file_path: str, export_path: str) -> None:
    data = pd.read_csv(file_path)
    duplicates = data.duplicated().sum()
    print(f"Found {duplicates} duplicates")

    data = data.drop_duplicates()
    data.to_csv(export_path, index=False)

def main() -> None:
    file_path = "/home/maccou/Bureau/stage-maccou/data/mv/triplets.csv"
    export_path = "/home/maccou/Bureau/stage-maccou/data/mv/triplets.csv"
    process_csv(file_path, export_path)

if __name__ == "__main__":
    main()