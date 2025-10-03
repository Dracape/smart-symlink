# Behaviour setting
## Variables (without any equivalent argument != VERBOSE)
_smart-symlink_behaviour-setting_variables 'output_prefix'


function smart-symlink --description 'Recursively symlinks a source directory to a target directory—linking whole directories if the contents are the same'
	## Arguments
	### Switches
	#### Parse
	argparse 'v/verbose' 'h/help' -- "$argv"
	#### Individual
	##### Verbose
	_smart-symlink_behaviour-setting_variables 'VERBOSE'


	##### Help
	if set -q _flag_help
		echo 'Smartly symlink SOURCE_DIR to TARGET.'\n
		set_color --bold --underline; echo -n 'Usage:'; set_color normal; echo ' '(status current-function)' [OPTION] SOURCE_DIR TARGET'\n
		set_color --bold --underline; echo 'Arguments:'; set_color normal; echo \t'<paths>…'\n

		set_color --bold --underline; echo 'Options:'
		set_color --bold normal; echo -n -- '  -h'; set_color normal; echo -n ', '; set_color --bold; echo -- '--help'
		set_color normal; echo \t'Print help'
		set_color --bold; echo -n -- '  -v'; set_color normal; echo -n ', '; set_color --bold; echo -- '--verbose'
		set_color normal; echo -n \t'Show more information'\n\t'[Variable: '; set_color --italics; echo -n 'VERBOSE'; set_color normal; echo ']' 

		if set -q VERBOSE
			set_color --bold --underline; echo \n'Variables:'
			set_color --bold normal; echo '  VERBOSE'
			set_color normal; echo \t'Show more information'
			set_color normal; echo -n \t'[Switch: '; set_color --italics; echo -n -- '-v';set_color normal; echo -n ', ';set_color --italics ; echo -n -- '--verbose' ; set_color normal; echo ']'
		end
		
		return 0
	end




	### Positional
	#### 1 argument → Set current directory as source
	if test (count {$argv}) -eq 1
		set --function source_dir (string escape {$PWD})
		set --function target_dir (path normalize {$argv[1]} | string escape)
	#### 2 argument → Set 1st argument as Source & 2nd argument as Target 
	else
		if test (count {$argv}) -eq 2
			set --function source_dir (realpath {$argv[1]} | string escape)
			set --function target_dir (path normalize {$argv[2]} | string escape)
	#### argument count != 1 or 2 → throw error
		else
			echo {$output_prefix}'Invalid number of arguments' 1>&2
			return 1
		set --erase argv
		end
	end




	# Conditional operation
	## Simple non-recursive
	### Ensure source is a valid directory
	if ! path is -d "$source_dir"
		echo {$output_prefix}'Not a directory: '{$source_dir} 1>&2
		return 1
	end

	### If target doesn't exist, simply create a symlink to the source and exit
	if ! test -e "$target_dir"
		if set -q VERBOSE # Verbosity announcement
			echo {$output_prefix}\"{$target_dir}\"' Does not exist, symlinking entire directory'
		end

		ln {$VERBOSE} -s "$source_dir" "$target_dir"
		return 0
	end

	### If target is not a directory, it's a conflict. Overwrite it as a symlink.
	if ! test -d "$target_dir"
		echo {$output_prefix}'Warning: Target "'{$target_dir}'" is a file Replacing with symlink' 1>&2
		sudo ln {$VERBOSE} -sfn "$source_dir" "$target_dir"
		return 0
	end


	##  Recursive
	sudo fd . --base-directory "$target_dir" | while read --local item_path # Find all files and directories within the target, relative to itself
		if ! test -e "$source_dir"/"$item_path" # Check if the file(s)/directories in the target are also in source
			# A unique file/dir was found in the target. It is not a pure subset
			if set -q VERBOSE # Verbosity announcement
				echo {$output_prefix}'Unique file: '"$target_dir"/"$item_path"
			end

			set --function impure_subset
			break
		end
	end


	### Action based on comparison
	if ! set -q impure_subset # Target is a "pure" subset. Remove it and link the source directory
		if set -q VERBOSE # Verbosity announcement
			echo {$output_prefix}'Pure subset directory: '{$target_dir}
		end

		sudo rm {$VERBOSE} -rf "$target_dir"
		sudo ln {$VERBOSE} -sf "$source_dir" "$target_dir"
	else # Target has unique files. Preserve them by linking contents individually
		for item in (ls -A "$source_dir") # Items in source content
			set --local source_item "$source_dir"/"$item"
			set --local target_item "$target_dir"/"$item"

			if path is -d "$source_item"
				# If the source item is a directory, recurse
				if set -q VERBOSE # Verbosity announcement
					echo {$output_prefix}"$(status current-function)"': Re-operating on directory in Super-set "'{$target_dir}'": '{$target_item}
				end

				set --local function_name (status current-function)
				"$function_name" "$source_item" "$target_item"
			else
				sudo rm {$VERBOSE} -f "$target_item" # Remove target item if it exists
				sudo ln {$VERBOSE} -sfn "$source_item" "$target_item"
			end
		end
	end
end
