;;; sr-english-config.el --- Personal configuration for English learning  -*- lexical-binding: t; -*-

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

(with-eval-after-load 'sr-english
  (setq sr/english-capture-file (expand-file-name "english2.org" sr/note-root-directory)))

(keymap-global-set "C-c d d" #'sr/english-browse-dictionary-at-point)
(keymap-global-set "C-c d c" #'sr/english-capture-dwim)

;;; _

(provide 'sr-english-config)

;;; sr-english-config.el ends here
