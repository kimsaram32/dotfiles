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

(defcustom sr/english-srs-file
  (expand-file-name "english.org" sr/note-flashcards-directory)
  "Location to the SRS file for storing English flashcards."
  :type 'file
  :set-after '(sr/note-flashcards-directory))

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

;;; SRS

;; TODO: Maybe merge with `'sr/denote-get-initial-data-dwim'?
(defun sr/english-get-buffer-page ()
  "Get the web page information the current buffer is visiting.
Return a plist consisting of two properties: URL and TITLE. TITLE can be
nil."
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

(defun sr/english-capture-region-pause-and-think ()
  "Add the region's content as a pause-and-think entry to the SRS file.
Navigate to the buffer visiting the file, and place the point to the
beginning of the text."
  (interactive)
  ;; TODO lazy-load the library instead
  (require 'org)
  (unless (region-active-p)
    (user-error "The region is not active"))
  (let* ((content (buffer-substring (region-beginning) (region-end)))
         (page (sr/english-get-buffer-page))
         (link (and page
                    (org-link-make-string
                     (plist-get page :url)
                     (plist-get page :title))))
         (buf (or (get-file-buffer sr/english-srs-file)
                  (create-file-buffer sr/english-srs-file)))
         (start-pos))
    (switch-to-buffer buf)
    (goto-char (point-max))
    ;; Invariant: Each flashcard should end with an empty line. This still does
    ;; not prevent from having multiple empty lines though.
    (unless (looking-at "^$")
      (insert "\n"))
    (setq start-pos (point))
    (insert "\nPause-and-think: ")
    (save-excursion
      (insert content)
      (fill-region start-pos (point))
      ;; `fill-region' does not work properly with Org mode links, as
      ;; they have different displayed string length.
      (when page
        (insert (format " (%s)" link)))
      (insert "\n\n-\n"))))

;;; _

(provide 'sr-english)

;;; sr-english.el ends here
