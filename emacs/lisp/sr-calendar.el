;;; sr-calendar.el --- Personal calendar configurations  -*- lexical-binding: t; -*-

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

(require 'calendar)

;;; Date/time formats

(setq calendar-week-start-day 1)
(calendar-set-date-style 'iso)

(setq calendar-time-zone-style 'numeric)
(setq calendar-date-display-form calendar-iso-date-display-form)

;;; Holidays

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

;;; Buffer display

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

;;; Window setup

(defun sr/calendar-dedicate-window ()
  (set-window-dedicated-p (get-buffer-window calendar-buffer) t))

(add-hook 'calendar-initial-window-hook #'sr/calendar-dedicate-window)

(provide 'sr-calendar)

;;; sr-calendar.el ends here
