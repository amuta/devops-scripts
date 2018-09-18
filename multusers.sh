#!/bin/bash

# Helper function
usage () {
	echo "Overview: multusers script create, update or lock users in batches by reading
	  from am <users_file>. 

	NOTE: the <users_file> should have be .txt file with one user per line and the 
	  following syntax of parameters (required by the newusers command):
	    <Username>:<Password>:<UID>:<GID>:<User Info>:<Home Dir>:<Default Shell>
	  *The first line will be ignored if the first value is 'Username (header line)'
	  The <User Info> field is a GECOS field that can be use to specify general user's
	  information which should be separated by commas.

	<users_file> example:
	  # cat ./new_users.txt
	  joao:senha123::::/home/tester:
	  jose:senha123::1600::/home/tester:/bin/bash
	  maria:senha123:::::

	Usage: sudo ./multusers [options] -f <users_file>
	Options:
	  -h, --help			display help message and exit
	  -a, --add				add or update users from <users_file>
	  -l, --lock			lock users from <Username> in <users_file>
	  -u, --unlock			unlock users
	  -f, --file			path to <users_file>
	  -d, --dir-name		custom home directory
	  -g, --group-id		group-id (GID)
	  -i, --user-info		GECOS info (separated by comma)
	"
	exit 1
}

# Validator function that will check the syntax of the input file
validator() {
	gawk '!/^[a-z][-a-z0-9_]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*$/ {
			print $1
			exit 1
		}' $1
	if [ $? -eq 1 ]; then
		echo "Error in file syntax."
		usage
	fi
}

# Checks if at least 2 args
if [[ $# -le 2 ]]; then 
	usage
fi

# Manages options flags
while (( $# )) ; do
	case $1 in
		-a | --add )
			add=true
			;;
		-l | --lock )
			lock=true
			;;
		-u | --unlock )
			unlock=true
			;;
		-f | --file )
			shift
			filename=$1
			;;
		-d | --dir-name )
			shift
			dir_name=$1
			;;
		-g | --group-id )
			shift
			group_id=$1
			;;
		-i | --user-info )
			shift
			user_info=$1
			;;
		* )
			usage
			;;
	esac
	shift
done

# Checks file format
if ! [[ $filename =~ ^.*\.(txt|csv)$ ]]; then
	usage
fi

# Creates a temp users file
users_file=$(mktemp /tmp/multusers.XXXXXX)
exec 3>"$users_file"
rm "$users_file"
cat "$filename" > "$users_file" # write input to <users_file>

# Validates input users file
validator "$users_file" 

# Writes necessary modifications
gawk -i inplace '{ gsub(/:$/,":/bin/bash") }; { print }' "$users_file" # bash as default shell
gawk -i inplace -v d=$dir_name -v g=$group_id -v i=$user_info  'BEGIN{ FS=":"; OFS=":" } { $4 = g; $5 = i; $6 = d } { print }' "$users_file"
gawk -i inplace '!/Username/' "$users_file" # remove the header line


# Add/update users
if [[ $add == true ]]; then
	sudo newusers "$users_file"
	echo "Users added/updated"
fi

# Lock/unlock users
if [[ $lock == true || $unlock == true ]]; then
	usernames=$(gawk -F":" '{print $1}' "$users_file")
	for user in $usernames; do
		if  [[ $lock == true ]]; then
			sudo passwd -l "$user"
		else
			sudo passwd -u "$user"
		fi
	done
	echo "Finished locking users"
fi

# Print this to check the changes in /etc/passwd
# cat /etc/passwd | tail