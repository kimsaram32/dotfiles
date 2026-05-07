;;; sr-completion.el --- Personal configuration for completion  -*- lexical-binding: t; -*-
;;; Commentary:
;; Personal library for completion.

;;; Code:

(require 'vertico)

;;; Vertico

(vertico-mode)
(vertico-multiform-mode)

(keymap-set vertico-map "M-n" #'vertico-next)
(keymap-set vertico-map "M-p" #'vertico-previous)
(keymap-set vertico-map "M-TAB" #'vertico-insert)
(keymap-set vertico-map "RET" #'vertico-exit-input)
(keymap-set vertico-map "M-RET" #'vertico-exit)

(keymap-set vertico-map "C-n" #'next-history-element)
(keymap-set vertico-map "C-p" #'previous-history-element)

;;; Marginalia

(marginalia-mode)

;;; Completion configuration

;; Non-exhaustive list of completion categories:
;; - eglot-capf: =eglot-completion-at-point=
;; - org-heading: [[*Jump to heading][Jump to heading]] and =consult-org-heading=
;; - info-menu

(setq completion-ignore-case t)
(setq completion-styles '(basic partial-completion emacs22 orderless))

;; Clear the defaults for complete control over my completions.
(setq completion-category-defaults nil)

(setq
 completion-category-overrides
 '((command (styles basic substring partial-completion initials orderless))
   (file (styles partial-completion orderless))
   (eglot-capf (styles basic initials substring orderless))
   (project-file (styles partial-completion substring orderless))
   (xref-location (styles substring))
   (info-menu (styles substring basic))
   (org-heading (styles orderless substring))
   (symbol (styles basic initials substring orderless))
   (kubedoc (styles partial-completion))))

;;; Testing completion styles

(defvar sr/--completion-testing nil)

(defun sr/completion-test-start (style)
  "Test a completion style STYLE.
  This makes `'completing-read' to only use STYLE as the completion
  style. call `sr/completion-test-end' when finished."
  (interactive (list (completing-read
                      "Completion style: "
                      (mapcar (lambda (x) (car x)) completion-styles-alist))))
  (when (not sr/--completion-testing)
    (setq sr/--completion-testing t)
    (setq sr/--completion-styles-prev completion-styles)
    (setq sr/--completion-category-overrides-prev completion-category-overrides)
    (setq sr/--completion-category-defaults-prev completion-category-defaults))
  (setq-default completion-styles (list (intern style)))
  (setq-default completion-category-overrides nil)
  (setq-default completion-category-defaults nil))

(defun sr/completion-test-end ()
  "Revert completion styles altered by `sr/completion-style-start'."
  (interactive)
  (when (not sr/--completion-testing)
    (user-error "Not testing"))
  (setq sr/--completion-testing nil)
  (setq-default completion-styles sr/--completion-styles-prev)
  (setq-default completion-category-overrides sr/--completion-category-overrides-prev)
  (setq-default completion-category-defaults sr/--completion-category-defaults-prev))

;;; Revealing current completion category

(defun sr/show-completion-category ()
  "Show category in current completion context."
  (interactive)
  (message "%S"
           (completion-metadata-get
            (completion-metadata
             (minibuffer-contents)
             minibuffer-completion-table
             minibuffer-completion-predicate)
            'category)))

(keymap-set minibuffer-local-map "C-c C-k" #'sr/show-completion-category)

;;; _

(provide 'sr-completion)

;;; sr-completion.el ends here
