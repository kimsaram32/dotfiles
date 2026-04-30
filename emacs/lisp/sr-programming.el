;;; sr-programming.el --- Personal configuration for programming  -*- lexical-binding: t; -*-

;; Copyright (C) Minjeong Kim

;; Author: Minjeong Kim <kimsaram32@fastmail.com>
;; URL: https://github.com/kimsaram32/dotfiles

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;; Code:

(defvar-keymap sr/prog-setup-mode-map
  :doc "Keymap for `sr/prog-setup-mode'.")

(define-minor-mode sr/prog-setup-mode
  "Minor mode for shared programming setups."
  :lighter "")

(add-hook 'prog-mode-hook #'sr/prog-setup-mode)
(add-hook 'html-ts-mode-hook #'sr/prog-setup-mode)
(add-hook 'yaml-ts-mode-hook #'sr/prog-setup-mode)

;;; Display line numbers mode

(add-hook 'sr/prog-setup-mode-hook #'display-line-numbers-mode)

(setq-default display-line-numbers-width 4)
(setq display-line-numbers-type 'relative)

;;; Electric pairs mode

(add-hook 'sr/prog-setup-mode-hook #'electric-pair-local-mode)

;;; Tabs

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;;; Eglot

(defun sr/eglot-rename (newname)
  "Modified `eglot-rename' - set the old name as a default value for minibuffer."
  (interactive
   (let ((tap (thing-at-point 'symbol t)))
     (list (read-from-minibuffer
            (format "Rename `%s' to: " (or tap "unknown symbol"))
            tap nil nil nil tap))))
  (eglot-server-capable-or-lose :renameProvider)
  (eglot--apply-workspace-edit
   (eglot--request (eglot--current-server-or-lose)
                   :textDocument/rename `(,@(eglot--TextDocumentPositionParams)
                                          :newName ,newname))
   this-command))

(keymap-set sr/prog-setup-mode-map "C-c g r" #'sr/eglot-rename)
(keymap-set sr/prog-setup-mode-map "C-c g a" #'eglot-code-actions)
(keymap-set sr/prog-setup-mode-map "C-c g f" #'eglot-code-action-quickfix)

(defvar sr/eglot-ensure-hooks
  '(js-ts-mode-hook
    typescript-ts-mode-hook
    tsx-ts-mode-hook
    html-ts-mode-hook
    c-ts-mode-hook)
  "Hooks to attach `eglot-ensure'.")

(dolist (hook sr/eglot-ensure-hooks)
  (add-hook hook #'eglot-ensure))

;; Fix shifting line height
;; https://www.reddit.com/r/emacs/comments/1lbo5jy/eldoc_undesirably_shifting_my_line_height/
(setq eglot-code-action-indications '(eldoc-hint))

;;; Eglot-booster

(require 'eglot-booster)

;; Disable bytecode mode for eglot-booster to preserve proper UTF-8 encoding
;; https://github.com/blahgeek/emacs-lsp-booster/issues/43
(setq eglot-booster-io-only t)

(eglot-booster-mode)

;;; Flymake

(with-eval-after-load 'flymake
  (keymap-set flymake-mode-map "M-n" 'flymake-goto-next-error)
  (keymap-set flymake-mode-map "M-p" 'flymake-goto-prev-error))

;;; Flymake-eslint

;; https://www.rahuljuliato.com/posts/eslint-on-emacs

(require 'flymake-eslint)

(setq flymake-eslint-prefer-json-diagnostics t)

(defun sr/flymake-eslint-enable-with-local-binary ()
  "Run `flymake-eslint-enable' but with local binary support.
Set project's `node_modules' binary eslint as first priority, if any."
  (interactive)
  (let* ((root (locate-dominating-file (buffer-file-name) "node_modules"))
         (local-eslint (and root
                            (expand-file-name "node_modules/.bin/eslint"
                                              root))))
    (if (and local-eslint (file-executable-p local-eslint))
        (progn
          (setq-local flymake-eslint-executable-name local-eslint)
          (message (format "Using local Eslint: %s" local-eslint)))
      (message "Local Eslint not found, using the global binary: %s" flymake-eslint-executable-name))
    (flymake-eslint-enable)))

(defvar sr/flymake-eslint-enabled-modes
  '(tsx-ts-mode typescript-ts-mode js-ts-mode))

(defun sr/flymake-eslint-enable-on-required-modes ()
	(when (memq major-mode sr/flymake-eslint-enabled-modes)
    (sr/flymake-eslint-enable-with-local-binary)))

;; (add-hook 'eglot-managed-mode-hook #'sr/flymake-eslint-enable-on-required-modes)

;;; Eldoc

(with-eval-after-load 'eldoc
  (setq eldoc-echo-area-use-multiline-p nil)
  (setq eldoc-idle-delay 0.5))

;;; Whitespace mode

(require 'whitespace)

(add-hook 'sr/prog-setup-mode-hook #'whitespace-mode)

(defvar sr/whitespace-style-basic
  '(face trailing newline indentation empty missing-newline-at-eof)
  "Value for `whitespace-style', highlighting essential stuff only.")

(defvar sr/whitespace-style-detailed
  '(face tabs spaces trailing lines space-before-tab newline indentation empty space-after-tab space-mark tab-mark newline-mark missing-newline-at-eof)
  "Value for `whitespace-style' with full details.")

(setq whitespace-style sr/whitespace-style-basic)

(setq-default sr/whitespace-use-detailed nil)

(defun sr/whitespace-toggle-details ()
  "Toggle detailed whitespace visualization."
  (interactive)
  (if (not whitespace-mode)
      (user-error "whitespace-mode not enabled")
    (setq-local sr/whitespace-use-detailed
                (not sr/whitespace-use-detailed))
    (setq-local whitespace-style
                (if sr/whitespace-use-detailed
                    sr/whitespace-style-detailed
                  sr/whitespace-style-basic))
                                        ; reload `whitespace-mode'.
    (whitespace-mode -1)
    (whitespace-mode 1)))

(keymap-set sr/prog-setup-mode-map "C-c C-w" #'sr/whitespace-toggle-details)

(setq whitespace-display-mappings
      '(
        (space-mark   ?\     [?·]     [?.])
        (space-mark   ?\xA0  [?¤]     [?_])
        (newline-mark ?\n    [?$ ?\n])
        (tab-mark     ?\t    [?» ?\t] [?\\ ?\t])
        ))

;;; Dumb-jump

(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

;;; Tree-sitter

(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash")
        (c "https://github.com/tree-sitter/tree-sitter-c")
        (cmake "https://github.com/uyha/tree-sitter-cmake")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (make "https://github.com/alemuller/tree-sitter-make")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml" "v0.5.0")))

(add-to-list
 'major-mode-remap-alist
 '(js-json-mode . json-ts-mode))
(add-to-list
 'major-mode-remap-alist
 '(javascript-mode . js-ts-mode))

(defvar sr/tree-sitter-remap-list
  '(c css js json python go typescript yaml)
  "List of tree-sitter remapped languages.
For each LANG, LANG-mode is remapped to LANG-ts-mode,
and LANG-ts-mode is used with org mode source codes.")

(setq major-mode-remap-alist
      (append
       (mapcar
        (lambda (x)
          (let ((pre (symbol-name x)))
            (cons
             (intern (concat pre "-mode"))
             (intern (concat pre "-ts-mode")))))
        sr/tree-sitter-remap-list)
       major-mode-remap-alist))

(setq org-src-lang-modes
      (append
       (mapcar
        (lambda (x)
          (let ((pre (symbol-name x)))
            (cons
             pre
             (intern (concat pre "-ts")))))
        sr/tree-sitter-remap-list)
       org-src-lang-modes))

;;; Format-all

(with-eval-after-load 'format-all
  (setq-default format-all-formatters
                '(("CSS" (prettier))
                  ("JavaScript" (prettier))
                  ("TypeScript" (prettier))
                  ("HTML" (prettier)))))

(keymap-set sr/prog-setup-mode-map "C-c C-f" #'format-all-region-or-buffer)
(keymap-set sr/prog-setup-mode-map "C-c f" #'format-all-region-or-buffer)

;;; Combobulate

(setq sr/combobulate-enable-hooks
      '(js-ts-mode-hook
        typescript-ts-mode-hook
        tsx-ts-mode-hook
        css-ts-mode-hook
        json-ts-mode-hook
        html-ts-mode-hook
        yaml-ts-mode-hook))

(dolist (hook sr/combobulate-enable-hooks)
  (add-hook hook #'combobulate-mode))

(defun sr/combobulate-display-tree-at-point ()
  "Render a navigation tree around the node at point."
  (interactive)
  (combobulate-display-draw-node-tree (combobulate-node-at-point)))

;;; Completion

(keymap-set sr/prog-setup-mode-map "M-TAB" #'completion-at-point)

;;; CSS

(with-eval-after-load 'css-mode
  (setq css-indent-offset 2)
  (add-hook 'css-ts-mode-hook #'rainbow-mode))

;;; C

(require 'c-ts-mode)

(setq c-ts-mode-indent-style 'bsd)
(setq c-ts-mode-indent-offset 2)

(defun sr/c-previous-defun-body ()
  "Go to body of the previous defun."
  (interactive)
  (if (c-defun-name)
      (c-beginning-of-defun))
  (c-beginning-of-defun)
  (c-syntactic-re-search-forward "{"))

(defun sr/c-next-defun-body ()
  "Go to body of the next defun."
  (interactive)
  (if (c-defun-name)
      (c-end-of-defun))
  (c-syntactic-re-search-forward "{"))

(keymap-set c-ts-mode-map "C-M-x" 'sr/c-next-defun-body)
(keymap-set c-ts-mode-map "C-M-y" 'sr/c-previous-defun-body)

;;; Go

(with-eval-after-load 'go-ts-mode
  (setq go-ts-mode-indent-offset 2)

  (keymap-set go-ts-mode-map "C-c C-f" #'gofmt))

;;; Dockerfile

(add-to-list 'auto-mode-alist
             '("Dockerfile\\'" . dockerfile-ts-mode))

;;; JavaScript

(with-eval-after-load 'js
  (setq js-indent-level 2))

;;; TypeScript

(defun sr/eglot-ts-handle-file-rename (server file new-name)
  "Send the TS LSP command to SERVER handling the rename of FILE to NEW-NAME."
  (eglot--request
   server
   :workspace/executeCommand
   (list
    :command "_typescript.applyRenameFile"
    :arguments `[(
                  :sourceUri ,(eglot-path-to-uri file)
                  :targetUri ,(eglot-path-to-uri new-name))])))

(defun sr/eglot-ts-rename (new-name)
  "Rename the visited file of the current TypeScript buffer to a new name."
  (interactive (list (read-file-name "Set visited file name: "
                                     default-directory
                                     (expand-file-name
                                      (file-name-nondirectory (buffer-name))
                                      default-directory))))
  (when-let* ((server (eglot--current-server-or-lose))
              (old-file-name (buffer-file-name)))
    (sr/eglot-ts-handle-file-rename server old-file-name new-name)
    (rename-visited-file new-name)))

;; Work in progress

(defun sr/eglot-ts-server-p (server)
  "Return t if SERVER can manage TS buffers."
  (prin1 (eglot--language-ids server)))

;; FIXME: Refactor w/ project-wise cache
(defun sr/eglot-ts-server-for-file (file)
  "Return the current Eglot TS server for FILE, if one exists."
  (if-let* ((project (project-current nil (file-name-directory file)))
            (servers (gethash project eglot--servers-by-project)))
      (-first #'sr/eglot-ts-server-p servers)))

(defun sr/eglot-ts-handle-dired-rename (file new-name ok-if-already-exists)
  (if-let* ((server (sr/eglot-ts-server-for-file file)))
      (sr/eglot-ts-handle-file-rename server file new-name)))

;; (advice-add 'dired-rename-file :after #'sr/eglot-ts-handle-dired-rename)

(defun sr/tsc ()
  "Run `tsc' with `compile.'"
  (interactive)
  (compile "tsc --noEmit --pretty false"))

;;; HTML

(require 'html-ts-mode)

(add-to-list 'major-mode-remap-alist '(mhtml-mode . html-ts-mode))

(unbind-key "C-c C-f" sgml-mode-map)

;;;; Emmet

(require 'emmet-mode)
(add-hook 'html-ts-mode-hook #'emmet-mode)
(keymap-unset emmet-mode-keymap "C-j")
(keymap-set emmet-mode-keymap "C-c C-j" #'emmet-expand-line)

;;; Markdown

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)

(add-to-list
 'auto-mode-alist
 '("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
  "Major mode for editing GitHub Flavored Markdown files" t)

(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

(with-eval-after-load 'markdown-mode
  (setq
   markdown-css-paths
   (list (expand-file-name "~/me/ws/projects/github-markdown-css/github-markdown.css")))

  (setq
   markdown-xhtml-body-preamble
   "<main class=\"markdown-body\">")

  (setq
   markdown-xhtml-body-epilogue
   "</main>"))

;;; Python

(with-eval-after-load 'python
  (setq python-indent-offset 2))

;;; PlantUML

(setq image-use-external-converter t)

(add-to-list
 'org-src-lang-modes '("plantuml" . plantuml))

(add-hook 'plantuml-mode-hook #'abbrev-mode)

(with-eval-after-load 'plantuml-mode
  (setq plantuml-default-exec-mode 'executable)
  (setq plantuml-executable-path "/opt/homebrew/bin/plantuml")
  (setq plantuml-svg-background "#ffffff")
  (setq plantuml-output-type "svg")

  (setq plantuml-indent-level 2)

  (sr/define-abbrev-table
   'plantuml-mode-abbrev-table
   '(("oto" "||--||")
     ("mto" "}o--||")
     ("otm" "||--o{")
     ("mtm" "}o--o{")
     ("pk" "<<PK>>")
     ("fk" "<<FK>>")
     ("uq" "<<UNIQUE>>"))))

;;; Restclient

(require 'restclient)
(require 'ob-restclient)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((restclient . t)))

;;; YAML

(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-ts-mode))

;;; _
(provide 'sr-programming)
;;; sr-programming.el ends here
