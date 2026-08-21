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

;;; Basic workflow

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

;;; Periodic notes

(with-eval-after-load 'sr-denote-periodic
  (setq sr/denote-periodic-directory sr/note-periodic-directory)
  (setq sr/denote-periodic-get-today-date-function #'sr/note-current-date))

(defun sr/denote-periodic-daily-note-today ()
  (interactive)
  (sr/denote-periodic-today 'daily))

(keymap-global-set "C-c j j" #'sr/denote-periodic-daily-note-today)

;;; _

(provide 'sr-workflow)

;;; sr-workflow.el ends here
