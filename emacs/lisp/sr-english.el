;;; sr-english.el --- Personal configuration for English learning  -*- lexical-binding: t; -*-

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

(require 'srs)

(defgroup sr/english nil
  "Personal English learning."
  :group 'application)

(defcustom sr/english-dictionary-url
  "https://www.merriam-webster.com/dictionary/%s"
  "Format string for English dictionary."
  :type 'string)

(defcustom sr/english-capture-file
  (expand-file-name "english2.org" sr/note-root-directory)
  "Location to the SRS file for storing English flashcards."
  :type 'file
  :set-after '(sr/note-root-directory))

;;; Dictionary

;; I tried using EWW to browse words inside Emacs, but the site feels broken
;; when rendered in pure HTML. EWW overrides `browse-url-browser-function' to
;; `eww-browse-url', so to avoid using EWW, I overrode it.

(defun sr/english-browse-dictionary-at-point ()
  "Look up dictionary for a word at point."
  (interactive)
  (if-let* ((word (if (region-active-p)
                      (buffer-substring (region-beginning) (region-end))
                    (word-at-point t)))
            (browse-url-browser-function 'browse-url-default-browser)) ; do not use EWW
      (browse-url (url-encode-url (format sr/english-dictionary-url word)))
    (user-error "No word found at point")))

(keymap-global-set "C-c d d" #'sr/english-browse-dictionary-at-point)

;;; Sentences

;; TODO: Maybe merge with `'sr/denote-get-initial-data-dwim'?
(defun sr/english-get-buffer-page ()
  "Get the web page information the current buffer is visiting.
Return a plist consisting of two properties: URL and TITLE. TITLE can be
nil. When there is no appropriate page data, return nil."
  (cond
   ((eq major-mode 'eww-mode)
    (list
     :url (eww-current-url)
     :title (plist-get eww-data :title)))
   ((eq major-mode 'elfeed-show-mode)
    (let ((entry elfeed-show-entry))
      (list
       :url (elfeed-entry-link entry)
       :title (elfeed-entry-title entry))))))

(defun sr/english-capture (content page)
  "Add a new entry in the capture file.
Navigate to the buffer visiting the file, and place the point to the
beginning of the text.

CONTENT is the English text to capture, and PAGE is either nil or a plist
returned by `sr/english-get-buffer-page'."
  (interactive
   (list (read-string-from-buffer "Content: " "")
         (sr/english-get-buffer-page)))
  (if (string-empty-p content)
      (user-error "Empty content"))
  (let* ((link (and page
                    (org-link-make-string
                     (plist-get page :url)
                     (plist-get page :title))))
         (buf (or (get-file-buffer sr/english-capture-file)
                  (create-file-buffer sr/english-capture-file)))
         (start-pos))
    (switch-to-buffer buf)
    (goto-char (point-min))
    (setq start-pos (point))
    (save-excursion
      (insert (format "* A\n\n%s" content))
      (fill-region start-pos (point))
      (when page
        (insert (format "\n\n%s" link)))
      (insert "\n\n"))))

(defun sr/english-capture-region ()
  "Call `sr/english-capture' with the region's content."
  (interactive)
  ;; TODO lazy-load the library instead
  (require 'org)
  (unless (use-region-p)
    (user-error "The region is not active"))
  (sr/english-capture
     (buffer-substring (region-beginning) (region-end))
     (sr/english-get-buffer-page)))

(defun sr/english-capture-dwim ()
  "Add a new entry in the capture file with appropriate data."
  (interactive)
  (if (use-region-p)
      (sr/english-capture-region)
    (call-interactively #'sr/english-capture)))

;;; _

(provide 'sr-english)

;;; sr-english.el ends here
