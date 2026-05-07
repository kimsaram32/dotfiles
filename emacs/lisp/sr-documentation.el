;;; sr-documentation.el --- Personal configuration for reading documentation  -*- lexical-binding: t; -*-
;;; Commentary:
;; Personal library for reading documentation.

;;; Code:

(require 'help)

;;; elisp-demos

(advice-add 'describe-function-1 :after #'elisp-demos-advice-describe-function-1)
(advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update)

;;; apropos key bindings

(unbind-key "a" help-map)

(keymap-set help-map "a a" 'apropos-command)
(keymap-set help-map "a f" 'apropos-function)
(keymap-set help-map "a v" 'apropos-variable)
(keymap-set help-map "a u" 'apropos-user-option)
(keymap-set help-map "a l" 'apropos-library)

;;; helpful

(require 'helpful)

(keymap-set help-map "f" #'helpful-function)
(keymap-set help-map "v" #'helpful-variable)
(keymap-set help-map "k" #'helpful-key)
(keymap-set help-map "x" #'helpful-command)
(keymap-set help-map "o" #'helpful-symbol)

;;; man

(with-eval-after-load 'man
  ;; disable autocompletion by overriding the completion table function that the
  ;; `man' command uses. It's slow for me, and I don't need this feature.
  (defun Man-completion-table (str pred flag)
	  '()))

;;; _

(provide 'sr-documentation)

;;; sr-documentation.el ends here
