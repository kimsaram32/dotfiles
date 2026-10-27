;;; sr-web.el --- Personal configuration for browsing the web  -*- lexical-binding: t; -*-

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

;;; Shr

(with-eval-after-load 'shr
  (setq shr-max-width 80)
  (setq shr-use-colors nil)
  (setq shr-max-image-proportion 0.7)
  (setq shr-bullet "- "))

;;; EWW

(defun sr/eww-rename-buffer ()
  (when (eq major-mode 'eww-mode)
    (when-let* ((name (or (plist-get eww-data :title)
                          (plist-get eww-data :url)
                          "Untitled")))
      (format "*eww: %s*" name))))

(defun sr/eww-enable-diff-mode-github-diff ()
  (when (string-match-p "github\\.com.+\\.diff$" (eww-current-url))
    (diff-mode)))

(with-eval-after-load 'eww
  (setq eww-auto-rename-buffer #'sr/eww-rename-buffer)
  (setq eww-browse-url-new-window-is-tab nil)

  (add-hook 'eww-mode #'outline-minor-mode)
  (add-hook 'eww-after-render-hook #'sr/eww-enable-diff-mode-github-diff))

;;; Browse-url

;; My customization for browsing functions: (1) Use EWW by default while
;; providing an option to use external browsers. (2) Use external browsers for
;; URLs known to require JavaScript.

(defvar sr/browse-url-external-url-regexp-list
  '("github\\.com"
    "youtube\\.com"
    "youtu\\.be"
    "reddit\\.com"
    "lobste\\.rs"
    "merriam-webster\\.com"
    "dictionary\\.cambridge\\.org"
    "localhost")
  "List of regexps that match external URLs.
Used to set the value for `browse-url-handlers'.")

(with-eval-after-load 'browse-url
  (setq browse-url-browser-function #'eww-browse-url)
  (setq browse-url-secondary-browser-function #'browse-url-default-browser)

  (setq browse-url-handlers
        `(("github\\.com.+\\.diff$" . eww-browse-url)
          ,@(mapcar
             (lambda (regexp)
               (cons regexp #'browse-url-default-browser))
             sr/browse-url-external-url-regexp-list))))

;;; Goto address mode

(with-eval-after-load 'goto-addr
  (keymap-set goto-address-highlight-keymap "C-c C-o" #'goto-address-at-point))

;;; Elfeed

;;;; Configuration

(keymap-global-set "C-c w" #'elfeed)

(with-eval-after-load 'elfeed
  (setq-default elfeed-search-filter "+unread -to-read-list")
  (remove-hook 'elfeed-search-update-hook #'elfeed-search-add-separators)

  (keymap-set elfeed-show-mode-map "w" #'sr/elfeed-show-visit-eww)
  (keymap-set elfeed-show-mode-map "a" 'sr/elfeed-show-add-to-read)
  (keymap-set elfeed-show-mode-map "r" #'sr/elfeed-show-read)

  (keymap-set elfeed-search-mode-map "l" 'sr/elfeed-search-show-to-reads)
  (keymap-set elfeed-search-mode-map "e" 'sr/elfeed-export-entries)
  (keymap-set elfeed-search-mode-map "r" #'sr/elfeed-search-read)

  (sr/elfeed-load-entries))

(defvar sr/elfeed-to-read-tag 'to-read-list
  "Elfeed tag for 'to read' entries.")

;;;; Load entries

(defun sr/elfeed-load-entries ()
  "Load entries from elfeed.org."
  (interactive)
  (org-babel-load-file (expand-file-name "emacs/elfeed.org" sr/dotfiles-directory)))

;;;; Integration with EWW

(defun sr/elfeed-show-visit-eww ()
  "Visit the current entry with `eww'."
  (interactive)
  (when-let* ((link (elfeed-entry-link elfeed-show-entry)))
    (eww link)))

;;;; Managing 'to read' entries

(defun sr/elfeed-show-add-to-read ()
  "Add current entry to 'to read' list and go to the next entry."
  (interactive)
  (when-let ((entry elfeed-show-entry))
    (elfeed-show-tag 'unread sr/elfeed-to-read-tag)
    (message "Addded entry to to-read list")
    (elfeed-show-next)))

(defun sr/elfeed-show-add-to-read ()
  "Add current entry to 'to read' list and go to the next entry."
  (interactive)
  (when-let ((entry elfeed-show-entry))
    (elfeed-show-tag 'unread sr/elfeed-to-read-tag)
    (message "Addded entry to to-read list")
    (elfeed-show-next)))

(defun sr/elfeed-search-show-to-reads ()
  "Set Elfeed filter to show 'to read' entries only."
  (interactive)
  (elfeed-search-set-filter "+to-read-list"))

(defun sr/elfeed-export-entries ()
  "Push current entries to the mark ring."
  (interactive)
  (kill-new (string-join
  	       (mapcar
  	        (lambda (entry) (elfeed-entry-link entry))
  	        (if (region-active-p)
                  (elfeed-search-selected)
                elfeed-search-entries))
  	       "\n"))
  (message "Pushed current entries to the mark ring."))

;;;; Mark entries as read

(defun sr/elfeed-search-read ()
  "Read elfeed entries in search mode."
  (interactive)
  (let ((entries (elfeed-search-selected)))
    (elfeed-untag entries 'unread)
    (elfeed-untag entries sr/elfeed-to-read-tag)
    (mapc #'elfeed-search-update-entry entries)
    (unless (or elfeed-search-remain-on-entry (use-region-p))
      (forward-line))))

(defun sr/elfeed-show-read ()
  "Read current elfeed entry."
  (interactive)
  (elfeed-show-untag 'unread 'to-read-list))

;;; Downloading HTTP documents

(defvar sr/download-directory "~/Downloads/"
  "Base directory for downloaded documents.")

(defvar sr/download-http-url-prompt-history nil
  "Minibuffer history for URL prompt in `sr/download-http'.")

(defun sr/download-http (url file)
  "Retrieve document at URL and save it to FILE."
  (interactive
   (let ((url (read-string "URL: " nil sr/download-http-url-prompt-history)))
     (list url
           (expand-file-name
            (read-file-name "File: " sr/download-directory nil nil
                            (file-name-nondirectory
                             (car (url-path-and-query (url-generic-parse-url url)))))
            sr/download-directory))))
  (when (not (string= (file-name-directory file)
                      (expand-file-name sr/download-directory)))
    (user-error
     "Invalid file name '%s': must be inside `sr/download-directory'"
     file))
  (let* ((url-buffer (url-retrieve-synchronously url)))
    (find-file file)
    (erase-buffer)
    (insert-buffer-substring
     url-buffer
     (with-current-buffer url-buffer
       (url-http-parse-headers)
       (goto-char url-http-end-of-headers)
       (forward-char)
       (point)))))

;;; Quicklinks

(defvar sr/quicklink-alist
  '((merriam-webster
     :url "https://www.merriam-webster.com/dictionary/%s")
    (google
     :url "https://google.com/search?q=%s&udm=14&lr=lang_en")
    (cambridge
     :url "https://dictionary.cambridge.org/dictionary/english/%s")))

(defun sr/quicklink-word-dwim ()
  "Return the appropriate word to use in quicklinks.
Currently, it tries the following in order:
1. The region's text, if it's active.
2. The word at point."
  (if (region-active-p)
      (buffer-substring (region-beginning) (region-end))
    (word-at-point t)))

(defun sr/quicklink-open (url word)
  (interactive
   (let ((quicklink
          (alist-get (intern (completing-read
                              "Select quicklink: "
                              (mapcar
                               (lambda (s) (symbol-name (car s)))
                               sr/quicklink-alist)
                              nil t))
                     sr/quicklink-alist)))
     (list
      (plist-get quicklink :url)
      (or (sr/quicklink-word-dwim) (user-error "No word found at point")))))
  ;; Do not use EWW.
  (let ((browse-url-browser-function 'browse-url-default-browser))
    (browse-url (url-encode-url (format url word)))))

(keymap-global-set "C-c d d" #'sr/quicklink-open)

;;; _

(provide 'sr-web)

;;; sr-web.el ends here
