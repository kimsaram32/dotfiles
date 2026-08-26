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

(require 'org)

(defgroup sr/english nil
  "Personal English learning."
  :group 'application)

(defcustom sr/english-dictionary-url
  "https://www.merriam-webster.com/dictionary/%s"
  "Format string for opening English dictionary."
  :type 'string)

(defcustom sr/english-capture-file
  (expand-file-name "english2.org" sr/note-root-directory)
  "Location to the file storing captured English sentences."
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

;;; Sentence capture

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

;;; Capture buffer

(defun sr/english--capture-org-timestamp-string-to-time (string)
  (org-timestamp-to-time (org-timestamp-from-string string)))

(defun sr/english--capture-hide-entry ()
  (let ((overlay (make-overlay
                  (org-entry-beginning-position)
                  (org-entry-end-position))))
    (overlay-put overlay 'invisible 'english-capture)))

(defun sr/english--capture-show-entry ()
  (remove-overlays
   (org-entry-beginning-position)
   (org-entry-end-position)
   'invisible 'english-capture))

(defun sr/english--capture-is-entry-due ()
  "Return t if entry at point is due today."
  (let ((time (sr/english--capture-org-timestamp-string-to-time
               (org-entry-get (point) "NEXT_REVIEW"))))
     (or (time-less-p time (current-time))
         (time-equal-p time (current-time)))))

(defvar-local sr/english--capture-non-due-hidden nil)

(defun sr/english-capture-hide-non-due ()
  "Hide non-due entries."
  (interactive)
  (setq sr/english--capture-non-due-hidden t)
  (org-scan-tags
   #'sr/english--capture-hide-entry
   (lambda (todo tags level) (not (sr/english--capture-is-entry-due)))
   nil))

(defun sr/english-capture-show-non-due ()
  "Show non-due entries."
  (interactive)
  (setq sr/english--capture-non-due-hidden nil)
  (remove-overlays (point-min) (point-max) 'invisible 'english-capture))

(defun sr/english-capture-toggle-non-due-visibility ()
  "Toggle whether non-due entries are visible."
  (interactive)
  (if sr/english--capture-non-due-hidden
      (sr/english-capture-show-non-due)
    (sr/english-capture-hide-non-due)))

(defun sr/english-capture-finish-review-at-point (next-review)
  "Update review properties for entry at point.
NEXT-REVIEW must be a time value."
  (interactive
   (list (let* ((last-interval
                 (-
                  (time-to-days
                   (sr/english--capture-org-timestamp-string-to-time
                    (org-entry-get (point) "NEXT_REVIEW")))
                  (time-to-days
                   (sr/english--capture-org-timestamp-string-to-time
                    (org-entry-get (point) "LAST_REVIEW")))))
                (prompt (format "Next review date (last interval was %d): " last-interval)))
           (date-to-time (org-read-date nil nil nil prompt)))))
  (org-entry-put (point) "NEXT_REVIEW"
                 (format-time-string (org-time-stamp-format) next-review))
  (org-entry-put (point) "LAST_REVIEW"
                 (format-time-string (org-time-stamp-format) (current-time)))
  (if sr/english--capture-non-due-hidden
      (sr/english--capture-hide-entry)))

(defvar-keymap sr/english-capture-mode-map
  "C-c C-." #'sr/english-capture-toggle-non-due-visibility
  "C-c r r" #'sr/english-capture-finish-review-at-point)

(define-minor-mode sr/english-capture-mode
  "Minor mode for the English capture buffer."
  :global nil
  :lighter " Eng"
  (if sr/english-capture-mode
      (progn
        (add-to-invisibility-spec 'english-capture))
    (sr/english-capture-show-non-due)
    (remove-from-invisibility-spec 'english-capture)))

;;; _

(provide 'sr-english)

;;; sr-english.el ends here
