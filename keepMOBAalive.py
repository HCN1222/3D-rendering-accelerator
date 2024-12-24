import pyautogui
import time

# Function to simulate mouse click
def keep_program_alive(interval=60):
    try:
        while True:
            # Move the mouse slightly and click
            pyautogui.move(1, 1)  # Move the mouse by 1 pixel
            pyautogui.move(-1, -1)
            pyautogui.click()
            print("Mouse clicked to keep the program alive.")
            time.sleep(interval)  # Wait for the specified interval
    except KeyboardInterrupt:
        print("Program stopped by user.")

# Call the function with a 60-second interval
keep_program_alive(interval=60)
