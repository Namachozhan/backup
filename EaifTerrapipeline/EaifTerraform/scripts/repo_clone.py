import argparse
import json
import os
import shutil
import subprocess
import re

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
        # Create the new directory in the target repo if it doesn't exist
        target_new_dir = os.path.join(target_dir, new_target_dir)
        if not os.path.exists(target_new_dir):
            os.makedirs(target_new_dir)
            print(f"Created new directory {target_new_dir} in the target repo.")
       
        # Move the specified directory (copy the entire directory itself)
        target_experiment_dir = os.path.join(target_new_dir, os.path.basename(copy_dir_name))
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

def copy_dist_to_c_drive(source_dist_dir, c_drive_dist_dir):
    """Copies the dist directory from source to C:\backup\dist."""
    try:
        if os.path.exists(source_dist_dir):
            # Create the target directory if it doesn't exist
            if not os.path.exists(c_drive_dist_dir):
                os.makedirs(c_drive_dist_dir)
            
            # Copy the entire dist directory to C:\backup\dist
            shutil.copytree(source_dist_dir, c_drive_dist_dir, dirs_exist_ok=True)
            print(f"Copied dist directory from {source_dist_dir} to {c_drive_dist_dir}")
            return c_drive_dist_dir
        else:
            print(f"Source dist directory {source_dist_dir} does not exist.")
            return None
    except Exception as e:
        print(f"Error copying dist directory: {e}")
        return None

def find_latest_utility(dist_dir):
    """Find the latest utility based on the version in the file name."""
    try:
        # List all .tar.gz files in the dist_dir
        files = [f for f in os.listdir(dist_dir) if f.endswith('.tar.gz')]
        if not files:
            print("No .tar.gz files found.")
            return None
        
        # Extract version numbers from filenames using regex
        utilities = []
        for file in files:
            match = re.match(r'utilities-(\d+\.\d+)\.tar\.gz', file)
            if match:
                version = match.group(1)
                utilities.append((version, file))
        
        if not utilities:
            print("No valid utilities found.")
            return None
        
        # Sort utilities based on the version number (latest first)
        utilities.sort(key=lambda x: tuple(map(int, x[0].split('.'))), reverse=True)
        latest_utility = utilities[0][1]
        print(f"Latest utility is: {latest_utility}")
        return os.path.join(dist_dir, latest_utility)
    except Exception as e:
        print(f"Error finding latest utility: {e}")
        return None

def install_package_from_dist(latest_utility_path):
    """Install the .tar.gz package from the dist directory."""
    try:
        print(f"Found utility: {latest_utility_path}")
        subprocess.run(['pip', 'install', latest_utility_path], check=True)
        print(f"Successfully installed {latest_utility_path} using pip.")
        return True
    except Exception as e:
        print(f"Error installing utility from {latest_utility_path}: {e}")
        return False

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
    target_dir = os.path.expanduser('~/Documents/Data and AI')  # Change this to a subdirectory

    # Define the dist directory (source location) and the C:\ backup location
    source_dist_dir = os.path.expanduser('~/Documents/source_repo/Componentized/AI/Utilities/dist')  # Expand the path to full
    c_drive_dist_dir =  os.path.expanduser('C:/dist')  # Path where the dist directory will be copied on C: drive

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

    # Copy the dist directory to C: drive
    copied_dist_dir = copy_dist_to_c_drive(source_dist_dir, c_drive_dist_dir)
    if not copied_dist_dir:
        print("Failed to copy dist directory. Stopping process.")
        return

    # Find the latest utility in the copied dist directory and install it
    latest_utility_path = find_latest_utility(c_drive_dist_dir)
    if not latest_utility_path:
        print("Failed to find the latest utility. Stopping process.")
        return

    # Install the latest utility
    if not install_package_from_dist(latest_utility_path):
        print("Package installation failed. Stopping process.")
        return

    # Delete the source repo directory permanently
    delete_directory(source_dir)
    delete_directory(c_drive_dist_dir)
 
    print("Process completed successfully.")
 
if __name__ == '__main__':
    main()
