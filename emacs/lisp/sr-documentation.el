;;; sr-documentation.el --- Personal configuration for reading documentation  -*- lexical-binding: t; -*-

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

(require 'help)

;;; elisp-demos

(advice-add 'describe-function-1 :after #'elisp-demos-advice-describe-function-1)
(advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update)

;;; apropos key bindings

(unbind-key "a" help-map)

(keymap-set help-map "a a" 'apropos-command)
(keymap-set help-map "a f" 'apropos-function)
(keymap-set help-map "a v" 'apropos-variable)
(keymap-set help-map "a u" 'apropos-user-option)
(keymap-set help-map "a l" 'apropos-library)

;;; helpful

(require 'helpful)

(keymap-set help-map "f" #'helpful-function)
(keymap-set help-map "v" #'helpful-variable)
(keymap-set help-map "k" #'helpful-key)
(keymap-set help-map "x" #'helpful-command)
(keymap-set help-map "o" #'helpful-symbol)

;;; man

(with-eval-after-load 'man
  ;; disable autocompletion by overriding the completion table function that the
  ;; `man' command uses. It's slow for me, and I don't need this feature.
  (defun Man-completion-table (str pred flag)
	  '()))

;;; _

(provide 'sr-documentation)

;;; sr-documentation.el ends here
