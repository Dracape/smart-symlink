function _smart-symlink_operate_non-recursive --description 'Simple, Non-recursive operations'
	set --append --local output_prefix "(status current-function | string split '_' | tail -n 1)"': ' # Append the Output-prefix with the current function name
	set --local function_name (status current-function)
 
	"$function_name"_verify-source-is-dir # Verify source is a directory

	# If target doesn't exist, simply create a symlink to the source and exit
	if ! test -e "$target_dir"
		if set -q VERBOSE # Verbosity announcement
			echo {$output_prefix}\"{$target_dir}\"' Does not exist, symlinking entire directory'
		end

		ln {$VERBOSE} -s "$source_dir" "$target_dir"
		exit 0
	end

	# If target is not a directory, it's a conflict. Overwrite it as a symlink.
	if ! test -d "$target_dir"
		echo {$output_prefix}'Warning: Target "'{$target_dir}'" is not a directory'\t'Replacing with symlink' 1>&2
		sudo ln {$VERBOSE} -sfn "$source_dir" "$target_dir"
		exit 0
	end
