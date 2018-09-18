#!/bin/bash

# Checks if user is root, exit if not
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

# Helper function
usage () {
	echo "Overview: grants script modifies the privileges of given <users> on database or
	table level of a postgresql database running (tested on v10.5).

	NOTE: is possible set multiple users or privileges, see examples. If not specified, 
	grants will be applied to all <tables> in <data_base>. The privileges on table and 
	database level can be seen here (postgresql.org/docs/10/static/sql-grant.html).

	Usage: sudo ./grants.sh [options] [-d <data_base>] [-u <users>] [-p <privileges>]

	Examples:
	 sudo ./grants.sh -u \"usuario1 usuario2\" -d crm -p ALL -t comments
	 sudo ./grants.sh -u usuario1 -d  -p \"SELECT, INSERT\" -t prices

	Options:
	  -h, --help			display help message and exit
	  -d, --data-base		name of the <data_base> to use
	  -t, --table 			name of the <table>
	  -r, --revoke 			REVOKE privileges insteand of GRANT
	  -p, --privileges 		privileges to be granted or revoked
	"
	exit 1
}

# Manages options flags
while (( $# )) ; do
	case $1 in
		-p | --privileges )
			shift
			privileges=$1
			;;
		-d | --data-base )
			shift
			data_base=$1
			;;
		-t | --table )
			shift
			table=$1
			;;
		-u | --users )
			shift
			users=$1
			;;
		-r | --revoke )
			revoke=true
			;;
		* )
			usage
			;;
	esac
	shift
done

# Checks if all necessary arguments were given
if [ -z "$data_base" ] || [ -z "$users" ] || [ -z "$privileges" ]; then
	usage
	exit 1
fi

# Modify query parameters to correct syntax
if [ -n "$table" ]; then
	where="ON $table"
else
	echo $data_base$where
	where="ON ALL TABLES"
fi

if [ -n "$revoke" ]; then
	what="REVOKE"
else
	what="GRANT"
fi

psql_wrap() {
	sudo -u postgres bash -c "psql -d $data_base -c \"$1\""
}

# Grant/Revoke $privileges to all user in <users>
for user in $users; do
	query="$what $privileges $where TO $user;"
	echo "$query"
	psql_wrap "$query"
done