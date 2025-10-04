function _smart-symlink_operate --description 'Main operation logic'
	set --append --local output_prefix "(status current-function | string split '_' | tail -n 1)"': ' # Append the Output-prefix with the current function name
	set --local function_name (status current-function)

	"$function_name"_non-recursive 	# Simple, Non-recursive operations
	"$function_name"_recursive 	# Complex, Recursive operations



	#  Recursive
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


	## Action based on comparison
	if ! set -qf impure_subset # Target is a "pure" subset. Remove it and link the source directory
		if set -q VERBOSE # Verbosity announcement
			echo {$output_prefix}'Pure subset directory: '{$target_dir}
		end

		set --erase --function impure_subset
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
