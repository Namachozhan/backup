import argparse
import json
import os
 
# Function to update the .config file
def update_config(config_path, json_input):
    # Resolve the absolute path and ensure the file exists
    config_path = os.path.abspath(config_path)
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"The file at '{config_path}' does not exist. Check the path and permissions.")
    if not os.access(config_path, os.R_OK | os.W_OK):
        raise PermissionError(f"Insufficient permissions to access the file: '{config_path}'")
 
    # Open and read the .config file
    with open(config_path, 'r') as file:
        config_lines = file.readlines()
 
    # Parse the JSON input
    data = json.loads(json_input)
    # Iterate over the config lines and update based on the JSON keys
    for i, line in enumerate(config_lines):
        # Ignore lines that are section headings
        if line.strip().startswith('[') and line.strip().endswith(']'):
            continue
        # Split the line at '=' to get the key-value pairs
        key_value = line.split('=') if '=' in line else None
        if key_value and len(key_value) == 2:
            key = key_value[0].strip()
            if key in data:
                # Update the line with the corresponding value from the JSON input
                config_lines[i] = f"{key} = {data[key]}\n"
    # Write the updated content back to the .config file
    with open(config_path, 'w') as file:
        file.writelines(config_lines)
 
# Main function to handle argument parsing and invoke the update
def main():
    # Define the path to the .config file
    path = "C:/Users/chozhan1/Documents/.config"  # Update this to the correct file path
 
    # Ensure the file exists and is accessible
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('--json', required=True, help='JSON input')
        args = parser.parse_args()
        # Call the function to update .config
        update_config(path, args.json)
    except FileNotFoundError as e:
        print(f"Error: {e}")
    except PermissionError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
 
# Ensure the main function is called when the script runs
if __name__ == "__main__":
    main()

