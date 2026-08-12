;;; sr-environment.el --- Personal environment-specific configurations  -*- lexical-binding: t; -*-

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

;; Workaround: 'Invalid function: org-element-with-disabled-cache'
;; https://www.reddit.com/r/emacs/comments/1hayavx/invalid_function_orgelementwithdisabledcache/

(setq native-comp-jit-compilation-deny-list '(".*org-element.*"))
(load-library "org-element.el")

;; mise integration
;; https://mise.jdx.dev/ide-integration.html#emacs

(setenv "PATH" (concat (getenv "PATH") ":/home/user/.local/share/mise/shims"))
(setq exec-path (append exec-path '("/home/user/.local/share/mise/shims")))

;; exec-path-from-shell

(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; macOS keyboard

(setq mac-option-modifier 'meta)

;;; _

(provide 'sr-environment)

;;; sr-environment.el ends here
