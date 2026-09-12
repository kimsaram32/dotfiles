;;; sr-scratch.el --- Personal library for managing scratch files  -*- lexical-binding: t; -*-

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

(defgroup sr/scratch nil
  "Simple management of scratch files."
  :group 'file)

(defcustom sr/scratch-directory (expand-file-name "~/me/scratch/")
  "Directory for scratch files."
  :type 'directory)

(defcustom sr/scratch-file-alist
  '((emacs-lisp-mode . "elisp.el"))
  "Alist of scratch files.
Each element is of the form (MODE . FILE). MODE is the major mode of the
scratch file, and FILE is its file name (just the base name and
extension)."
  :type '(repeat (group string symbol)))

(defcustom sr/scratch-default-major-mode 'emacs-lisp-mode
  "Major mode that specifies the default scratch file.
It must be one of the major modes listed in `sr/scratch-file-alist'."
  :type 'symbol)

(defvar sr/scratch-major-mode-prompt-history nil
  "Minibuffer history for major mode prompt.")

(defun sr/scratch--file-name (mode)
  "Return the full scratch file name for major mode MODE."
  (expand-file-name
   (alist-get mode sr/scratch-file-alist)
   sr/scratch-directory))

;;;###autoload
(defun sr/scratch-open-default ()
  "Open the scratch file for the default major mode."
  (interactive)
  (find-file (sr/scratch--file-name sr/scratch-default-major-mode)))

;;;###autoload
(defun sr/scratch-open (mode)
  "Open the scratch file for major mode MODE.
Interactively, prompt for MODE."
  (interactive
   (list
    (intern (completing-read
             "Select major mode: "
             (mapcar #'car sr/scratch-file-alist)
             nil t nil
             sr/scratch-major-mode-prompt-history
             (symbol-name sr/scratch-default-major-mode)))))
  (find-file (sr/scratch--file-name mode)))

;;; _

(provide 'sr-scratch)

;;; sr-scratch.el ends here
