;;; sr-periodic.el --- Personal periodic note-taking configuration  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Minjeong Kim

;; Author: Minjeong Kim
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

;;; Dependencies

(require 'denote)
(require 'calendar)

;;; Calendar

;;;; Date/time formats

(setq calendar-week-start-day 1)
(calendar-set-date-style 'iso)

(setq calendar-time-zone-style 'numeric)
(setq calendar-date-display-form calendar-iso-date-display-form)

;;;; Holidays

(defvar sr/calendar-korean-holidays
  '((holiday-fixed    1  1 "신정")
    (holiday-chinese  1  1 "설날")
    (holiday-fixed    3  1 "3.1절")
    (holiday-chinese  4  8 "부처님오신날")
    (holiday-fixed    5  1 "노동절")
    (holiday-fixed    5  5 "어린이날")
    (holiday-fixed    6  6 "현충일")
    (holiday-fixed    7 17 "제헌절")
    (holiday-fixed    8 15 "광복절")
    (holiday-chinese  8 15 "추석")
    (holiday-fixed   10  3 "개천절")
    (holiday-fixed   10  9 "한글날")
    (holiday-fixed   12 25 "크리스마스"))
  "Korean holidays.")

;; The standard way here is customizing `holiday-general-holidays', but the
;; calendar buffer uses `calendar-holidays', which by default includes other
;; kinds of holidays too. I don't want to see any other holidays in it, so I set
;; calendar-holidays directly.
(setq calendar-holidays sr/calendar-korean-holidays)

;;;; Buffer display

(setq calendar-left-margin 8)
(setq calendar-intermonth-text
        '(propertize
          (format "%2d"
                  (car
                   (calendar-iso-from-absolute
                    (calendar-absolute-from-gregorian (list month day year)))))
          'face 'font-lock-function-name-face))
(setq calendar-intermonth-spacing 4)
(setq calendar-intermonth-header
      '(propertize
        "W"
        'face 'calendar-weekday-header))

(setq calendar-mark-holidays-flag t)
(setq calendar-date-echo-text
      '(format "ISO date: %s"
               (calendar-iso-date-string
                (list month day year))))

(add-hook 'calendar-today-visible-hook #'calendar-mark-today)

;;;; Window setup

(defun sr/calendar-dedicate-window ()
  (set-window-dedicated-p (get-buffer-window calendar-buffer) t))

(add-hook 'calendar-initial-window-hook #'sr/calendar-dedicate-window)

;;; Denote

;;;; Note types

(defconst sr/denote-periodic-daily-note-id-format "D%Y%m%d")
(defconst sr/denote-periodic-daily-note-id-regexp "D\\([0-9]\\{4\\}\\)\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)")

(defun sr/denote-periodic-daily-note-id-from-date (date)
  (format-time-string sr/denote-periodic-daily-note-id-format date))

(defun sr/denote-periodic-daily-note-id-to-date (identifier)
  "Return the date of the IDENTIFIER.
if IDENTIFIER is not a valid daily note identifier, return nil."
  (when (string-match sr/denote-periodic-daily-note-id-regexp identifier)
    ;; (SECOND MINUTE HOUR DAY MONTH YEAR)
    (encode-time 0 0 0
                 (string-to-number (match-string 3 identifier))
                 (string-to-number (match-string 2 identifier))
                 (string-to-number (match-string 1 identifier)))))

(defconst sr/denote-periodic-monthly-note-id-format "M%Y%m")
(defconst sr/denote-periodic-montly-note-id-regexp "M\\([0-9]\\{6\\}\\)")

(defconst sr/denote-periodic-yearly-note-id-format "Y%Y")
(defconst sr/denote-periodic-yearly-note-id-regexp "W\\([0-9]\\{4\\}\\)")

(defconst sr/denote-periodic-weekly-note-id-format "W%W")
(defconst sr/denote-periodic-weekly-note-id-regexp "W\\([0-9]\\{1,2\\}\\)")

;;;; Note commands

(defun sr/denote-periodic-daily-note-file-date ()
  (and-let* ((file (buffer-file-name))
             (identifier (denote-retrieve-filename-identifier file)))
    (sr/denote-periodic-daily-note-id-to-date identifier)))

(defun sr/denote-periodic-previous-daily-note ()
  (interactive)
  (if-let ((date (sr/denote-periodic-daily-note-file-date)))
      (if-let ((file (denote-get-path-by-id
                      (sr/denote-periodic-daily-note-id-from-date (time-subtract date (days-to-time 1))))))
          (funcall denote-open-link-function file)
        (user-error "No daily note of the previous day was found"))
    (user-error "Not inside a Denote daily note")))

(defun sr/denote-periodic-next-daily-note ()
  (interactive)
  (if-let ((date (sr/denote-periodic-daily-note-file-date)))
      (if-let ((file (denote-get-path-by-id
                      (sr/denote-periodic-daily-note-id-from-date (time-add date (days-to-time 1))))))
          (funcall denote-open-link-function file)
        (user-error "No daily note of the next day was found"))
    (user-error "Not inside a Denote daily note")))

(defvar-keymap sr/denote-periodic-daily-note-mode-map
  "C-c j n" #'sr/denote-periodic-next-daily-note
  "C-c j p" #'sr/denote-periodic-previous-daily-note)

(define-minor-mode sr/denote-periodic-daily-note-mode
  "Minor mode for Denote daily notes.")

(add-to-list
 'magic-mode-alist
 '(sr/denote-periodic-daily-note-file-date . sr/denote-periodic-daily-note-mode))

;;;; Calendar integration

(defun sr/denote-periodic-daily-note-id-from-calendar (date)
  (format
   "D%d%02d%02d"
   (calendar-extract-year date)
   (calendar-extract-month date)
   (calendar-extract-day date)))

(defun sr/denote-periodic-calendar-find-daily-note-at-cursor ()
  (interactive)
  (if-let* ((identifier (sr/denote-periodic-daily-note-id-from-calendar (calendar-cursor-to-date)))
            (file (denote-get-path-by-id identifier)))
      (funcall denote-open-link-function file)
    (user-error "No daily note for date at point")))

(defvar-keymap sr/denote-periodic-calendar-mode-map
  "d" #'sr/denote-periodic-calendar-find-daily-note-at-cursor)

(define-minor-mode sr/denote-periodic-calendar-mode
  "Minor mode for navigating Denote periodec notes within `calendar'.

- Mark Denote daily note entries using `sr/denote-periodic-calendar' face.
- Open Denote daily note at point."
  :global nil)

(add-hook 'calendar-mode-hook #'sr/denote-periodic-calendar-mode)

;;; _
(provide 'sr-periodic)
;;; sr-periodic.el ends here
