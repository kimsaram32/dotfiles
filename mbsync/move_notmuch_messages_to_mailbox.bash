#! /usr/bin/env bash

# Move notmuch messages matching the given query to the specified mailbox.
# Messages already in the mailbox are skipped.
#
# Messages are retrieved with 'notmuch-search'.
#
# Example: ./move_messages_to_mailbox.bash Trash tag:deleted

set -euo pipefail

MAILDIR_ROOT=~/mail

usage() {
    echo "usage: " $(basename $0) MAILBOX QUERY
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

MAILBOX=$1
shift
QUERY=$*

new_dir=${MAILDIR_ROOT}/${MAILBOX}/cur

if [ ! -d ${new_dir} ]; then
    echo "'${MAILBOX}' does not exist as a valid mailbox"
    exit 1
fi

full_query="${QUERY} NOT folder:${MAILBOX}"
count=$(notmuch count ${full_query})

if [ ${count} -eq 0 ]; then
    echo "no messages matching '${full_query}'."
    exit 0
fi

echo "found ${count} messages matching '${full_query}'."

notmuch search --output=files ${full_query} |
    while IFS= read -r file; do
        base=${file##*/}

        # mbsync(1): When using the more efficient default UID mapping scheme,
        # it is important that the MUA renames files when moving them between
        # Maildir folders. (...) The general expectation is that a completely
        # new filename is generated as if the message was new, but stripping the
        # ,U=xxx infix is sufficient as well.
        new_name=${new_dir}/$(sed -E 's/,U=[0-9]+//' <<< ${base})

        mv $file $new_name
    done

echo "moved ${count} messages to ${MAILBOX}."
