;;; sr-projects.el --- Personal configuration for project-specific automations  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Minjeong Kim

;; Author: Minjeong Kim <mail@kimsaram.dev>
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

;;;; Convert Markdown to Org

(defvar sr/project-public-is-conversion-target-p
  (lambda (file) (string-suffix-p ".org" file)))

(defvar sr/project-public-get-conversion-dest-file
  (lambda (src) (concat (file-name-sans-extension src) ".md")))

(defvar sr/project-public-conversion-pandoc-args
  '("--from" "org" "--to" "markdown-inline_code_attributes" "--columns" "80"))

(defvar sr/project-public-after-conversion-hook nil
  "Hook run after generating a conversion preview.
It is called inside the conversion buffer.")

(add-hook 'sr/project-public-after-conversion-hook #'markdown-mode)

(defvar sr/project-public--conversion-dired-buffer nil)
(defvar sr/project-public--conversion-queue nil)

(defun sr/project-public--finalize-conversion ()
  (interactive)
  (let* ((src (car sr/project-public--conversion-queue))
         (buf (current-buffer))
         (dest (funcall sr/project-public-get-conversion-dest-file src)))
    (with-current-buffer (find-file-noselect dest)
      (erase-buffer)
      (insert-buffer buf)
      (save-buffer))
    (sr/project-public--skip-conversion)))

(defun sr/project-public--skip-conversion ()
  (interactive)
  (kill-buffer (find-file-noselect (car sr/project-public--conversion-queue)))
  (setq sr/project-public--conversion-queue
        (cdr sr/project-public--conversion-queue))
  (sr/project-public--process-next-conversion))

(defun sr/project-public--display-src-buffer ()
  (display-buffer
   (find-file-noselect (car sr/project-public--conversion-queue))
   '(display-buffer-pop-up-window)))

(defvar-keymap sr/project-public--conversion-minor-mode-map
  "C-c C-f" #'sr/project-public--finalize-conversion
  "C-c C-s" #'sr/project-public--skip-conversion)

(define-minor-mode sr/project-public--conversion-minor-mode
  "Minor mode for confirming/skipping markdown conversions."
  :lighter " Conversion"
  (setq header-line-format
        (substitute-command-keys
         "Type \\[sr/project-public--finalize-conversion] to finalize, \
and \\[sr/project-public--skip-conversion] to skip.")))

(defun sr/project-public--process-next-conversion ()
  (let ((src (car sr/project-public--conversion-queue))
        (buf (get-buffer-create "*conversion preview*")))
    (if src
        (progn
          (switch-to-buffer buf)
          (erase-buffer)
          (apply #'call-process "pandoc" src t nil sr/project-public-conversion-pandoc-args)
          (run-hooks 'sr/project-public-after-conversion-hook)
          (sr/project-public--conversion-minor-mode 1)
          (sr/project-public--display-src-buffer))
      (kill-buffer buf)
      (message "Conversion finished")
      (switch-to-buffer sr/project-public--conversion-dired-buffer)
      (revert-buffer))))

(defun sr/project-public-convert-marked-files ()
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (user-error "Not in a Dired buffer"))
  (setq
   sr/project-public--conversion-queue
   (dired-get-marked-files nil nil sr/project-public-is-conversion-target-p nil t))
  (setq sr/project-public--conversion-dired-buffer (current-buffer))
  (sr/project-public--process-next-conversion))

;;; Dotfiles

(defun sr/project-dotfiles-list-external-software ()
  "Return the list of external software used in the Emacs configuration."
  (let* ((files (seq-filter
                 (lambda (file) (string-suffix-p ".el" file))
                 (project-files (project-current))))
         (matches))
    (with-temp-buffer
      (apply
       'call-process
       "grep" nil t nil "^;; EXTERNAL: "
       files)
      (goto-char (point-min))
      (while (re-search-forward ";; EXTERNAL: \\(.+\\)$" nil t)
        (push (match-string 1) matches))
      matches)))

(defun sr/project-dotfiles-insert-external-software ()
  "Insert the list of external software, formatted as a list."
  (interactive)
  (dolist (item (sr/project-dotfiles-list-external-software))
    (insert "- ")
    (insert item)
    (insert "\n")))

(defun sr/project-dotfiles-generate-loaddefs ()
  "Generate loaddefs for the Lisp libraries."
  (interactive)
  (let* ((library-directory
          (expand-file-name "emacs/libraries" (project-root (project-current))))
         (output-file
          (expand-file-name "sr-autoloads.el" library-directory)))
    (loaddefs-generate library-directory output-file)
    (message
     (format
      "Generated loaddefs file for Lisp files in '%s'"
      library-directory output-file))))

;;; Website accounts

(defconst sr/website-account-list-file
  "/Users/kimsaram32/me/secrets/accounts.txt"
  "File to record websites where I have created an account.")

(defun sr/website-account-check-existence (url)
  "Check whether an account exists on website for URL."
  (interactive (list (read-string "Enter URL for website: "))))

(defun sr/website-account-record (host)
  "Record that an account is created for website with HOST."
  (interactive (list (read-string "I have an account on: ")))
  (with-current-buffer (find-file-noselect sr/website-account-list-file)
    (goto-char (point-max))
    (insert host)
    (insert "\n"))
  (message (format "Recorded %s" host)))

;;; _

(provide 'sr-projects)

;;; sr-projects.el ends here
