import pyautogui

print("Move your mouse to the desired position and press Ctrl+C to stop.")

try:
    while True:
        # Get the current mouse position
        x, y = pyautogui.position()
        print(f"Mouse position: ({x}, {y})", end="\r")  # Print coordinates in real time
except KeyboardInterrupt:
    print("\nStopped. Use the last shown coordinates.")
