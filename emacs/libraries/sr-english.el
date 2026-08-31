;;; sr-english.el --- Personal library for English learning  -*- lexical-binding: t; -*-

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

;;; Customization

(defgroup sr/english nil
  "Personal English learning."
  :group 'application)

(defcustom sr/english-dictionary-url
  "https://www.merriam-webster.com/dictionary/%s"
  "Format string for opening English dictionary."
  :type 'string)

(defcustom sr/english-capture-file
  "~/english.org"
  "Location to the file storing captured English sentences."
  :type 'file)

;; TODO better customizations

(defcustom sr/english-tts-kokoro-options
  '(:port 8880
          :voice "af_aoede"
          :lang-code "a")
  "Plist of options for using Kokoro.

- `:port' is the port to the Kokoro-FastAPI server.

- `:voice' and `:lang-code' is the voice name and language code for
  Kokoro, respectively."
  :type 'plist)

(defcustom sr/english-tts-output-directory
  (locate-user-emacs-file "english-tts")
  "Directory to store generated TTS audio files."
  :type 'directory)

;;; Dictionary

;; I tried using EWW to browse words inside Emacs, but the site feels broken
;; when rendered in pure HTML. EWW overrides `browse-url-browser-function' to
;; `eww-browse-url', so to avoid using EWW, I overrode it.

;;;###autoload
(defun sr/english-browse-dictionary-at-point ()
  "Look up dictionary for a word at point."
  (interactive)
  (if-let* ((word (if (region-active-p)
                      (buffer-substring (region-beginning) (region-end))
                    (word-at-point t)))
            (browse-url-browser-function 'browse-url-default-browser)) ; do not use EWW
      (browse-url (url-encode-url (format sr/english-dictionary-url word)))
    (user-error "No word found at point")))

;;; Sentence capture

;; TODO: Maybe merge with `'sr/denote-get-initial-data-dwim'?
(defun sr/english-get-buffer-page-data ()
  "Get the page data the current buffer is visiting.
A page data is a plist consisting of two properties: URL and TITLE.
TITLE can be nil.

When there is no appropriate page data, return nil."
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

(defvar sr/english-page-url-history nil
  "Minibuffer history for URL in `sr/english-page-prompt'.")

(defvar sr/english-page-title-history nil
  "Minibuffer history for title in `sr/english-page-prompt'.")

(defun sr/english-page-prompt ()
  "Prompt for page data."
  (let ((url (read-string
              "Enter page URL (empty input for no page): "
              nil sr/english-page-url-history)))
    (if (string-empty-p url)
        nil
      (list
       :url url
       :title (let ((title (read-string
                            "Enter page title: "
                            nil sr/english-page-title-history)))
                (if (string-empty-p title) nil title))))))

;;;###autoload
(defun sr/english-capture (content page)
  "Add a new entry in the capture file.
Navigate to the buffer visiting the file, and place the point to the
beginning of the text.

CONTENT is the English text to capture, and PAGE is either nil or a page
data."
  (interactive
   (list (if (use-region-p)
             (buffer-substring (region-beginning) (region-end))
           (read-string-from-buffer "Content: " ""))
         (or
          (sr/english-get-buffer-page-data)
          (sr/english-page-prompt))))
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
    (when (not (org-at-heading-p))
      (outline-next-heading))
    (setq start-pos (point))
    (save-excursion
      (insert (format "* _\n\n%s" content))
      (fill-region start-pos (point))
      (when page
        (insert (format "\n\n%s" link)))
      (insert "\n\n"))))

;;; Capture buffer

(defun sr/english--capture-org-timestamp-string-to-time (string)
  "Convert org timestamp string to time values.
STRING can be nil, and in this case nil is returned."
  (and string (org-timestamp-to-time (org-timestamp-from-string string))))

(defun sr/english--capture-hide-entry ()
  (let ((overlay (make-overlay
                  (org-entry-beginning-position)
                  (org-entry-end-position))))
    (overlay-put overlay 'invisible 'english-capture)
    ;; Take precedence over other overlays setting the `invisible' property.
    (overlay-put overlay 'priority 99)))

(defun sr/english--capture-show-entry ()
  (remove-overlays
   (org-entry-beginning-position)
   (org-entry-end-position)
   'invisible 'english-capture))

(defun sr/english--capture-is-entry-due ()
  "Return t if entry at point is due today."
  (if-let* ((time (sr/english--capture-org-timestamp-string-to-time
                   (org-entry-get (point) "NEXT_REVIEW"))))
      (or (time-less-p time (current-time))
          (time-equal-p time (current-time)))
    t))

(defvar-local sr/english--capture-non-due-hidden nil)

;;;###autoload
(defun sr/english-capture-hide-non-due ()
  "Hide non-due entries."
  (interactive)
  (setq sr/english--capture-non-due-hidden t)
  (org-scan-tags
   #'sr/english--capture-hide-entry
   (lambda (todo tags level) (not (sr/english--capture-is-entry-due)))
   nil))

;;;###autoload
(defun sr/english-capture-show-non-due ()
  "Show non-due entries."
  (interactive)
  (setq sr/english--capture-non-due-hidden nil)
  (remove-overlays (point-min) (point-max) 'invisible 'english-capture))

;;;###autoload
(defun sr/english-capture-toggle-non-due-visibility ()
  "Toggle whether non-due entries are visible."
  (interactive)
  (if sr/english--capture-non-due-hidden
      (sr/english-capture-show-non-due)
    (sr/english-capture-hide-non-due)))

(defun sr/english--capture-next-review-date-prompt (entry-epom)
  (let* ((next-review (sr/english--capture-org-timestamp-string-to-time
                       (org-entry-get entry-epom "NEXT_REVIEW")))
         (last-review (sr/english--capture-org-timestamp-string-to-time
                       (org-entry-get entry-epom "LAST_REVIEW")))
         (prompt
          (concat
           "Next review date"
           (if (and next-review last-review)
               (format
                " (last interval was %d)"
                (- (time-to-days next-review) (time-to-days last-review)))
             " (new entry)")
           ": ")))
    (date-to-time (org-read-date nil nil nil prompt))))

;;;###autoload
(defun sr/english-capture-finish-review-at-point (next-review)
  "Update review properties for entry at point.
NEXT-REVIEW must be a time value."
  (interactive
   (list (sr/english--capture-next-review-date-prompt (point))))
  (org-entry-put (point) "NEXT_REVIEW"
                 (format-time-string (org-time-stamp-format) next-review))
  (org-entry-put (point) "LAST_REVIEW"
                 (format-time-string (org-time-stamp-format) (current-time)))
  (if sr/english--capture-non-due-hidden
      (sr/english--capture-hide-entry)))

(defvar-keymap sr/english-capture-mode-map
  "C-c C-." #'sr/english-capture-toggle-non-due-visibility
  "C-c d r" #'sr/english-capture-finish-review-at-point)

;;;###autoload
(define-minor-mode sr/english-capture-mode
  "Minor mode for the English capture buffer."
  :global nil
  :lighter " Eng"
  (if sr/english-capture-mode
      (progn
        (add-to-invisibility-spec 'english-capture))
    (sr/english-capture-show-non-due)
    (remove-from-invisibility-spec 'english-capture)))

;;; TTS

(defun sr/english--tts-preprocess-text (text)
  (with-temp-buffer
    (insert text)
    (goto-char (point-min))
    (while (re-search-forward "/\\([^/]+\\)/" nil t)
      (replace-match "\\1"))
    (buffer-string)))

(defun sr/english--tts-get-output-file (text)
  (expand-file-name
   (concat
    (secure-hash 'sha1 (prin1-to-string (list sr/english-tts-kokoro-options text)))
    ".mp3")
   sr/english-tts-output-directory))

(defun sr/english--tts-generate-audio (text output-file callback)
  (let* ((url (format "http://localhost:%d/v1/audio/speech"
                      (plist-get sr/english-tts-kokoro-options :port)))

         (url-automatic-caching t)
         (url-request-method "POST")
         (url-request-extra-headers
          '(("Content-Type" . "application/json")))
         (url-request-data
          ;; Encode multibyte string to unibyte.
          (encode-coding-string
           (json-encode
           `((model . "kokoro")
             (input . ,text)
             (voice . ,(plist-get sr/english-tts-kokoro-options :voice))
             (lang_code . ,(plist-get sr/english-tts-kokoro-options :lang-code))
             (response_format . ,(file-name-extension output-file))
             (speed . 1)))
           'us-ascii))

         (url-callback
          (lambda (status)
            (let ((http-status
                   (prog1
                       (url-http-parse-response)
                     (goto-char url-http-end-of-headers))))
              (cond
               ((= http-status 200)
                (write-region (1+ (point)) (point-max) output-file)
                (funcall callback))
               ((= http-status 422)
                (error "Bad request format: %s"
                       (alist-get 'msg (elt (alist-get 'detail (json-read)) 0))))
               (t
                (error "Unexpected HTTP status code %s" http-status)))))))
    (url-retrieve url url-callback)))

(defun sr/english--tts-play-audio (file)
  (if (executable-find "ffplay")
      (start-process "*ffplay*" nil "ffplay" "-nodisp" "-autoexit" file)
    (user-error "ffplay executable not found")))

(defun sr/english-tts-read-text (text &optional no-cache)
  "Read the English text TEXT aloud.
The generated audio file is saved in `sr/english-tts-output-directory',
and is used later in caching.

When optional argument NO-CACHE is non-nil, do not reuse the cached
output.

Interactively, TEXT is either the region's content or the paragraph at
point, depending on whether the region is active. NO-CACHE is set when
the prefix argument is present."
  (interactive (list (if (use-region-p)
                         (buffer-substring (region-beginning) (region-end))
                       (thing-at-point 'paragraph t))
                     (and current-prefix-arg)))
  (if-let* ((preprocessed-text (sr/english--tts-preprocess-text text))
            (output-file (sr/english--tts-get-output-file preprocessed-text)))
      (if (and (not no-cache)
               (file-regular-p output-file))
          (sr/english--tts-play-audio output-file)
        (if (not (file-directory-p sr/english-tts-output-directory))
            (make-directory sr/english-tts-output-directory))
        (sr/english--tts-generate-audio
         preprocessed-text
         output-file
         (lambda ()
           (sr/english--tts-play-audio output-file))))))

;;; _

(provide 'sr-english)

;;; sr-english.el ends here
