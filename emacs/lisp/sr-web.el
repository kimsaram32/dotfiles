;;; sr-web.el --- Personal configuration for browsing the web  -*- lexical-binding: t; -*-

;; Copyright (C) Minjeong Kim

;; Author: Minjeong Kim <kimsaram32@fastmail.com>
;; URL: https://github.com/kimsaram32/dotfiles

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
;; Personal library for Web browsing configuration.

;;; Code:

(require 'shr)
(require 'eww)
(require 'browse-url)
(require 'goto-addr)

;;; Shr

(setq shr-max-width 80)
(setq shr-use-colors nil)
(setq shr-max-image-proportion 0.7)
(setq shr-bullet "- ")

;;; EWW

(defun sr/eww-enable-diff-mode-github-diff ()
  (when (string-match-p "github\\.com.+\\.diff$" (eww-current-url))
    (diff-mode)))

(add-hook 'eww-after-render-hook #'sr/eww-enable-diff-mode-github-diff)

;;; Browse-url

;; My customization for browsing functions: (1) Use EWW by default while
;; providing an option to use external browsers. (2) Use external browsers for
;; URLs known to require JavaScript.

(setq browse-url-browser-function #'eww-browse-url)
(setq browse-url-secondary-browser-function #'browse-url-default-browser)

(setq browse-url-handlers
      '(("github\\.com.+\\.diff$" . eww-browse-url)
        ("github\\.com" . browse-url-default-browser)
        ("youtube\\.com" . browse-url-default-browser)
        ("reddit\\.com" . browse-url-default-browser)
        ("localhost" . browse-url-default-browser)))

;;; Goto address mode

(keymap-set goto-address-highlight-keymap "C-c C-o" #'goto-address-at-point)

;;; _

(provide 'sr-web)

;;; sr-web.el ends here
