import argparse
import json
import os
import shutil
import subprocess

def clone_repo(repo_url, target_dir):
    """Clones the given repo to the target directory."""
    try:
        subprocess.run(['git', 'clone', repo_url, target_dir], check=True)
        print(f"Cloned {repo_url} into {target_dir}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to clone {repo_url}: {e}")
        return False
    return True

def move_experiment_dir(source_dir, target_dir, copy_dir_name, new_target_dir):
    """Moves the specified directory from the source repo to the target repo (root level)."""
    experiment_dir = os.path.join(source_dir, copy_dir_name)
    
    if os.path.exists(experiment_dir):
        # Create the new directory in the target repo
        target_new_dir = os.path.join(target_dir, new_target_dir)
        if not os.path.exists(target_new_dir):
            os.makedirs(target_new_dir)
            print(f"Created new directory {target_new_dir} in the target repo.")
        
        # Move the specified directory (copy or rename)
        target_experiment_dir = os.path.join(target_new_dir, copy_dir_name)
        shutil.copytree(experiment_dir, target_experiment_dir)
        print(f"Moved directory from {experiment_dir} to {target_experiment_dir}")
        return True
    else:
        print(f"Directory '{copy_dir_name}' not found in {source_dir}")
        return False

def get_key_value(json_data, key_name):
    """Fetch the value of a given key from a JSON object."""
    if key_name in json_data:
        return json_data[key_name]
    else:
        print(f"Key '{key_name}' not found in the JSON data.")
        return None

def delete_directory(directory_path):
    """Deletes a directory and its contents permanently."""
    try:
        # Change the permissions of all files in the directory to allow deletion
        for root, dirs, files in os.walk(directory_path, topdown=False):
            for name in files:
                file_path = os.path.join(root, name)
                os.chmod(file_path, 0o777)  # Grant full permissions to the file
            for name in dirs:
                dir_path = os.path.join(root, name)
                os.chmod(dir_path, 0o777)  # Grant full permissions to the directory
        
        # Now try to delete the directory
        shutil.rmtree(directory_path)
        print(f"Deleted directory: {directory_path}")
    except Exception as e:
        print(f"Error deleting directory {directory_path}: {e}")

def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Clone repos and move directories.")
    parser.add_argument('json_input', type=str, help="JSON input string")
    args = parser.parse_args()

    # Parse the JSON input string into a Python dictionary
    try:
        json_data = json.loads(args.json_input)
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
        return

    # Retrieve the source and target repo URLs and the other necessary parameters from the JSON
    source_repo_url = get_key_value(json_data, 'source_repo')
    target_repo_url = get_key_value(json_data, 'target_repo')
    copy_dir_name = get_key_value(json_data, 'copy_dir_name')
    new_target_dir = get_key_value(json_data, 'new_target_dir')  # Get the new directory name for the target repo

    if not source_repo_url or not target_repo_url or not copy_dir_name or not new_target_dir:
        print("Missing source, target repo URLs, directory name, or new target directory name. Cannot proceed.")
        return

    # Define the directories for cloning
    source_dir = os.path.expanduser('~/Documents/source_repo')  # Change this to a subdirectory
    target_dir = os.path.expanduser('~/Documents/data and AI')  # Change this to a subdirectory

    # Clone both the source and target repos
    if not clone_repo(source_repo_url, source_dir):
        print("Cloning source repository failed. Stopping process.")
        return

    if not clone_repo(target_repo_url, target_dir):
        print("Cloning target repository failed. Stopping process.")
        return

    # Move the specified directory from source to target repo
    if not move_experiment_dir(source_dir, target_dir, copy_dir_name, new_target_dir):
        print("Failed to move directory. Stopping process.")
        return

    # Delete the source repo directory permanently
    delete_directory(source_dir)

    print("Process completed successfully.")

if __name__ == '__main__':
    main()
