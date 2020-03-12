#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-03-12 16:40:27 +0000 (Thu, 12 Mar 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Lists all PostgreSQL tables using adjacent impala_shell.sh script
#
# FILTER environment variable will restrict to matching tables (matches against fully qualified table name <db>.<schema>.<table>)
#
# Auto-skips information_schema and pg_catalog schemas
#
# Tested on AWS RDS PostgreSQL 9.5.15

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(dirname "$0")"

#"$srcdir/psql.sh" -q -t -c "SELECT table_catalog || '.' || table_schema || '.' || table_name FROM information_schema.tables ORDER BY table_catalog, table_schema, table_name;" "$@" |
"$srcdir/psql.sh" -q -t -c "SELECT table_catalog, table_schema, table_name FROM information_schema.tables ORDER BY table_catalog, table_schema, table_name;" "$@" |
sed 's/|//g; s/^[[:space:]]*//; s/[[:space:]]*$//; /^[[:space:]]*$/d' |
#while read -r table; do
while read -r db schema table; do
    if [ "$schema" = "information_schema" ] ||
       [ "$schema" = "pg_catalog" ]; then
        continue
    fi
    if [ -n "${FILTER:-}" ] &&
       ! [[ "$db.$schema.$table" =~ $FILTER ]]; then
        continue
    fi
    printf "%s\t%s\t%s\n" "$db" "$schema" "$table"
done
