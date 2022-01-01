# Watchdog
Watchdog can help you see every single action a script does. Even if its obfuscated. Just add the watchdog module script into the script you want to debug and add this: `setfenv(1,require(script.Watchdog){script=script}._ENV);` to the top of the script and watch the output window as you see what the script does.
