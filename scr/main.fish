#!/usr/bin/env fish
# TODO
# • Libraries
# 	◦ Use `systemd-path` to determine library directory
# 	◦ Use a libary directory for functions
# 		‣ Append to fish's function search path
# 		‣ Also append subdirectories in the library directory
# 	◦ Create functions for commands (with different names to that of the original) to automatically use sudo if permission is denied and handle verbosity
# • Set link ownership to appropriate home directory (use `__fish_print_users`)
# • Allow interactive use
# • Make variables for customization

source "$(systemd-path system-library-arch)"'/smart-symlink/main.fish'
smart-symlink {$argv}
