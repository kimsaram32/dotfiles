;; -*- lexical-binding: t -*-

;; Note that under this configuration, `prepare-user-lisp' doesn't consider
;; modules under configs/. This is desired as the modules shouldn't be
;; byte-compiled.
(setq user-lisp-directory (locate-user-emacs-file "libraries/"))
