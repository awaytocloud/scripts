#!/bin/zsh

# Auxiliary script for iTerm2 that automates VPN and SSH connectivity. It establishes a VPN
# connection before initiating the SSH session and disconnects it automatically when the session ends.

# Due to iTerm2 limitations the $PATH environment variable can not be checked. Specifying
# the absolute path to the Tailscale binary instead:

BIN_PATH=

# Specifying SSH session details:

KEY=
PORT=
USER=
HOST=

# Starting up Tailscale client

printf 'Establishing Tailscale connection...\n\n'

"$BIN_PATH" up

# Checking whether Tailscale connection is established
# (Connection status is obtained by verifying the local machine's IPv4)

"$BIN_PATH" status --peers=false | grep "$("$BIN_PATH" ip --4)" &> /dev/null

if [[ $? -eq 0 ]]; then
	printf '\033[1;32mTailscale connection established\033[0m\n\n'
else
	printf '\033[1;31mError: Check Tailscale settings! Exiting in 15s...\033[0m\n\n'
	sleep 15 && exit 1
fi

# Starting up SSH client

printf 'Creating SSH session...\n\n'

ssh -i "$KEY" -p "$PORT" "$USER"@"$HOST"

# Checking SSH session results

if [[ $? -eq 0 ]]; then
	printf '\033[1;32m\nSSH session ended normally\033[0m\n\n'
else
	printf '\033[1;33m\nWarning: SSH session ended unexpectedly\033[0m\n\n'
fi

# Shutting down Tailscale client

printf 'Closing Tailscale connection...\n\n'

"$BIN_PATH" down

# Checking Tailscale connection status

if [[ $? -eq 0 ]]; then
	printf '\033[1;32mTailscale connection closed successfully. Exiting in 15s...\033[0m\n\n'
	sleep 15 && exit 0
else
	printf '\033[1;31mError: Check Tailscale settings! Exiting in 15s...\033[0m\n\n'
	sleep 15 && exit 1
fi
