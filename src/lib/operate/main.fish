function _smart-symlink_operate --description 'Main operation logic'
	set --append --local output_prefix (status current-function | string split '_' | tail -n 1)': ' # Append the Output-prefix with the current function name
	set --local function_name (status current-function) # Set function-name for execution on sub-functions

	"$function_name"_case_non-recursive 	# Simple, Non-recursive operations
	"$function_name"_case_recursive 	# Complex, Recursive operations (super-set directories)
end
