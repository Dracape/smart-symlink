function _smart-symlink_behaviour-setting_variables --description 'Set variables'
	# Handle arguments
	## Switches
	### Scope (for use in the function itself)
	argparse 'g/global' 'f/function' 'l/local' --exclusive g,f,l -- $arvg
	if ! set -q _flag_function || set -q _flag_local
		set --function _flag_global -- '--global'
	end
	set --function scope_flags {$_flag_g} {$_flag_f} {$_flag_l} # List of scope flags
	set --erase --local flag_g flag_global  flag_f flag_function  flag_l flag_local 

	## Positional
	for given_var in {$argv}
		if contains "$given_var" VERBOSE output_prefix
			set --append --function vars_to_set {$given_var}
		else
			set --append --function unknown_vars {$given_var}
		end
	end

	### Individual
	#### Verbosity
	if contains VERBOSE {$vars_to_set}
		# Overwrite $VERBOSE to '--verbose'
		if set -q VERBOSE || set -q _flag_verbose
			set {$scope_flags} --export VERBOSE -- '--verbose'
		end
	end

	#### Output prefix
	if contains output_prefix {$vars_to_set}
		if ! set -q output_prefix # Define only if not already set
			set {$scope_flags} output_prefix "$(status current-function)"': '

			if ! status is-interactive
				set {$scope_flags} --append output_prefix "$(status basename | path basename --no-extension)"': '
			end
		end
	end
	
	set --erase 'argv' 'vars_to_set'



	if set -q unknown_vars
		# Set output prefix if not already set
		if ! set -q output_prefix
			set --local function_name "$(status current-function)"
			"$function_name" --local output_prefix
		end

		echo {$output_prefix}'Unknown variables: '{$unkown_vars} 1>&2
		return 1
	end
end
