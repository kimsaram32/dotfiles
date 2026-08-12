;;; sr-window.el --- Window configurations  -*- lexical-binding: t; -*-

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

;;; Configurations

(setq window-combination-resize t)

(keymap-global-set "C-M-c" #'scroll-other-window-down)
(keymap-global-unset "C-x o")
(keymap-global-set "M-o" #'other-window)

(setq switch-to-buffer-obey-display-actions t)

(defvar-keymap sr/window-map
  :doc "Keymap for window-related functionalities.")

(keymap-set ctl-x-map "C-w" sr/window-map)

;; Remove colliding maps
(with-eval-after-load 'org-agenda
  (keymap-unset org-agenda-mode-map "C-x C-w"))

;;; Windmove

(keymap-set sr/window-map "C-f" #'windmove-swap-states-right)
(keymap-set sr/window-map "C-b" #'windmove-swap-states-left)
(keymap-set sr/window-map "C-p" #'windmove-swap-states-up)
(keymap-set sr/window-map "C-n" #'windmove-swap-states-down)

;;; Winner mode

(setq winner-dont-bind-my-keys t)
(winner-mode)

(keymap-set sr/window-map "<left>" #'winner-undo)
(keymap-set sr/window-map "<right>" #'winner-redo)

;;; Window setup (display-buffer-alist)

(setq display-buffer-alist nil)

;; Help and occur

(add-to-list
 'display-buffer-alist
 `((or
	(derived-mode help-mode)
    (derived-mode helpful-mode)
	(derived-mode occur-mode))
   (display-buffer-in-side-window)
   (side . bottom)
   (window-height . 0.4)
   (post-command-select-window . t)))

;; Info and apropos

;; (add-to-list
;;  'display-buffer-alist
;;  `((or
;; 	(derived-mode Info-mode)
;; 	(derived-mode apropos-mode))
;;    (display-buffer-reuse-mode-window display-buffer-in-side-window)
;;    (mode . Info-mode)
;;    (side . right)
;;    (window-width . 0.5)
;;    (post-command-select-window . t)))

;; Manuals

(defconst sr/manual-mode-list
  '(Man-mode kubedoc-mode)
  "List of major modes that function as manuals.")

(add-to-list
 'display-buffer-alist
 `((or
    ,@(mapcar (lambda (x) (list 'derived-mode x)) sr/manual-mode-list))
   (display-buffer-reuse-mode-window display-buffer-in-side-window)
   (mode . ,sr/manual-mode-list)
   (side . right)
   (window-width . 0.5)
   (post-command-select-window . t)))

(with-eval-after-load 'man
  (setq Man-notify-method 'thrifty))

(add-hook 'Man-mode-hook
          (lambda ()
			(set-window-dedicated-p (selected-window) nil)))

;; Tabulated lists

(add-to-list
 'display-buffer-alist
 `((derived-mode tabulated-list-mode)
   (display-buffer-in-side-window)
   (side . bottom)
   (window-height . 0.5)
   (post-command-select-window . t)))

;; Eldoc

(add-to-list
 'display-buffer-alist
 `("^\\*eldoc"
   (display-buffer-in-side-window)
   (side . bottom)
   (window-height . 20)
   (post-command-select-window . t)))

;;; _

(provide 'sr-windows)

;;; sr-windows.el ends here
