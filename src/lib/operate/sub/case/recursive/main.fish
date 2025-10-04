function _smart-symlink_operate_case_recursive --description 'Recursive operation on super-set directories'
	set --append --local output_prefix (status current-function | string split '_' | tail -n 1)': ' # Append the Output-prefix with the current function name
	set --local function_name (status current-function) # Set function-name for execution on sub-functions


	# Determine if the Target is a pure subset of the Source
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


	# Action based on comparison
	if ! set -qf impure_subset # Target is a pure subset
		"$function_name"_reserve-and-link
	else # Target has unique files. Preserve them by linking contents individually
		"$function_name"_operate-on-children
	end
end
