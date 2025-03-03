import os
import subprocess
import sys
 
# Define the constant directory where the virtual environment will be created
venv_dir = r'C:\MYpythonvenv'
 
# Check if the virtual environment already exists
if not os.path.exists(venv_dir):
    # Create the virtual environment
    subprocess.run([sys.executable, "-m", "venv", venv_dir])
    print(f"Virtual environment created at {venv_dir}")
else:
    print(f"Virtual environment already exists at {venv_dir}")