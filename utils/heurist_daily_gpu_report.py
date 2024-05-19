import requests
import pandas as pd
import logging
from prettytable import PrettyTable
from termcolor import colored

# Setup logging
logging.basicConfig(level=logging.WARNING, format='%(asctime)s - %(levelname)s - %(message)s')

api_url = 'https://stats-caller.onrender.com/'

def fetch_data(api_url):
    """Fetch data from the API, requesting non-encoded response."""
    headers = {'Accept-Encoding': 'identity'}  # Request non-encoded response
    try:
        response = requests.get(api_url, headers=headers)
        response.raise_for_status()

        # Process the JSON data directly
        data = response.json()
        return pd.DataFrame(data['minerDetails'])
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        raise

def process_data(df):
    """Process the data to calculate statistics."""
    if df.empty:
        logging.warning("No data to process.")
        return df
    
    numeric_cols = ['total_image_count', 'total_text_count', 'last_24_hours_image_win_rate', 'last_24_hours_text_win_rate']
    df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric, errors='coerce')
    
    # Aggregate data
    grouped = df.groupby('hardware').agg({
        'miner_id': 'count',
        'total_image_count': 'sum',
        'total_text_count': 'sum',
        'last_24_hours_image_win_rate': 'mean',
        'last_24_hours_text_win_rate': 'mean'
    }).rename(columns={'miner_id': 'number_of_miners'}).reset_index()
    
    return grouped

def display_data_as_table(df):
    """Display data in a colorful and formatted table with vertical lines for clarity."""
    if df.empty:
        logging.warning("No data to display.")
        return

    # Sorting data to show by total_image_count, total_text_count, image win rate, and text win rate
    df_sorted = df.sort_values(['total_image_count', 'total_text_count', 'last_24_hours_image_win_rate', 'last_24_hours_text_win_rate'], ascending=[False, False, False, False])

    # Use PrettyTable to format the output
    table = PrettyTable()
    table.field_names = [colored(col, 'blue', attrs=['bold']) for col in df_sorted.columns]
    table.align = "l"

    for _, row in df_sorted.iterrows():
        # Only apply color to win rate values
        colored_row = [
            str(row['hardware']),
            str(row['number_of_miners']),
            f"{row['total_image_count']:,}",
            f"{row['total_text_count']:,}",
            colored(f"{row['last_24_hours_image_win_rate']:.2f}", 'green' if row['last_24_hours_image_win_rate'] > 0.5 else 'red'),
            colored(f"{row['last_24_hours_text_win_rate']:.2f}" if pd.notna(row['last_24_hours_text_win_rate']) else 'nan', 'green' if pd.notna(row['last_24_hours_text_win_rate']) and row['last_24_hours_text_win_rate'] > 0.5 else 'red')
        ]
        table.add_row(colored_row)
    print(f"\nExtracting data from {api_url} to show GPU Stats for the last 24 hours:\n")
    print(table)

def main():
    
    try:
        data = fetch_data(api_url)
        processed_data = process_data(data)
        display_data_as_table(processed_data)
    except Exception as e:
        logging.error(f"Failed to process data: {e}")

if __name__ == '__main__':
    main()
