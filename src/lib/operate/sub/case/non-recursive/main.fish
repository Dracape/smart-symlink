function _smart-symlink_operate_case_non-recursive --description 'Simple, Non-recursive operations'
	set --append --local output_prefix $(status current-function | string split '_' | tail -n 1)': ' # Append the Output-prefix with the current function name
	set --local function_name (status current-function) # Set function-name for execution on sub-functions
 
	"$function_name"_verify-source-is-dir 		# Verify source is a directory

	# If target doesn't exist, simply create a symlink to the source and exit
	if ! test -e "$target_dir"
		"$function_name"_link-entire
	end

	# If target is not a directory, it's a conflict. Overwrite it as a symlink.
	if ! test -d "$target_dir"
		"$function_name"_overwrite-entire
	end
end
