;;; sr-workflow.el --- Personal workflow configurations  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Minjeong Kim

;; Author: Minjeong Kim <kimsaram32@fastmail.com>
;; URL: https://github.com/kimsaram32/dotfiles

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;; Code:

(defgroup sr/workflow nil
  "Personal workflows."
  :group 'local)

(defvar-keymap sr/workflow-map)

;;; The note system

(defun sr/note-current-date ()
  "Return current time value for the note system.
If the time is before `sr/note-day-start-hour', use the previous date.
Otherwise, use the current date."
  (let* ((time (decode-time))
	 (current-day (decoded-time-day time))
	 (day (if (< (decoded-time-hour time) sr/note-day-start-hour)
		  (- current-day 1)
		current-day)))
    (encode-time (append (list 0 0 0 day) (seq-subseq time 4)))))

(defun sr/file-name-today ()
  "Return the file name for today."
  (expand-file-name
   (format-time-string "%Y-%m.org" (sr/note-current-date))
   sr/note-periodic-directory))

(keymap-global-set "C-c j" sr/workflow-map)

(defun sr/find-today-buffer ()
  "Open buffer for today's daily note."
  (interactive)
  (find-file (sr/file-name-today)))

(keymap-set sr/workflow-map "j" #'sr/find-today-buffer)

(defun sr/is-empty-line-p ()
  "Return t if current line only includes whitespace, else return nil."
  (string-match-p "^[[:blank:]]*$"
                  (buffer-substring (line-beginning-position)
                                    (line-end-position))))

(defun sr/start-today ()
  "Begin today by creating an entry to the Org buffer for today."
  (interactive)
  (find-file (sr/file-name-today))
  (goto-char (point-max))
  (unless (sr/is-empty-line-p)
    (insert "\n"))
  (insert (concat
           "* "
           (format-time-string "%Y-%m-%d" (sr/note-current-date))))
  (recenter 0)
  (save-excursion
    (insert "\n** Logs")))

(defun sr/finish-today ()
  "Finish daily workflow; save all buffers associated with a file, commit
changes in the note directory."
  (interactive)
  (save-some-buffers t)
  (let ((default-directory sr/note-root-directory)
	    (subcommands `(("add" ".")
			           ("commit" "-m"
			            ,(format-time-string "%Y%m%d" (sr/note-current-date)))
			           ("push"))))
    (dolist (args subcommands)
	  (apply 'call-process (append '("git" nil nil nil) args)))
    (message "Commited and pushed changes in the note directory.")
    (message "Done. Good night :)")))

;;; _

(provide 'sr-workflow)

;;; sr-workflow.el ends here
