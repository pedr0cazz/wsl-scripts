# WSL2 Keep-Alive GUI Concept

This Python script provides a simple graphical interface to keep WSL2 alive by periodically checking the status of Nginx.  
It acts as a "keep-alive" tool to prevent WSL2 from shutting down automatically due to inactivity.

## How it works

- Every X seconds (configurable at the top of the script), the program runs a command in WSL2 to check if Nginx is running.
- As long as the script is open, WSL2 remains active.
- A timer shows the time since the last WSL request.

## Usage

1. Install Python on Windows.
2. Run:
   ```sh
   python wsl_nginx_gui.py
   ```
3. Adjust the check interval by changing the `CHECK_INTERVAL_MS` variable at the top of the script.