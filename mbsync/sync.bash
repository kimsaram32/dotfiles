#! /usr/bin/env bash

# Synchronize notmuch tags and mailboxes, then run mbsync.

set -euo pipefail

move_notmuch_messages_to_mailbox=$(dirname $0)/move_notmuch_messages_to_mailbox.bash

# Reflect Notmuch tag changes in mailbox locations.
${move_notmuch_messages_to_mailbox} Archive tag:archive
${move_notmuch_messages_to_mailbox} Trash tag:deleted

mbsync -a
