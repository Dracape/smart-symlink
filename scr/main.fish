#!/usr/bin/env fish
# TODO
# • Libraries
# 	◦ Use a libary directory for functions (symlink libraries to the root-parent directory)
# 	◦ Create functions for commands to automatically set the permissions to the directory's ownership (using stat -c %[U|G])
# • Allow interactive use (without force or interactive option; determine what to use on the basis of `status is-interactive`)
# • Make variables for customization

smart-symlink {$argv}
