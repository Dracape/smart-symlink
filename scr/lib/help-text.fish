function _smart-symlink_help-text
	echo 'Smartly symlink SOURCE_DIR to TARGET.'\n
	set_color --bold --underline; echo -n 'Usage:'; set_color normal; echo ' '(status current-function)' [OPTION] SOURCE_DIR TARGET'\n
	set_color --bold --underline; echo 'Arguments:'; set_color normal; echo \t'<paths>…'\n

	set_color --bold --underline; echo 'Options:'
	set_color --bold normal; echo -n -- '  -h'; set_color normal; echo -n ', '; set_color --bold; echo -- '--help'
	set_color normal; echo \t'Print help'
	set_color --bold; echo -n -- '  -v'; set_color normal; echo -n ', '; set_color --bold; echo -- '--verbose'
	set_color normal; echo -n \t'Show more information'\n\t'[Variable: '; set_color --italics; echo -n 'VERBOSE'; set_color normal; echo ']' 

	if set -q VERBOSE
		set_color --bold --underline; echo \n'Variables:'
		set_color --bold normal; echo '  VERBOSE'
		set_color normal; echo \t'Show more information'
		set_color normal; echo -n \t'[Switch: '; set_color --italics; echo -n -- '-v';set_color normal; echo -n ', ';set_color --italics ; echo -n -- '--verbose' ; set_color normal; echo ']'
	end
end
