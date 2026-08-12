;; -*- lexical-binding: t -*-

;;; Packages

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file)

;;; Shared files and directories

(defconst sr/dotfiles-directory (expand-file-name "~/me/dotfiles/")
  "Root directory for dotfiles.")

(defconst sr/emacs-load-directory
  (file-name-concat sr/dotfiles-directory "emacs/lisp/")
  "Directory for personal lisp libraries.")

(defconst sr/note-root-directory (expand-file-name "~/me/myself/")
  "Root directory for notes.")

(defconst sr/note-periodic-directory
  (expand-file-name "life/" sr/note-root-directory)
  "Directory for periodic notes.")

(defconst sr/note-project-directory
  (expand-file-name "projects/" sr/note-root-directory)
  "Directory for project notes.")

(defconst sr/note-second-brain-directory
  (expand-file-name "second-brain/" sr/note-root-directory)
  "Directory for second bran.")

(defconst sr/note-zk-directory
  (expand-file-name "zettelkasten/" sr/note-root-directory)
  "Directory for Zettelkasten.")

(defconst sr/note-media-directory
  (expand-file-name "media/" sr/note-root-directory)
  "Directory for media (e.g. images)")

(defconst sr/dev-project-directory
  (expand-file-name "~/me/ws/projects/")
  "Directory for software projects")

;;; Workflow

(defconst sr/note-day-start-hour 3
  "The starting hour of a day for notes.")

(add-to-list 'load-path sr/emacs-load-directory)

;;; Load modules

;; From Prot's dotfiles
(defmacro sr/load-configuration (name &rest body)
  "Evaluate BODY and catch any errors."
  (declare (indent 0))
  `(condition-case err
       (progn ,@body)
     ((error user-error quit)
      (message "Failed to load configuration '%s': `%S'" ,name (cdr err)))))

(require 'sr-environment)

;; This is a private module.
(sr/load-configuration
  "Startup"
  (require 'sr-startup))

(sr/load-configuration
  "Emacs"
  (require 'sr-emacs))

(sr/load-configuration
  "Org"
  (require 'sr-org))

(sr/load-configuration
  "Completion"
  (require 'sr-completion))

(sr/load-configuration
  "Windows"
  (require 'sr-windows))

(sr/load-configuration
  "Workflow"
  (require 'sr-workflow))

(sr/load-configuration
  "Email"
  (require 'sr-email))

(sr/load-configuration
  "Programming"
  (require 'sr-programming))

(sr/load-configuration
  "Web"
  (require 'sr-web))

(sr/load-configuration
  "Documentation"
  (require 'sr-documentation))

(sr/load-configuration
  "Denote"
  (require 'sr-denote))

(sr/load-configuration
  "Latex"
  (require 'sr-latex))

(sr/load-configuration
  "Others"
  (require 'sr-others))

;;; Enable disabled commands

(put 'scroll-left 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
