;;; sr-projects.el --- Personal configuration for project-specific automations  -*- lexical-binding: t; -*-

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

(require 'project)

;;; Common

(defmacro sr/project-with-root (&rest body)
  `(let ((default-directory (project-root (project-current t))))
     ,@body))

(defmacro sr/project-define-simple-compile (name command)
  `(defun ,name ()
     (declare (interactive-only t))
     (interactive)
     (sr/project-with-root
      (compile ,command))))

;;; YICHE

;; <https://github.com/kimsaram32/yiche-lang>

(sr/project-define-simple-compile
 sr/project-yiche-run
 "cmake --build build && ./build/bin/yiche < test.txt")

(sr/project-define-simple-compile
 sr/project-yiche-test
 "cmake --build build && ctest --test-dir build --verbose")

(sr/project-define-simple-compile
 sr/project-yiche-leaks
 "cmake --build build && leaks --atExit -- ./build/bin/yiche < test.txt")

(sr/project-define-simple-compile
 sr/project-yiche-generate-test-outputs
 "cmake --build build --target generate_outputs")

(defun sr/project-yiche-debug ()
  (declare (interactive-only t))
  (interactive)
  (sr/project-with-root
   (compile "cmake -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build")
   (call-interactively 'lldb)))

(defvar-keymap sr/project-yiche-map)
(keymap-global-set "C-c y" sr/project-yiche-map)

(keymap-set sr/project-yiche-map "r" #'sr/project-yiche-run)
(keymap-set sr/project-yiche-map "t" #'sr/project-yiche-test)
(keymap-set sr/project-yiche-map "d" #'sr/project-yiche-debug)
(keymap-set sr/project-yiche-map "l" #'sr/project-yiche-leaks)
(keymap-set sr/project-yiche-map "o" #'sr/project-yiche-generate-test-outputs)

;;; Public learning

;; <https://github.com/kimsaram32/learn>

(defun sr/project-public-upload ()
  "Commit and push changes made in the public repository."
  (interactive)
  (save-some-buffers t)
  (let* ((date-string (format-time-string "%Y%m%d" (sr/note-current-date)))
	     (subcommands `(("commit" "-m" ,date-string)
			            ("push"))))
    (dolist (args subcommands)
	  (apply 'call-process (append '("git" nil nil nil) args)))
    (message (format "%s uploaded." date-string))))

(provide 'sr-projects)
;;; sr-projects.el ends here
