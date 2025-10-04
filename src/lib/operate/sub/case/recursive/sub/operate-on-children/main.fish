function _smart-symlink_operate_case_recursive_operate-on-children --description 'Operate individually on contents of `$target_dir`'
	set --local function_name (status current-function) # Set function-name for execution on sub-functions

	for item in (ls -A "$source_dir") # Items in source content
		set --local source_item "$source_dir"/"$item"
		set --local target_item "$target_dir"/"$item"

		if path is -d "$source_item"
			# If the source item is a directory, recurse
			if set -q VERBOSE # Verbosity announcement				
				set --append --local output_prefix (status current-function | string split '_' | tail -n 1)': ' # Append the Output-prefix with the current function name
				echo {$output_prefix}"$(status current-function)"': Re-operating on directory in Super-set "'{$target_dir}'": '{$target_item}
			end

			set --local main_executable (status basename)
			"$main_executable" "$source_item" "$target_item"
		else
			sudo rm {$VERBOSE} -f "$target_item" # Remove target item if it exists
			sudo ln {$VERBOSE} -sfn "$source_item" "$target_item"
		end
	end
end
