#!/usr/bin/env fish
# TODO
# • Respect `$VERBOSE`
# • Set link ownership to appropriate home directory
# • Libraries
# 	◦ Use a libary directory for functions
# 		‣ Append to fish's function search path
# 		‣ Also append subdirectories in the library directory
# 	◦ Use `systemd-path` to determine library directory

function exit_on_error --description 'Exit the script on error to prevent further mis-execution' --on-event fish_postexec
	if test {$status} -ne 0
		exit 1
	end
end


# Handle Arguments
## Switches
### Parse
argparse 'v/verbose' 'h/help' -- $argv


### Individual
#### Help
if set -q _flag_help
	echo 'Smartly symlink SOURCE_DIR to TARGET.'\n
	set_color --bold --underline; echo -n 'Usage:'; set_color normal; echo ' '(status current-function)' [OPTION] SOURCE_DIR TARGET'\n
	set_color --bold --underline; echo 'Arguments:'; set_color normal; echo \t'<paths>…'\n

	set_color --bold --underline; echo 'Options:'; set_color normal
	set_color --bold; echo -n -- '  -h'; set_color normal; echo -n ', '; set_color --bold; echo -- '--help'; set_color normal
	echo \t'Print help'
	set_color --bold; echo -n -- '  -v'; set_color normal; echo -n ', '; set_color --bold; echo -- '--verbose'; set_color normal
	echo -n \t'explicitly state what is being done'\n\t'[Env: '; set_color --italics; echo -n 'VERBOSE'; set_color normal; echo ']' 

	return 0
end


#### Verbose
if set -q _flag_verbose _flag_v
	set --export --global VERBOSE
end


## Positional
### 1 argument → Set current directory as source
if test (count {$argv}) -eq 1
	set --global source_dir $PWD
	set --global target_dir (realpath {$argv[1]})
### 2 argument → Set 1st argument as Source & 2nd argument as Target 
else if test (count {$argv}) -eq 2
	set --global source_dir (realpath {$argv[1]})
	set --global target_dir (realpath {$argv[2]})
end
### argument count != 1 or 2 → throw error
else
	echo 'Invalid number of arguments' 1>&2
	return 1
set --erase argv



# Command verbosity
if set -q VERBOSE
	alias ln 'ln --verbose'
	alias rm 'rm --verbose'

	function sudo; command sudo $argv --verbose; end
end



# Conditional operation
## Simple non-recursive
### Ensure source is a valid directory
if ! path is -d "$source_dir"
	echo "$(status basename)"': '"$(status current-function)"': Not a directory: '{$source_dir} 1>&2
	return 1
end

### If target doesn't exist, simply create a symlink to the source and exit
if ! test -e "$target_dir"
	# Verbosity announcement
	if set -q VERBOSE
		echo \"{$target_dir}\"' Does not exist, symlinking entire directory'
	end

	ln -s "$source_dir" "$target_dir"
	return 0
end

### If target is not a directory, it's a conflict. Overwrite it as a symlink.
if ! test -d "$target_dir"
	echo (status basename)': '(status current-function)': Warning: Target "'{$target_dir}'" is a file Replacing with symlink' 1>&2
	sudo ln -sfn "$source_dir" "$target_dir"
	return 0
end


##  Recursive
sudo fd . --absolute-path "$target_dir" | while read --local item_paths
	# Find all files and directories within the target, relative to itself
	if ! test -e {$source_dir}/{$item_path}
		# A unique file/dir was found in the target. It is not a pure subset
		# Verbosity announcement
		if set -q VERBOSE
			echo (status basename)': '(status current-function)': Unique file: '{$target_dir}/{$item_path}
		end

		set --function impure_subset
		break
	end
end


## Action based on comparison
if ! set -q impure_subset # Target is a "pure" subset. Remove it and link the source directory
	# Verbosity announcement
	if set -q VERBOSE
		echo (status basename)': '(status current-function)': Pure subset directory: '{$target_dir}
	end
	
	sudo rm -rf "$target_dir"
	sudo ln -sf {$source_dir} {$target_dir}
else # Target has unique files. Preserve them by linking contents individually
	set --local source_content (command ls -A "$source_dir")
	for item in {$source_content}
		set --local source_item {$source_dir}/{$item}
		set --local target_item {$target_dir}/{$item}

		if path is -d "$source_item"
			# If the source item is a directory, recurse
			set --local function_name (status current-function)
			$function_name {$source_item} {$target_item}
		else
			sudo rm -f {$target_item} # Remove target item if it exists
			sudo ln -sfn {$source_item} {$target_item}
		end
	end
end
