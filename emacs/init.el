;; -*- lexical-binding: t -*-

;;; Packages

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file)

;;; Shared files and directories

(defgroup sr/emacs nil
  "Personal Emacs configuration."
  :group 'files)

(defcustom sr/dotfiles-directory (expand-file-name "~/me/dotfiles/")
  "Root directory for dotfiles."
  :type 'directory)

(defcustom sr/emacs-load-directory
  (file-name-concat sr/dotfiles-directory "emacs/lisp/")
  "Directory for personal lisp libraries."
  :type 'directory)

(defcustom sr/note-root-directory (expand-file-name "~/me/myself/")
  "Root directory for notes."
  :type 'directory)

(defcustom sr/note-periodic-directory
  (expand-file-name "life2/" sr/note-root-directory)
  "Directory for periodic notes."
  :type 'directory
  :set-after '(sr/note-root-directory))

(defcustom sr/note-periodic-directory-old
  (expand-file-name "life/" sr/note-root-directory)
  "Directory for older periodic notes."
  :type 'directory
  :set-after '(sr/note-root-directory))

(defcustom sr/note-project-directory
  (expand-file-name "projects/" sr/note-root-directory)
  "Directory for project notes."
  :type 'directory
  :set-after '(sr/note-root-directory))

(defcustom sr/note-second-brain-directory
  (expand-file-name "second-brain/" sr/note-root-directory)
  "Directory for second brain."
  :type 'directory
  :set-after '(sr/note-root-directory))

(defcustom sr/note-zk-directory
  (expand-file-name "zettelkasten/" sr/note-root-directory)
  "Directory for Zettelkasten."
  :type 'directory
  :set-after '(sr/note-root-directory))

(defcustom sr/note-media-directory
  (expand-file-name "media/" sr/note-root-directory)
  "Directory for media (e.g. images)."
  :type 'directory
  :set-after '(sr/note-root-directory))

(defcustom sr/note-flashcards-directory
  (expand-file-name "flashcards/" sr/note-root-directory)
  "Directory for flashcards."
  :type 'directory
  :set-after '(sr/note-root-directory))

(defcustom sr/dev-project-directory
  (expand-file-name "~/me/ws/projects/")
  "Directory for software projects."
  :type 'directory)

;;; Workflow

(defcustom sr/note-day-start-hour 3
  "The starting hour of a day for notes."
  :type 'natnum)

;;; Load path

(add-to-list 'load-path sr/emacs-load-directory)

;;; Autoloads

(unless (require 'sr-autoloads nil t)
  (message
   "Autoload file must be generated in %s; some features might not work"
   (expand-file-name "sr-autoloads.el" sr/emacs-load-directory)))

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
  "Projects"
  (require 'sr-projects))

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
  "English"
  (require 'sr-english))

(sr/load-configuration
  "Periodic"
  (require 'sr-periodic))

(sr/load-configuration
  "Others"
  (require 'sr-others))

;;; Enable disabled commands

(put 'scroll-left 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
