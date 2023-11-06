


# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd );


backup_bashrc_path="${HOME}/.bashrc.${RANDOM}.backup-before-install";
echo "backing up .bashrc to $backup_bashrc_path";
cp ~/.bashrc "${backup_bashrc_path}";


echo "source \"${SCRIPT_DIR}/cb-path.sh\";" >> ~/.bashrc;












