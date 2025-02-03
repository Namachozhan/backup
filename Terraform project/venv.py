import os
import subprocess
import sys
import argparse

def create_virtual_environment(venv_dir):
    try:
        print(f"Creating Python virtual environment at '{venv_dir}'")
        
        # Run the Python command to create the virtual environment
        subprocess.run([sys.executable, "-m", "venv", venv_dir], check=True)
        
        print(f"Python virtual environment created successfully at '{venv_dir}'")
    
    except subprocess.CalledProcessError as e:
        print(f"Error creating virtual environment: {e}")

def main():
    # Setup argument parser
    parser = argparse.ArgumentParser(description="Create a Python virtual environment.")
    parser.add_argument('--path', required=True, help="Directory where the virtual environment should be created")
    
    # Parse arguments
    args = parser.parse_args()
    
    venv_dir = args.path

    # Check if the directory exists, if not create it
    if not os.path.exists(venv_dir):
        os.makedirs(venv_dir)

    # Create the virtual environment
    create_virtual_environment(venv_dir)

if __name__ == "__main__":
    main()
