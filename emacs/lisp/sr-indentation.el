;;; sr-indentation.el --- Move by indentation  -*- lexical-binding: t; -*-

;; Copyright (C) Minjeong Kim

;; Author: Minjeong Kim <kimsaram32@proton.me>
;; URL: https://github.com/kimsaram32/emacs-config

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Personal library for moving by indentation. Originally from
;; https://emacs.stackexchange.com/a/27169.

;;; Code:
(defun sr/indentation-get-next-good-line (direction skip good)
  "Moving in direction `direction', and skipping over blank lines and lines that
satisfy relation `skip' between their indentation and the original indentation,
finds the first line whose indentation satisfies predicate `good'."
  (let ((starting-indentation (current-indentation))
        (lines-moved direction))
    (save-excursion
      (while (and (zerop (forward-line direction))
                  (or (eolp)  ; Skip past blank lines and other skip lines
                      (funcall
                       skip (current-indentation) starting-indentation)))
        (setq lines-moved (+ lines-moved direction)))
      ;; Now we can't go further. Which case is it?
      (if (and
           (not (eobp))
           (not (bobp))
           (funcall good (current-indentation) starting-indentation))
          lines-moved
        nil))))

(defun sr/indentation-get-next-sibling-line ()
  "The line number of the next sibling, if any."
  (sr/indentation-get-next-good-line 1 '> '=))

(defun sr/indentation-get-previous-sibling-line ()
  "The line number of the previous sibling, if any"
  (sr/indentation-get-next-good-line -1 '> '=))

(defun sr/indentation-get-parent-line ()
  "The line number of the parent, if any."
  (sr/indentation-get-next-good-line -1 '>= '<))

(defun sr/indentation-get-child-line ()
  "The line number of the first child, if any."
  (sr/indentation-get-next-good-line +1 'ignore '>))

(defun sr/indentation-move-to-line (func preserve-column name)
  "Move the number of lines given by func. If not possible, use `name' to
say so."
  (let ((saved-column (current-column))
        (lines-to-move-by (funcall func)))
    (if lines-to-move-by
        (progn
          (forward-line lines-to-move-by)
          (move-to-column (if preserve-column
                              saved-column
                            (current-indentation))))
      (message "No %s to move to." name))))

(defun sr/indentation-forward-to-next-sibling ()
  "Move to the next sibling if any, retaining column position."
  (interactive "@")
  (sr/indentation-move-to-line
   'sr/indentation-get-next-sibling-line
   t "next sibling"))

(defun sr/indentation-backward-to-previous-sibling ()
  "Move to the previous sibling if any, retaining column position."
  (interactive "@")
  (sr/indentation-move-to-line
   'sr/indentation-get-previous-sibling-line
   t "previous sibling"))

(defun sr/indentation-up-to-parent ()
  "Move to the parent line if any."
  (interactive "@")
  (sr/indentation-move-to-line 'sr/indentation-get-parent-line nil "parent"))

(defun sr/indentation-down-to-child ()
  "Move to the first child line if any."
  (interactive "@")
  (sr/indentation-move-to-line 'sr/indentation-get-child-line nil "child"))

(defvar-keymap sr/indentation-mode-map
  "C-M-u" #'sr/indentation-up-to-parent
  "C-M-d" #'sr/indentation-down-to-child
  "C-M-n" #'sr/indentation-forward-to-next-sibling
  "C-M-p" #'sr/indentation-backward-to-previous-sibling
  "C-M-f" #'sr/indentation-backward-to-next-sibling
  "C-M-b" #'sr/indentation-backward-to-previous-sibling)

(define-minor-mode sr/indentation-mode
  "Minor mode to move by indentation."
  :init-value nil
  :lighter " Indentation"
  :keymap sr/indentation-mode-map)

(provide 'sr-indentation)
;;; sr-vm.el ends here
