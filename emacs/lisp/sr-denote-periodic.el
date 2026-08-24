;;; sr-denote-periodic.el --- Periodic notes in Denote  -*- lexical-binding: t; -*-

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

(require 'denote)

;;; Note types

(defgroup sr/denote-periodic nil
  "Periodic notes in Denote."
  :group 'files
  :group 'denote)

(defcustom sr/denote-periodic-directory
  "~/periodic"
  "Directory for storing periodic notes."
  :type 'directory)

(defcustom sr/denote-periodic-note-keywords
  '("periodic")
  "List of Denote keywords added to periodic notes."
  :type '(list string))

(defcustom sr/denote-periodic-types
  '((daily
     :id-format "D%Y%m%d"
     :regexp "D\\([0-9]\\{4\\}\\)\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)"
     :title-format "%Y-%m-%d"
     :signature "daily")

    (monthly
     :id-format "M%Y%m"
     :regexp "M\\([0-9]\\{6\\}\\)"
     :title-format "%Y-%m"
     :signature "monthly")

    (yearly
     :id-format "Y%Y"
     :regexp "Y\\([0-9]\\{4\\}\\)"
     :title-format "%Y"
     :signature "yearly")

    (weekly
     :id-format "W%Y%W"
     :regexp "W\\([0-9]\\{6\\}\\)"
     :title-format "%Y-W%W"
     :signature "weekly"))
  "Alist of periodic note types.

Each element is of the form (NAME . PLIST). NAME is a symbol for the
note type. PLIST is a plist that consists of the following elements:

- `:id-format' is a format string (see `format-time-string') that is used
  to generate a note identifier.

- `:regexp' is a regular expression used to retrieve the note identifier
  from a file name.

- `:title-format' is a format string that is used to construct the title
  of a new note.

- `:signature' is a Denote signature to use in new notes.

Changing the value of this variable does not create or delete the
convenience \"today\" functions, e.g.,
`sr/denote-periodic-daily-note-today'."
  :type '(alist :key-type symbol
                :value-type plist))

(defcustom sr/denote-periodic-get-today-date-function
  #'current-time
  "Function to get the date of today.
The function should return a time value."
  :type 'function)

(defun sr/denote-periodic-get-type (type)
  "Get the plist of periodic note type TYPE."
  (cdr (assq type sr/denote-periodic-types)))

(defun sr/denote-periodic-date-to-identifier (type date)
  "Generate a note identifier for TYPE corresponding to DATE.
DATE should be a time value."
  (format-time-string
   (plist-get (sr/denote-periodic-get-type type) :id-format)
   date))

;;; Note commands

;;;###autoload
(defun sr/denote-periodic-create-note (type date)
  "Create the periodic note of TYPE for DATE."
  (let ((type-entry (sr/denote-periodic-get-type type))
        (directory (expand-file-name
                    (format-time-string "%Y" date)
                    sr/denote-periodic-directory)))
    (unless (file-exists-p directory)
      (make-directory directory))
    (denote
     (format-time-string (plist-get type-entry :title-format) date)
     sr/denote-periodic-note-keywords
     nil
     directory
     date
     nil
     (plist-get type-entry :signature)
     (sr/denote-periodic-date-to-identifier type date))))

;;;###autoload
(defun sr/denote-periodic-find-or-create-note (type date)
  "Find the periodic note of TYPE for DATE, creating one if it does not exist."
  (if-let* ((file (denote-get-path-by-id
                   (sr/denote-periodic-date-to-identifier type date))))
      (find-file file)
    (sr/denote-periodic-create-note type date)))

;;;###autoload
(defun sr/denote-periodic-today (type)
  "Find or create the periodic note of TYPE for the current date."
  (interactive (list (intern (completing-read
                              "Note type: " (mapcar #'car sr/denote-periodic-types)
                              nil t))))
  (sr/denote-periodic-find-or-create-note
   type
   (funcall sr/denote-periodic-get-today-date-function)))

;; Convenience functions

(defmacro sr/denote-periodic-define-today-function (name)
  `(defun ,(intern (format "sr/denote-periodic-%s-note-today" name)) ()
     ,(format "Find or create the %s note for the current date." name)
     (interactive)
     (sr/denote-periodic-today ',name)))

(sr/denote-periodic-define-today-function daily)
(sr/denote-periodic-define-today-function weekly)
(sr/denote-periodic-define-today-function monthly)
(sr/denote-periodic-define-today-function yearly)

;;; Daily note mode

(defun sr/denote-periodic-daily-note-id-to-date (identifier)
  "Return the corresponding date of a daily note identifier IDENTIFIER.
if IDENTIFIER is invalid as a daily note identifier, return nil."
  (when (string-match (plist-get (sr/denote-periodic-get-type 'daily) :regexp) identifier)
    ;; (SECOND MINUTE HOUR DAY MONTH YEAR)
    (encode-time 0 0 0
                 (string-to-number (match-string 3 identifier))
                 (string-to-number (match-string 2 identifier))
                 (string-to-number (match-string 1 identifier)))))

(defun sr/denote-periodic-daily-note-buffer-date ()
  (and-let* ((file (buffer-file-name))
             (identifier (denote-retrieve-filename-identifier file)))
    (sr/denote-periodic-daily-note-id-to-date identifier)))

;;;###autoload
(defun sr/denote-periodic-find-previous-daily-note ()
  "Find the previous Denote daily note."
  (interactive)
  (if-let* ((date (sr/denote-periodic-daily-note-buffer-date))
            (prev-date (time-subtract date (days-to-time 1))))
      (if-let ((file (denote-get-path-by-id
                      (sr/denote-periodic-date-to-identifier 'daily prev-date))))
          (funcall denote-open-link-function file)
        (when (y-or-n-p "No previous daily note found. create?")
          (sr/denote-periodic-create-note 'daily prev-date)))
    (user-error "Not inside a Denote daily note")))

;;;###autoload
(defun sr/denote-periodic-find-next-daily-note ()
  "Find the next Denote daily note."
  (interactive)
  (if-let* ((date (sr/denote-periodic-daily-note-buffer-date))
            (next-date (time-add date (days-to-time 1))))
      (if-let ((file (denote-get-path-by-id
                      (sr/denote-periodic-date-to-identifier 'daily next-date))))
          (funcall denote-open-link-function file)
        (when (y-or-n-p "No next daily note found. create?")
          (sr/denote-periodic-create-note 'daily next-date)))
    (user-error "Not inside a Denote daily note")))

(defvar-keymap sr/denote-periodic-daily-note-mode-map
  "C-c j n" #'sr/denote-periodic-find-next-daily-note
  "C-c j p" #'sr/denote-periodic-find-previous-daily-note)

;;;###autoload
(define-minor-mode sr/denote-periodic-daily-note-mode
  "Minor mode for Denote daily notes.")

;;; Calendar integration (in progress)

(defun sr/denote-periodic-daily-note-id-from-calendar (date)
  (format
   "D%d%02d%02d"
   (calendar-extract-year date)
   (calendar-extract-month date)
   (calendar-extract-day date)))

(defun sr/denote-periodic-calendar-mark-notes ()
  ;; (dolist (file (denote-directory-files sr/denote-periodic-daily-note-id-regexp))
  ;;   (calendar-mark-visible-date
  ;;    (sr/time-to-calendar-date
  ;;     (sr/denote-periodic-daily-note-id-to-date (denote-retrieve-filename-identifier file)))
  ;;    sr/denote-periodic-calendar-marker))
  )

(defun sr/denote-periodic-calendar-find-daily-note-at-cursor ()
  (interactive)
  (if-let* ((identifier (sr/denote-periodic-daily-note-id-from-calendar (calendar-cursor-to-date)))
            (file (denote-get-path-by-id identifier)))
      (funcall denote-open-link-function file)
    (user-error "No daily note for date at point")))

(defvar-keymap sr/denote-periodic-calendar-mode-map
  "d" #'sr/denote-periodic-calendar-find-daily-note-at-cursor)

;;;###autoload
(define-minor-mode sr/denote-periodic-calendar-mode
  "Minor mode for navigating Denote periodec notes within `calendar'.

- Mark Denote daily note entries using `sr/denote-periodic-calendar' face.
- Open Denote daily note at point."
  :global nil
  (dolist (hook '(calendar-today-visible-hook calendar-today-invisible-hook))
    (if sr/denote-periodic-calendar-mode
        (add-hook hook #'sr/denote-periodic-calendar-mark-notes nil :local)
      (remove-hook hook #'sr/denote-periodic-calendar-mark-dates :local))))

(add-hook 'calendar-mode-hook #'sr/denote-periodic-calendar-mode)

;;; _

(provide 'sr-denote-periodic)

;;; sr-denote-periodic.el ends here
