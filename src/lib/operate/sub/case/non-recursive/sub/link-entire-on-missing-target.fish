function _smart-symlink_operate_case_non-recursive_link-entire-on-missing-target --description 'Link entire directory if the target doesn\'t exist'

	if ! test -e "$target_dir"
		if set -q VERBOSE # Verbosity announcement
			set --append --local output_prefix (status current-function | string split '_' | tail -n 1)': ' # Append the Output-prefix with the current function name
			echo {$output_prefix}'Target Does not exist: "'{$target_dir}\"
		end

		ln {$VERBOSE} -s "$source_dir" "$target_dir"
		exit 0
	end
end
