;;; sr-tts.el --- Personal library for TTS (Text-To-Speech)  -*- lexical-binding: t; -*-

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
;;
;; Heavily inspired by TTS by Diogo Doreto (<https://github.com/DiogoDoreto/emacs-tts>).

;;; Code:

;;; Customization

(defgroup sr/tts nil
  "Text-To-Speech."
  :group 'application)

(defcustom sr/tts-kokoro-options
  '(:port 8880
          :voice "af_aoede"
          :lang-code "a")
  "Plist of options for using Kokoro.

- `:port' is the port to the Kokoro-FastAPI server.

- `:voice' and `:lang-code' is the voice name and language code for
  Kokoro, respectively."
  :type 'plist)

(defcustom sr/tts-output-directory
  (locate-user-emacs-file "tts")
  "Directory to store generated TTS audio files."
  :type 'directory)

;;; TTS


(defun sr/tts-preprocess-text (text)
  (with-temp-buffer
    (insert text)
    (goto-char (point-min))
    (while (re-search-forward "/\\([^/]+\\)/" nil t)
      (replace-match "\\1"))
    (buffer-string)))

(defun sr/tts--get-output-file (text)
  (expand-file-name
   (concat
    (secure-hash 'sha1 (prin1-to-string (list sr/tts-kokoro-options text)))
    ".mp3")
   sr/tts-output-directory))

(defun sr/tts--generate-audio (text output-file callback)
  "Generate audio for TEXT to OUTPUT-FILE.

CALLBACK is called with no arguments on successful conversion."
  (let* ((url (format "http://localhost:%d/v1/audio/speech"
                      (plist-get sr/tts-kokoro-options :port)))

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
             (voice . ,(plist-get sr/tts-kokoro-options :voice))
             (lang_code . ,(plist-get sr/tts-kokoro-options :lang-code))
             (response_format . ,(file-name-extension output-file))
             (speed . 1)))
           'us-ascii))

         (url-callback
          (lambda (status)
            (if (plist-member status :error)
                (progn
                  (if-let ((err (plist-get status :error)))
                      (signal (car err) (cdr err))
                    (error "TTS failed with unknown error")))
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
                  (error "Unexpected HTTP status code %s" http-status))))))))
    (url-retrieve url url-callback)
    (message "Generating audio...")))

(defun sr/tts--play-audio (file)
  (message "Playing audio...")
  (if (executable-find "ffplay")
      (start-process "*ffplay*" nil "ffplay" "-nodisp" "-autoexit" file)
    (user-error "ffplay executable not found")))

;;;###autoload
(defun sr/tts-read-text (text &optional no-cache)
  "Read the English text TEXT aloud.
The generated audio file is saved in `sr/tts-output-directory',
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
  (if-let* ((preprocessed-text (sr/tts--preprocess-text text))
            (output-file (sr/tts--get-output-file preprocessed-text)))
      (if (and (not no-cache)
               (file-regular-p output-file))
          (sr/tts--play-audio output-file)
        (if (not (file-directory-p sr/tts-output-directory))
            (make-directory sr/tts-output-directory))
        (sr/tts--generate-audio
         preprocessed-text
         output-file
         (lambda ()
           (sr/tts--play-audio output-file))))))

;;; _

(provide 'sr-tts)

;;; sr-tts.el ends here
