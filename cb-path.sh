


# this file is meant to be sourced by bash.


# CB_PATH_PATH_BACKUP="";


# filter les caractères / . dans les noms de fichiers. le . c'est pour
# *facilement* pouvoir utiliser * (filename expansion) pour lister
# tout les fichiers dans le dossier save.
--cb-path--filter-name() {
	echo "${1//[\/.]/}";
}


# TODO:
# ls : lister le contenu du dossier assodié à un name
# find ou which: trouver dans quel name se trouve le fichier spécifié
# cd : changer le current directory pour le path associé

cb-path () {
	if [ -z "$CB_PATH_PATH_BACKUP" ]; then
		CB_PATH_PATH_BACKUP="${PATH}";
	fi;
	
	local config_dir=~/.local/share/cb-path;
	local save_dir="$config_dir/saved";
	local namepath;
	mkdir -p "$config_dir";
	mkdir -p "$save_dir";
	
	# IFS=$'\n';
	# local db_file_path="$HOME/.cb-path-db";
	# touch "$db_file_path";
    
	
	
	if [ "$#" == "0" ]; then
		echo "Not enough arguments";
		return 1;
	fi
	
	

	local option_help=0;
	
	for i in "$@"; do
		case "$i" in
			(-h|--help|help)
				option_help=1;
				;;
			(--)
				break;
				;;
		esac;
	done
	
	
	if (($option_help)); then
		cat <<"HELP";
SYNOPSIS

	cb-path [-h|--help] <command> [<arguments>]...

DESCRIPTION

	Manage the PATH environment variable.

COMMANDS

	list

		List your saved folders with their names.

	reset

		Reset your PATH to its value when opening your shell.

	export <name>

		Export the associated folder to your PATH.

	add <name>
	add <name> <relative/absolute path>

		Add the current directory to the database with the associated
		name.

	rm <name>

		Remove the name from the database.

	cd <name>

		Change the current directory to the associated path.

	ls <name> [<options>]...

		List files in the associated folder. It uses the ls command on
		the system, and forwards the arguments to it.

	which <file names>

		Find where a file is located and to which name its parent
		directory is associated.

HELP
		return;
	fi;
	
	
	if [ "$1" == "list" ]; then
		for namepath in "$save_dir"/*; do
			local name=$(basename "$namepath");
			echo "$name:$(cat "$namepath")";
		done;
		
	elif [ "$1" == "export" ]; then
		shift;
		if ! [ "$#" == 1 ]; then
			echo "Not enough or too many arguments." >&2;
			return 1;
		fi;
		local name=$(basename "$1");
		if [ -f "$save_dir/$name" ] && [ -r "$save_dir/$name" ]; then
			export PATH=$(cat "$save_dir/$name")":$PATH";
		else
			echo "Name \"$name\" does not exist." >&2;
		fi;
		
	elif [ "$1" == "add" ]; then
		shift;
		if ! [ "$#" == 1 ] && ! [ "$#" == 2 ]; then
			echo "Not enough or too many arguments." >&2;
			return 1;
		fi;
		local name=$(--cb-path--filter-name "$1");
	    if [ -f "$save_dir/$name" ]; then
			echo "\"$name\" is already taken." >&2;
			return 1;
		fi;
		if ! [ -z "$2" ]; then
			realpath -m "$2";
		else
			pwd;
		fi > "$save_dir/$name";
		
	elif [ "$1" == "rm" ]; then
		shift;
		if ! [ "$#" == 1 ]; then
			echo "Not enough or too many arguments." >&2;
			return 1;
		fi;
		local name=$(--cb-path--filter-name "$1");
		if [ -f "$save_dir/$name" ]; then
			rm -r "$save_dir/$name";
		else
			echo "name \"$name\" is not used." >&2;
			return 1;
		fi;

	elif [ "$1" == "reset" ]; then
		export PATH="$CB_PATH_PATH_BACKUP";
		
	elif [ "$1" == "cd" ]; then
		shift;
		if ! [ "$#" == 1 ]; then
			echo "Not enough or too many arguments." >&2;
			return 1;
		fi;
		local name=$(--cb-path--filter-name "$1");
		if ! [ -f "$save_dir/$name" ]; then
			echo "Name \"$name\" does not exist." >&2;
			return 1;
		fi;
	    cd "$(cat "$save_dir/$name")";
		
	elif [ "$1" == "ls" ]; then
		shift;
		if (("$#" < 1)); then
			echo "Not enough arguments." >&2;
			return 1;
		fi;
		local name=$(--cb-path--filter-name "$1");
		if ! [ -f "$save_dir/$name" ]; then
			echo "Name \"$name\" does not exist." >&2;
			return 1;
		fi;
		shift;
		ls "$@" "$(cat "$save_dir/$name")";
		
	elif [ "$1" == "which" ]; then
		shift;
		if ! [ "$#" == 1 ]; then
			echo "Not enough or too many arguments." >&2;
			return 1;
		fi;
		for namepath in "$save_dir"/*; do
			local name=$(basename "$namepath");
		    local refpath=$(cat "$namepath");
			if [ -f "$refpath/$1" ] && [ -x "$refpath/$2" ]; then
				echo "$name:$refpath";
			fi;
		done;
		
	else
		echo "unknown command \"$1\"" >&2;
		return 1;
	fi;
}




















