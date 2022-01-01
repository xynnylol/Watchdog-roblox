# Watchdog
Watchdog can help you see every single action a script does. Even if its obfuscated. Just add this `setfenv(1,require(script.Watchdog){script=script}.__ENV);` line to the top of the script you want to debug and watch the output window as you see what the script does.
