;;; sr-emacs.el --- Personal configurations for Emacs core  -*- lexical-binding: t; -*-

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

;;; UI and display

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq frame-inhibit-implied-resize t)
(setq-default frame-title-format "")
(set-frame-parameter nil 'ns-transparent-toolbar t)
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))

(set-face-attribute
 'default nil
 :height 160
 :family "Aporetic Sans Mono")

(set-face-attribute
 'variable-pitch nil
 :height 160
 :family "Pretendard Variable")

(setq-default line-spacing 3)

;;; Custom

(setq custom-unlispify-tag-names nil)
(setq custom-unlispify-menu-entries nil)
(setq custom-unlispify-remove-prefixes nil)

;;; Some random settings

(setq ring-bell-function 'ignore)
(setq create-lockfiles nil)

;;; Global modes

(tab-bar-mode)
(keymap-global-set "C-c <SPC>" tab-prefix-map)
(keymap-set tab-prefix-map "]" 'tab-next)
(keymap-set tab-prefix-map "[" 'tab-previous)
(setq tab-bar-auto-width-max '((140) 20))

(global-visual-line-mode)
(add-hook 'org-agenda-mode-hook
          (lambda ()
            (visual-line-mode 0)))

(which-key-mode)
(recentf-mode)
(savehist-mode)
(blink-cursor-mode -1)

;;; Outline minor mode

(keymap-global-set "<f10>" #'outline-minor-mode)
(setq outline-minor-mode-cycle t)
(setopt outline-minor-mode-prefix "\C-c")

(defun sr/consult-outline ()
  "`consult-outline' with workarounds."
  (interactive)
  (let ((outline-regexp (if (derived-mode-p 'lisp-data-mode)
                            ";;;;* [^ \t\n]" ; show headings only.
                          outline-regexp)))
    (consult-outline)))

(keymap-set outline-minor-mode-map "C-c C-j" #'sr/consult-outline)
(keymap-set outline-minor-mode-map "M-h" #'outline-mark-subtree)

;;; Editing

(setq sentence-end-double-space nil)
(setq sentence-end-base "[.?!…‽,][]\"'”’)}»›]*")

(setq set-mark-command-repeat-pop t)

(setq kill-do-not-save-duplicates t)

(setopt register-use-preview 'insist)
(keymap-set ctl-x-r-map "a" #'append-to-register)

(setq delete-pair-blink-delay 0)
(keymap-global-set "C-M-z" 'delete-pair)

(setq-default fill-column 80)

;; Indentations

(keymap-global-set "S-<return>" #'electric-indent-just-newline)

(with-eval-after-load 'org
  (keymap-unset org-mode-map "S-<return>"))

;; Automatic whitespace deletion

(defun sr/delete-trailing-whitespace-after-newline ()
  "After inserting a newline, delete trailing whitespace in the previous line.
This function is intended to be added to `post-self-insert-hook'."
  (when (and (not (bobp))
             (<= (point) (line-beginning-position)))
    (save-excursion
      (goto-char (1- (point)))
      (skip-syntax-backward "-" (line-beginning-position))
      (delete-region (point) (line-end-position)))))

(add-hook 'post-self-insert-hook #'sr/delete-trailing-whitespace-after-newline)

;; Expreg

(keymap-global-set "C-M-SPC" #'expreg-expand)

;;; Search

(setq lazy-highlight-initial-delay 0)
(setq isearch-lazy-count t)
(setq isearch-allow-motion t)

(put 'beginning-of-defun 'isearch-motion
     (cons #'beginning-of-defun 'forward))

(with-eval-after-load 'treesit
  (put 'treesit-beginning-of-defun 'isearch-motion
       (cons #'treesit-beginning-of-defun 'forward)))

;;; Buffers

(keymap-global-set "C-x C-b" #'ibuffer)

(defvar sr/scratch-file-name (expand-file-name "emacs/lisp/sr-scratch.el" sr/dotfiles-directory))

(defun sr/open-scratch-file ()
  (interactive)
  (find-file sr/scratch-file-name))

(keymap-global-set "<f12>" #'sr/open-scratch-file)

(defun sr/buffer-kill-and-delete-file ()
  "Kill the current buffer, also deleting its file."
  (interactive)
  (delete-file (buffer-file-name))
  (kill-buffer))

(keymap-global-set "C-c C-k" #'sr/buffer-kill-and-delete-file)
(with-eval-after-load 'org
  (keymap-unset org-mode-map "C-c C-k"))

;;; Minibuffer

(keymap-set minibuffer-mode-map "C-p" #'previous-history-element)
(keymap-set minibuffer-mode-map "C-n" #'next-history-element)

(setq use-short-answers t)

;;; Abbrev

(defun sr/define-abbrev-table (name &rest args)
  (if (boundp name)
      (clear-abbrev-table (symbol-value name)))
  (apply #'define-abbrev-table name args))

(defun sr/make-prefixed-abbrev-table (prefix mappings)
  (mapcan
   (lambda (entry)
     (seq-map-indexed
      (lambda (expansion idx)
        (list
         (concat (make-string (1+ idx) prefix) (car entry))
         expansion))
      (cdr entry)))
   mappings))

(sr/define-abbrev-table
 'sr/latex-abbrev-table
 (append

  '(("to" "\\to")
    ("iff" "\\leftrightarrow")
    ("la" "\\land")
    ("lo" "\\lor")
    ("cap" "\\cap")
    ("cup" "\\cup"))

  (sr/make-prefixed-abbrev-table
    ?'
    '(("a" "\\alpha" "\\land")
      ("A" "\\forall" "\\aleph")
      ("b" "\\beta")
      ("e" "\\exists" "\\varnothing")
      ("p" "^\\prime")
      ("pp" "\\textt{++}")
      ("v" "\\lor")
      ("-" "\\neg{")
      ("." " \\cdot")
      ("," " \\circ")))))

(sr/define-abbrev-table
 'org-mode-abbrev-table
 nil
 nil
 :parents (list sr/latex-abbrev-table))

;;;; Dabbrev

(setq dabbrev-check-all-buffers nil)

(defun sr/dabbrev-is-friend-buffer (other-buffer)
  "Custom function for `dabbrev-friend-buffer-function'.
Select buffers that has the same major mode or currently attached to a
window."
  (or (dabbrev--same-major-mode-p other-buffer)
      (get-buffer-window other-buffer)))

(setq dabbrev-friend-buffer-function #'sr/dabbrev-is-friend-buffer)

(setq dabbrev-abbrev-char-regexp "\\sw\\|[_<>-]")
(setq dabbrev-case-replace nil)

;;; Scrolling

;; Do not let automatic scrolling recenter point.
(setq scroll-conservatively 101)

(setq scroll-margin 4)

;; Adjust the point to keep the cursor at the same screen position
;; whenever a scroll command moves it off-window.
(setq scroll-preserve-screen-position nil)

;;; Clipboard

(setq save-interprogram-paste-before-kill t)

(defun sr/normalize-ellipsis (str)
  "Replace … with ... in STR."
  (string-replace "…" "..." str))

(defun sr/gui-selection-value-transformed ()
  "Call `gui-selection-value', then transform its result."
  (let ((selection-value (gui-selection-value)))
    (if (listp selection-value)
        (mapcar #'sr/normalize-ellipsis selection-value)
      (sr/normalize-ellipsis selection-value))))

(setq interprogram-paste-function #'sr/gui-selection-value-transformed)

;;; Themes

;; Modus themes
(require-theme 'modus-themes)
(keymap-global-set "<f5>" 'modus-themes-rotate)
(setq modus-themes-common-palette-overrides modus-themes-preset-overrides-faint)
(modus-themes-load-theme 'modus-vivendi-tinted)

;; Ef themes
(require-theme 'ef-themes)
(ef-themes-take-over-modus-themes-mode 1)

;;; _

(provide 'sr-emacs)

;;; sr-emacs.el ends here
