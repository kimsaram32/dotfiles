;;; sr-completion.el --- Personal configuration for completion  -*- lexical-binding: t; -*-
;;; Commentary:
;; Personal library for completion.

;;; Code:

(require 'vertico)

;;; Completion configuration

;; Non-exhaustive list of completion categories:
;; - eglot-capf: `eglot-completion-at-point'
;; - org-heading: Jump to heading and `consult-org-heading'
;; - info-menu

(setq completion-ignore-case t)
(setq completion-styles '(basic partial-completion emacs22 orderless))
(setq completions-format 'one-column)

;; Clear the defaults for complete control over my completions.
(setq completion-category-defaults nil)

(setq completion-category-overrides
      '((command (styles basic substring partial-completion initials orderless))
        (file (styles partial-completion orderless))
        (project-file (styles partial-completion orderless))
        (denote-file (styles orderless))
        (eglot-capf (styles basic initials substring orderless))
        (xref-location (styles substring))
        (info-menu (styles substring basic))
        (org-heading (styles orderless substring))
        (symbol (styles basic substring orderless))
        (kubedoc (styles partial-completion))))

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

;;; Corfu

;; Enable on these modes
(add-hook 'sr/prog-setup-mode-hook #'corfu-mode)
(add-hook 'minibuffer-setup-hook #'corfu-mode)
(add-hook 'eshell-mode-hook #'corfu-mode)
(add-hook 'agent-shell-mode-hook #'corfu-mode)

(with-eval-after-load 'corfu
  (keymap-set corfu-map "M-TAB" #'corfu-insert)
  ;; Do not complete on RET.
  (keymap-unset corfu-map "RET")

  (setq corfu-cycle t)
  (setq corfu-preview-current nil)

  ;; Popupinfo mode
  (corfu-popupinfo-mode)
  (setq corfu-popupinfo-direction '(right left vertical))
  (setq corfu-popupinfo-delay '(nil . 0))
  (setq corfu-popupinfo-max-height 20)

  ;; Autocompletions
  (setq corfu-auto t)
  (setq corfu-auto-delay 0.1)

  ;; (setq corfu-auto-trigger ".-/")
  ;; Complete on camelCase.
  (setq corfu-auto-trigger
        (concat ".-/" (apply #'string (number-sequence ?A ?Z)))))

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
