;;; sr-others.el --- Random configurations  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Tools

(defvar-keymap sr/external-tools-map
  :doc "Keymap for various tools.")

(keymap-global-set "C-c e" sr/external-tools-map)

;; evil-mode
(keymap-set sr/external-tools-map "e" #'evil-mode)

;; docker
(keymap-set sr/external-tools-map "d" #'docker)

;; kele

;; kele-mode is not enabled by default, because the cluster might be
;; unreachable at startup. When this is the case, Kele still tries to connect,
;; causing Emacs to freeze on launch.

(require 'kele)
(keymap-set kele-mode-map "C-c k" kele-command-map)

;;; LLMs

(with-eval-after-load 'agent-shell
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))

  (setq agent-shell-openai-authentication
        (agent-shell-openai-make-authentication :login t))

  (add-hook 'agent-shell-mode-hook #'corfu-mode))

;;; English learning

;; I tried using EWW to browse words inside Emacs, but the site feels broken
;; when rendered in pure HTML. EWW overrides `browse-url-browser-function' to
;; `eww-browse-url', so to avoid using EWW, I overrode it.

(defcustom sr/eng-dictionary-url
  "https://www.merriam-webster.com/dictionary/%s"
  "Format string for English dictionary.")

(defun sr/eng-browse-dictionary-at-point ()
  "Look up dictionary for a word at point."
  (interactive)
  (if-let* ((word (word-at-point t))
            (browse-url-browser-function 'browse-url-default-browser)) ; do not use EWW
      (browse-url (url-encode-url (format sr/eng-dictionary-url word)))
    (user-error "No word found at point")))

(keymap-global-set "C-c d d" #'sr/eng-browse-dictionary-at-point)

;;; Avy

;; (keymap-global-set "C-M-'" #'avy-goto-char-timer)
;; (keymap-global-set "M-g t" #'avy-goto-char-2)
;; (keymap-global-set "M-g b" #'avy-goto-char)

(with-eval-after-load 'avy
  (setq avy-timeout-seconds 0.3)
  ;; I use Colemak layout, so the keys are adjusted accordingly.
  ;; The default is '(?a ?s ?d ?f ?g ?h ?j ?k ?l).
  (setq avy-keys '(?a ?r ?s ?t ?d ?n ?e ?i ?o ?h)))

;;; Spray

(keymap-global-set "<f6>" #'spray-mode)

;;; SRS

(defconst sr/note-flashcards-directory
  (expand-file-name "flashcards/" sr/note-root-directory)
  "Directory for flashcards.")

(with-eval-after-load 'srs
  (add-to-list 'srs-path-list (expand-file-name "*.txt" sr/note-flashcards-directory)))

(defvar-keymap sr/srs-map)

(keymap-global-set "C-c s" sr/srs-map)

(keymap-set sr/srs-map "s" #'srs-menu)
(keymap-set sr/srs-map "c" #'srs-card-make-at-point)
(keymap-set sr/srs-map "r" #'srs-review)

;;; _
(provide 'sr-others)
;;; sr-others.el ends here
