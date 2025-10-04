function _smart-symlink_operate_case_recursive_reserve-and-link --description 'Forcefully remove the target and link the source'
	set --append --local output_prefix $(status current-function | string split '_' | tail -n 1)': ' # Append the Output-prefix with the current function name

	if set -q VERBOSE # Verbosity announcement
		echo {$output_prefix}'Pure subset directory: '{$target_dir}
	end

	set --erase --function impure_subset
	sudo rm {$VERBOSE} -rf "$target_dir"
	sudo ln {$VERBOSE} -sf "$source_dir" "$target_dir"
end
