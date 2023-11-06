#!/bin/bash


# this file is meant to be source(ed) into your shell

CB_PATH_PATH_BACKUP="${PATH}";



# TODO:
# ls : lister le contenu du dossier assodié à un name
# find ou which: trouver dans quel name se trouve le fichier spécifié
# cd : changer le current directory pour le path associé

cb-path () {
	
	IFS=$'\n';
	local db_file_path="$HOME/.cb-path-db";
	touch "$db_file_path";
	
	cb-path-help () {
		(echo $'Manage the PATH environment variable';
		echo $'';
		echo $'db file path : '"$db_file_path";
		echo $'';
		echo $'usage: cb-path [command] [options]';
		echo $'commands:';
		echo $'\tlist : list your saved folders with their names';
		echo $'\treset : reset your PATH to its value when opening your shell';
		echo $'\texport <name> : export the associated folder(s) to your PATH';
		echo $'\tadd <name> : add the current directory to the database with the associated name';
		echo $'\trm <name> : remove the name from the database';
		echo $'\tcd <name> : change the current directory to the associated path';
		echo $'\tls <name> : list files in the associated folder(s)';
		echo $'\twhich <file names> : find where a file is located and to which name its parent directory is associated';
		echo $'';) | fmt -s;
	}
	
	cb-path-read-db () {
		
		cat "$db_file_path";
		
	}
	
	if [ "$#" == "0" ]; then
		echo "not enough arguments";
		return 1;
	fi
	
	
	
	
	for i in $*; do
		if [ "$i" == "-h" ] || [ "$i" == "--help" ] || [ "$i" == "help" ]; then
			cb-path-help;
			return;
		fi
	done
	
	
	
	
	
	if [ "$1" == "list" ]; then
		local content="$(cb-path-read-db)";
		echo $';name\tpath';
		for line in $content; do
			local name="$(echo "$line" | cut "-d/" "-f1")";
			local path="$(echo "$line" | cut "-d/" "-f2-")";
			echo "$name"$'\t'"$path";
		done
		
		
	elif [ "$1" == "export" ]; then
		if [ "$#" == "1" ]; then
			echo "not enough arguments";
			return 1;
		elif [ "$#" != "2" ]; then
			echo "too many arguments";
			return 1;
		fi
		
		local content="$(cb-path-read-db)";
		for line in $content; do
			local name="$(echo "$line" | cut "-d/" "-f1")";
			local path="$(echo "$line" | cut "-d/" "-f2-")";
			
			if [ "$name" == "$2" ]; then
				export PATH="${path}:${PATH}";
				echo "appended \"${path}\"";
			fi
		done
		
		
	elif [ "$1" == "add" ]; then
		if [ "$#" == "1" ]; then
			echo "not enough arguments";
			return 1;
		elif [ "$#" != "2" ]; then
			echo "too many arguments";
			return 1;
		fi
		
		echo "$2/$(pwd)" >> $db_file_path;
		
	elif [ "$1" == "rm" ]; then
		if [ "$#" == "1" ]; then
			echo "not enough arguments";
			return 1;
		elif [ "$#" != "2" ]; then
			echo "too many arguments";
			return 1;
		fi
		
		local content="$(cb-path-read-db)";
		local newcontent="";
		local first="true";
		for line in $content; do
			local name="$(echo "$line" | cut "-d/" "-f1")";
			local path="$(echo "$line" | cut "-d/" "-f2-")";
			
			if [ "$name" != "$2" ]; then
				# echo "$line";
				if [ "$first" == "false" ]; then
					newcontent="$newcontent"$'\n';
				fi
				newcontent="${newcontent}${line}";
				first="false";
			else
				echo "removed \"${path}\"";
			fi
		done
		# echo -n "$newcontent";
		echo -n "$newcontent" > $db_file_path;
		
	elif [ "$1" == "reset" ]; then
		export PATH="$CB_PATH_PATH_BACKUP";
		
	elif [ "$1" == "cd" ]; then
		if [ "$#" == "1" ]; then
			echo "not enough arguments";
			return 1;
		elif [ "$#" != "2" ]; then
			echo "too many arguments";
			return 1;
		fi
		
		local content="$(cb-path-read-db)";
		for line in $content; do
			local name="$(echo "$line" | cut "-d/" "-f1")";
			local path="$(echo "$line" | cut "-d/" "-f2-")";
			
			if [ "$name" == "$2" ]; then
				echo "cd ${path}";
				cd "${path}";
			fi
		done
	elif [ "$1" == "ls" ]; then
		if [ "$#" == "1" ]; then
			echo "not enough arguments";
			return 1;
		elif [ "$#" != "2" ]; then
			echo "too many arguments";
			return 1;
		fi
		
		local content="$(cb-path-read-db)";
		for line in $content; do
			local name="$(echo "$line" | cut "-d/" "-f1")";
			local path="$(echo "$line" | cut "-d/" "-f2-")";
			
			if [ "$name" == "$2" ]; then
				ls -p "${path}" | grep -v "/";
			fi
		done
		
	elif [ "$1" == "which" ]; then
		if [ "$#" == "1" ]; then
			echo "not enough arguments";
			return 1;
		fi
		
		shift;
		local content="$(cb-path-read-db)";
		for filename in $*; do
			for line in $content; do
				local name="$(echo "$line" | cut "-d/" "-f1")";
				local path="$(echo "$line" | cut "-d/" "-f2-")";
				
				if [ -f "${path}/${filename}" ]; then
					echo "$name"$'\t'"${path}/${filename}";
				fi
				
			done
		done
		
	else
		echo "unknown command \"$1\"";
		return 1;
	fi
	
}




















