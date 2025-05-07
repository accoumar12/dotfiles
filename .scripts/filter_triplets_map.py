import os
import pandas as pd

def filter_triplets_map(missing_ids_file: str | os.PathLike, triplets_map_file: str | os.PathLike, output_file: str | os.PathLike) -> None:
    missing_ids = pd.read_csv(missing_ids_file, header=None)
    triplets_map = pd.read_csv(triplets_map_file)

    # Rename the column in missing_ids to 'id'
    missing_ids.columns = ['id']

    # Remove rows from triplets_map where any id is in missing_ids
    triplets_map = triplets_map[~triplets_map['anchor'].isin(missing_ids['id']) &
                                ~triplets_map['positive'].isin(missing_ids['id']) &
                                ~triplets_map['negative'].isin(missing_ids['id'])]

    # Write the filtered triplets_map dataframe back to a CSV file
    triplets_map.to_csv(output_file, index=False)

def main() -> None:
    filter_triplets_map('missing_ids.csv', 'triplets_map.csv', 'filtered_triplets_map.csv')

if __name__ == "__main__":
    main()