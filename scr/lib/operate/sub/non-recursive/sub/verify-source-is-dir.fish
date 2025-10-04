function --description 'Verify that the source is a directory'
	set --append --local output_prefix "(status current-function | string split '_' | tail -n 1)"': ' # Append the Output-prefix with the current function name

	if ! path is -d "$source_dir"
		echo {$output_prefix}'Not a directory: '{$source_dir} 1>&2
		exit 1
	end
end
