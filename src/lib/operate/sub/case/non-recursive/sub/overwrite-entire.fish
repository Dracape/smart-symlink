function _smart-symlink_operate_case_non-recursive_overwrite-entire --description 'Overwrite the target'
	set --append --local output_prefix (status current-function | string split '_' | tail -n 1)': ' # Append the Output-prefix with the current function name
	echo {$output_prefix}'Warning: Target "'{$target_dir}'" is not a directory'\t'Replacing with symlink' 1>&2
	sudo ln {$VERBOSE} -sfn "$source_dir" "$target_dir"
	exit 0
end
