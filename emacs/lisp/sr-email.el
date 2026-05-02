;;; sr-email.el --- Personal configuration for email  -*- lexical-binding: t; -*-
;;; Commentary:
;; Personal library for Email configuration.

;;; Code:

(require 'notmuch)

;;; Mail sending

(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-default-smtp-server "smtp.fastmail.com"
      smtpmail-smtp-service 587)

(setq user-full-name "Minjeong Kim")
(setq user-mail-address "kimsaram32@fastmail.com")

(keymap-global-set "C-c m" #'notmuch)

;;; Notmuch search/tags

(setq notmuch-archive-tags '("-inbox" "-unread" "+archive"))

(setq notmuch-tagging-keys
      '(("a" notmuch-archive-tags "Archive")
        ("u" notmuch-show-mark-read-tags "Mark read")
        ("f" ("+flagged") "Flag")
        ("s" ("+spam" "-inbox") "Mark as spam")
        ("d" ("+deleted" "-inbox") "Delete")))

(setq notmuch-saved-searches
      '((:name "inbox" :query "tag:inbox" :key "i")
        (:name "unread" :query "tag:unread" :key "u")

        (:name "mailing list" :query "tag:list not tag:archive" :key "l")
        (:name "emacs" :query "tag:emacs not tag:archive" :key "e")

        (:name "flagged" :query "tag:flagged" :key "f")
        (:name "sent" :query "tag:sent" :key "t")
        (:name "drafts" :query "tag:draft" :key "d")
        (:name "deleted" :query "tag:deleted" :key "D")
        (:name "archives" :query "tag:archive" :key "a")
        (:name "all mail" :query "*" :key "A")))

;;; Notmuch hello

(setq notmuch-hello-sections
      (list
       #'notmuch-hello-insert-saved-searches
       #'notmuch-hello-insert-alltags))

(setq notmuch-show-all-tags-list t)

;;; Notmuch show mode

(defun sr/notmuch-show-get-message-depth ()
  (plist-get (notmuch-show-get-message-properties) :depth))

(defun sr/notmuch-show-parent-message ()
  (interactive)
  (let ((target-depth (1- (sr/notmuch-show-get-message-depth))))
    (while (and
            (notmuch-show-goto-message-previous)
            (not (= (sr/notmuch-show-get-message-depth)
                    target-depth))))))

(defun sr/notmuch-show-trash-message ()
  (notmuch-show-tag "+deleted"))

(keymap-set notmuch-show-mode-map "U" #'sr/notmuch-show-parent-message)

;;; Synchronization

(defvar sr/email-sync-process-name "mail-sync")

(defvar sr/email-sync-command "mbsync fastmail:INBOX")

(defvar sr/email-after-sync-hook nil)

(defvar sr/email-sync-interval-seconds 300)

(defun sr/email-sync-sentinel (proc change)
  (when (eq (process-status proc) 'exit)
    (message "Email synchronization done.")
    (run-hooks 'sr/email-after-sync-hook)))

(defun sr/email-sync ()
  "Run commands for synchronizing mail."
  (interactive)
  (if (get-process sr/email-sync-process-name)
      (message "Email synchronization already in progress.")
    (let ((proc (start-process-shell-command
                 sr/email-sync-process-name
                 "*mail sync*"
                 sr/email-sync-command)))
      (message "Synchronizing email...")
      (set-process-sentinel proc #'sr/email-sync-sentinel))))

(run-with-timer 0 sr/email-sync-interval-seconds #'sr/email-sync)

;;; Notify new messages for notmuch

(defun sr/email-notify-new-notmuch-messages ()
  "Notify notmuch messages tagged with \"new\", if any."
  (let ((count (string-to-number
                (car (notmuch--process-lines
                      notmuch-command "count"
                      "tag:new")))))
    (when (> count 0)
      (sr/show-notification
       (format "You have %d new message(s)." count)
       3))))

(defun sr/email-refresh-notmuch ()
  "Run \"notmuch new\", then notify new messages if any."
  (message "Importing messages to notmuch...")
  (notmuch-poll)
  (sr/email-notify-new-notmuch-messages)
  (notmuch-tag "tag:new" '("-new" "+inbox")))

(add-hook 'sr/email-after-sync-hook #'sr/email-refresh-notmuch)

;;; _

(provide 'sr-email)

;;; sr-email.el ends here
