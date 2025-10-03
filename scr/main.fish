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

# Load shared libraries
begin
	set --global fish_function_path_backup {$fish_function_path}

	set --local local_libraries "$(systemd-path system-library-arch)"'/'"$(status current-function)"
	set --global --append fish_function_path {local_libraries} # Add main-directory to functions path
	set --global --append fish_function_path (fd . -d "$(local_libraries)") # Add sub-directories to functions paht
end

# Configure operation
## Environment Variables
if set -q VERBOSE
	set --global --export VERBOSE -- '--verbose'
end

if ! set -q output_prefix # Define output
	set --local output_prefix "$(status current-function)"': '

	if ! status is-interactive
		set --global output_prefix "$(status basename | path basename --no-extension)"': '"$(status current-function)"': '
	end
end
