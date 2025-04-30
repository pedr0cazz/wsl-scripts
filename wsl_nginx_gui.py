import tkinter as tk
import subprocess
import time

# Around 15000 ms it will timeout and the browser wont open blog.test anymore
CHECK_INTERVAL_MS = 12000
last_wsl_request = None
main_window = None
label_result = None
label_clock = None

def check_nginx():
    global last_wsl_request
    try:
        result = subprocess.run(
            ["wsl", "bash", "-c", "systemctl is-active nginx"],
            capture_output=True, text=True, timeout=5
        )
        status = result.stdout.strip()
        if status == "active":
            last_wsl_request = time.time()
            label_result.config(text="Nginx is running ✅", fg="green")
        else:
            label_result.config(text="Nginx is NOT running ❌", fg="red")
    except Exception as e:
        label_result.config(text=f"Error: {e}", fg="orange")
    # Agenda próxima checagem usando a variável global
    main_window.after(CHECK_INTERVAL_MS, check_nginx)

def update_uptime_clock():
    if last_wsl_request:
        elapsed = int(time.time() - last_wsl_request)
        label_clock.config(text=f"Last WSL request: {elapsed} seconds ago")
    else:
        label_clock.config(text="Waiting for first WSL request...")
    main_window.after(1000, update_uptime_clock)

main_window = tk.Tk()
main_window.title("WSL2 Nginx Status Checker")

label_result = tk.Label(main_window, text="Checking Nginx status...", font=("Arial", 12))
label_result.pack(padx=20, pady=10)

label_clock = tk.Label(main_window, text="", font=("Arial", 10), fg="blue")
label_clock.pack(padx=20, pady=10)

check_nginx()
update_uptime_clock()

main_window.mainloop()