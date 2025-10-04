#!/usr/bin/fish
# TODO
# • Libraries
# 	◦ Use a libary directory for functions (symlink libraries to the root-parent directory)
# 	◦ Create functions for commands to automatically set the permissions to the directory's ownership (using stat -c %[U|G])
# • Allow interactive use (without force or interactive option; determine what to use on the basis of `status is-interactive`)
# • Make variables for customization
set --local script_name "$(status basename | path change-extension \0)"



# Behaviour setting
## Variables
### Output prefix
set --global output_prefix {$script_name}': '

### Verbose
if set -qlx VERBOSE
	set --global --export VERBOSE -- '--verbose'
end


## Arguments
### Switches
#### Parse
argparse 'v/verbose&' 'h/help&' -- "$argv"
#### Individual
##### Verbose
if set -ql _flag_verbose
	if ! set -qgx VERBOSE # Only if not set above
		set --global --export VERBOSE -- '--verbose'
	end
end

##### Help
if set -ql _flag_help
	_smart-symlink_help-text
	return 0
end




### Positional
#### 1 argument → Set current directory as source
if test (count {$argv}) -eq 1
	set --global source_dir (string escape {$PWD})
	set --global target_dir (path normalize {$argv[1]} | string escape)
#### 2 argument → Set 1st argument as Source & 2nd argument as Target
else
	if test (count {$argv}) -eq 2
		set --global source_dir (realpath {$argv[1]} | string escape)
		set --global target_dir (path normalize {$argv[2]} | string escape)
#### argument count != 1 or 2 → throw error
	else
		echo {$output_prefix}'Invalid number of arguments' 1>&2
		return 1
	set --erase argv
	end
end




_"$script_name"_operate # Main Operation
