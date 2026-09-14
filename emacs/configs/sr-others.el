;;; sr-others.el --- Random configurations  -*- lexical-binding: t; -*-

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

;;; Authentication

(setq auth-sources '("~/.authinfo.gpg"))
(setq epg-pinentry-mode 'loopback)

;;; Project

(defun sr/project-other-find-file (dir)
  "Prompt for a project, and run `project-find-file' in that project."
  (interactive (list (funcall project-prompter)))
  (let ((project-current-directory-override dir))
        (call-interactively #'project-find-file)))

(with-eval-after-load 'project
  (setq project-vc-include-untracked t)
  (setq project-mode-line t)
  (setq project-vc-extra-root-markers
        '(".Projectile"))

  (keymap-set project-prefix-map "F" #'sr/project-other-find-file))

;;; Dired

(with-eval-after-load 'dired
  (setq dired-listing-switches "-halX --group-directories-first")
  (setq dired-auto-revert-buffer t)
  (setq dired-vc-rename-file t)
  (setq dired-movement-style 'cycle)

  (setq delete-by-moving-to-trash t)

  (add-hook 'dired-mode-hook 'dired-omit-mode)
  (add-hook 'dired-mode-hook 'lin-mode))

(defun sr/dired-open-in-finder ()
  "Open the current Dired directory in macOS Finder."
  (interactive)
  (when (not (eq major-mode 'dired-mode))
    (user-error "Not in a Dired buffer"))
  (dired-smart-shell-command "open ."))

;;; Tools

(defvar-keymap sr/external-tools-map
  :doc "Keymap for various tools.")

(keymap-global-set "C-c e" sr/external-tools-map)

;; Lin mode

(keymap-set sr/external-tools-map "l" #'lin-mode)

;; Evil
(keymap-set sr/external-tools-map "e" #'evil-mode)

;; Docker
(keymap-set sr/external-tools-map "d" #'docker)

;; Kele

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

;;; Spacious padding

(with-eval-after-load 'spacious-padding
  (setq spacious-padding-widths
        '( :internal-border-width 4
           :header-line-width 4
           :mode-line-width 6
           :custom-button-width 3
           :tab-width 2
           :right-divider-width 4
           :scroll-bar-width 8
           :fringe-width 12)))

(spacious-padding-mode 1)

;;; Version control

(defvar sr/clone-project-repo-url-history nil
  "Minibuffer history for `sr/clone-project-repo'.")

(defun sr/clone-project-repo ()
  "Prompt for a repository url and clone it inside `sr/dev-project-directory'."
  (interactive)
  (let* ((url (read-string "URL to repo: " nil
                           sr/clone-project-repo-url-history))
         (directory-name
          (expand-file-name
           (read-directory-name "Directory name: " sr/dev-project-directory
                                nil (lambda (file-name) (not (file-exists-p file-name))))
           sr/dev-project-directory)))
    (make-directory directory-name t)
    (dired directory-name)
    (magit-clone-regular
     url
     directory-name
     nil)))

;;;; Forge

(defun sr/forge-copy-browse-url-as-link ()
  (interactive)
  (when-let* ((target (forge--browse-target))
            (url (if (stringp target) target (forge-get-url target))))
    (kill-new (format "[[%s]]" url))
    (message url)))

(with-eval-after-load 'magit
  (keymap-set magit-mode-map "C-c C-l" #'sr/forge-copy-browse-url-as-link))

;;; Vterm

;; Requires vterm and vterm-toggle

(with-eval-after-load 'vterm
  (keymap-set vterm-mode-map "C-M-;" #'vterm-copy-mode)
  (keymap-set vterm-copy-mode-map "C-M-;" #'vterm-copy-mode)

  (keymap-set vterm-mode-map "C-c C-l" #'vterm-clear)

  (keymap-set vterm-mode-map "C-c C-n" #'vterm-toggle-forward)
  (keymap-set vterm-mode-map "C-c C-p" #'vterm-toggle-backward)

  (keymap-unset vterm-mode-map "M-/"))

(defun sr/vterm-switch (arg)
  (require 'vterm)
  (vterm--internal
   #'switch-to-buffer
   (cond ((stringp arg) arg)
         (arg (concat "*vterm " (read-string "Session name: ") "*"))
         (t nil))))

(defvar sr/vterm-switch-function #'sr/vterm-switch
  "Function for switching to a vterm buffer.
It should accept the same arguments as `vterm'.")

(defun sr/vterm-switch-and-cd (arg)
  "Switch to a vterm buffer and cd to current directory.
ARG has the same meaning as `vterm'."
  (interactive "P")
  (let* ((directory (expand-file-name default-directory))
         (command (concat
                   "cd "
                   (shell-quote-argument directory))))
    (with-current-buffer (funcall sr/vterm-switch-function arg)
      (vterm-send-string "\C-u") ; clear the current line
      (vterm-send-string command)
      (vterm-send-string "\C-m") ; CR
      (cd directory))))

(keymap-global-set "C-c e t" #'sr/vterm-switch-and-cd)

;;; TTS

(with-eval-after-load 'sr-tts
  (setq sr/tts-kokoro-options
        '(:port 8880
                :voice "am_michael"
                :lang-code "a")))

(keymap-global-set "C-c d t" #'sr/tts-read-text)

;;; Scratch

(with-eval-after-load 'sr-scratch
  (setq sr/scratch-file-alist
        '((emacs-lisp-mode . "test.el")
          (org-mode . "test.org")
          (text-mode . "test.txt")))

  (setq sr/scratch-default-major-mode 'emacs-lisp-mode))

(keymap-global-set "C-<f12>" #'sr/scratch-open)
(keymap-global-set "<f12>" #'sr/scratch-open-default)

;;; _

(provide 'sr-others)

;;; sr-others.el ends here
