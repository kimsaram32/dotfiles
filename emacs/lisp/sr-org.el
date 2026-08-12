;;; sr-org.el --- Personal configuration for Org  -*- lexical-binding: t; -*-

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

(setq org-use-extra-keys t) ;; this should be enabled before loading org

;;; Global key bindings

(keymap-global-set "C-c l" #'org-store-link)
(keymap-global-set "C-c a" #'org-agenda)
(keymap-global-set "C-c c" #'org-capture)

;;; General

(with-eval-after-load 'org
  (setq org-directory sr/note-root-directory)
  (setq org-archive-location (expand-file-name
                              "archives/%s.archive::"
                              sr/note-root-directory))

  (add-to-list 'org-file-apps '("\\.md\\'" . emacs))

  (setq org-extend-today-until sr/note-day-start-hour))

;;; Editing

;;;; Configuration

(with-eval-after-load 'org
  (setq org-startup-indented t)
  (setq org-startup-with-inline-images t)
  (setq-default org-startup-folded 'showeverything)

  (setq org-emphasis-alist
        '(("*" bold) ("/" italic) ("_" underline) ("=" org-verbatim verbatim)
          ("~" org-code verbatim) ("~~" (:strike-through t))))

  (setq org-blank-before-new-entry '((heading . auto) (plain-list-item auto)))

  (setq org-image-actual-width nil)
  (setq org-image-max-width 400)

  (setq org-footnote-section nil)

  (setq org-list-allow-alphabetical t)

  ;; Unbind conflicting keys.
  (setq
   org-fold-show-context-detail
   '((isearch . lineage)
     (default . tree)))

  ;; Tags

  (setq org-complete-tags-always-offer-all-agenda-tags t)
  (setq org-use-tag-inheritance '("work"))
  (setq org-tags-match-list-sublevels t)

  ;; Exports

  (setq org-export-backends '(ascii md html icalendar latex))
  (setq org-export-with-toc nil)

  (keymap-unset org-mode-map "C-'")

  (keymap-set org-mode-map "M-{" #'org-backward-element)
  (keymap-set org-mode-map "M-}" #'org-forward-element)

  ;; Alternative keybindings for arrow key related commands.
  (keymap-set org-mode-map "C-c C--" #'org-metaup)
  (keymap-set org-mode-map "C-c C-=" #'org-metadown)
  (keymap-set org-mode-map "C-c C-;" #'org-metaleft)
  (keymap-set org-mode-map "C-c C-'" #'org-metaright)

  ;; Swap these two bindings, since I use the footnotes feature more.
  (keymap-set org-mode-map "C-c C-x C-f" #'org-footnote-action)
  (keymap-set org-mode-map "C-c C-x f" #'org-emphasize)

  (keymap-set org-mode-map "C-c C-8" #'org-list-make-subtree)

  (add-hook 'org-mode-hook #'auto-fill-mode))

;;;; Insert image from clipboard (Denote integration)

(defvar sr/denote-signature-for-media "media"
  "Signature to use for media files.")

;; EXTERNAL: pngpaste <https://github.com/jcsalterego/pngpaste> (macOS)

(defun sr/org-insert-image-from-clipboard ()
  "Create an image file with clipboard data and insert a link to it.
Images are created in `sr/note-media-directory' with Denote file-naming
scheme.

pngpaste is used to retrieve the image from clipboard."
  (interactive)
  (let ((temp-file-name (make-temp-file "image-tmp-")))
    (when (not (eq 0 (call-process-shell-command
		              (format "pngpaste %s" temp-file-name)
		              nil nil)))
      (user-error "Attempted to paste non-image content"))
    (let* ((id (funcall denote-get-identifier-function nil nil))
           (title (denote-title-prompt nil "Image title"))
           (keywords (denote-keywords-prompt "Image keywords"))
           (extension (read-from-minibuffer "Image extension: " "."))
           (width (read-from-minibuffer "Image width (witnout units): "))
           (file-name (denote-format-file-name
                       sr/note-media-directory
                       id keywords title extension "media")))
      (copy-file temp-file-name file-name)
      (unless (string-empty-p width)
        (insert (format "#+attr_html: :width %spx\n" width)))
      (insert (format "[[media:%s]]" (car (last (file-name-split file-name))))))))

(with-eval-after-load 'org
  (keymap-set org-mode-map "C-c i" #'sr/org-insert-image-from-clipboard))

;;; Managing todo items

(with-eval-after-load 'org
  (keymap-set org-mode-map "C-c i" #'sr/org-insert-image-from-clipboard)

  (setq org-todo-keywords
        '((sequence "TODO" "WORKING" "|" "DONE" "FAILED")))
  (setq org-todo-keyword-faces
        '(("TODO" . "gold")
  	      ("WORKING" . "CadetBlue2")
  	      ("FAILED" . "brown1")))

  (setq org-deadline-warning-days 21)

  (setq org-priority-lowest 68
	    org-priority-highest 65
	    org-priority-default 68)

  (add-to-list 'org-modules 'habit))

;;; Source code editing and evaluation

(with-eval-after-load 'org
  (keymap-set org-babel-map "C-k" #'org-babel-remove-result-one-or-many)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t)
     (js . t)))

  (setq org-edit-src-content-indentation 2))

(with-eval-after-load 'ob
  (setq org-confirm-babel-evaluate nil)
  (setq org-babel-results-keyword "results"))

;;; Latex

(with-eval-after-load 'org
  ;; Lualatex
  ;; EXTERNAL: lualatex
  ;; EXTERNAL: imagemagick

  (add-to-list 'org-preview-latex-process-alist
               '(luamagick :programs ("lualatex" "convert")
                           :description "pdf > png"
                           :message "you need to install lualatex and imagemagick."
                           :use-xcolor t
                           :image-input-type "pdf"
                           :image-output-type "png"
                           :image-size-adjust (1.0 . 1.0)
                           :latex-compiler ("lualatex -interaction nonstopmode -output-directory %o %f")
                           :image-converter ("convert -density %D -trim -antialias %f -quality 100 %O")))

  ;; dvisvgm
  ;; EXTERNAL: dvisvgm

  (add-to-list 'org-preview-latex-process-alist
	           '(dvisvgm :programs ("latex" "dvisvgm") :description "dvi > svg"
		                 :message
		                 "you need to install the programs: latex and dvisvgm."
		                 :image-input-type "dvi" :image-output-type "svg"
		                 :image-size-adjust (1.2 . 1.5) :latex-compiler
		                 ("latex -interaction nonstopmode -output-directory %o %f")
		                 :image-converter
		                 ("TEXMFCNF=\"/usr/local/texlive/2025:$TEXMFCNF\" dvisvgm --no-fonts --exact-bbox --scale=%S --output=%O --keep %f")))

  (setq org-preview-latex-default-process 'dvisvgm)
  (setq org-preview-latex-image-directory (expand-file-name "ltximg/" sr/note-root-directory))

  (setq org-latex-packages-alist '(("" "kotex" t) ("" "mathrsfs" t)))

  (setq org-format-latex-options
        '(:foreground "White" :background "Transparent" :scale 2 :html-foreground "Black"
                      :html-background "Transparent" :html-scale 1.0 :matchers
                      ("begin" "$1" "$" "$$" "\\(" "\\[")))

  (add-hook 'org-mode-hook #'org-cdlatex-mode)

  (keymap-unset org-cdlatex-mode-map "$"))

;;; Links

(with-eval-after-load 'ol
  (setq org-link-abbrev-alist
        `(("zk" . ,(expand-file-name "id:%s" sr/note-root-directory))
	      ("media" . ,sr/note-media-directory)))
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file))

;;; Ids

(with-eval-after-load 'org-id
  (setq org-id-method 'uuid)
  (setq org-id-track-globally t)
  (setq org-id-search-archives nil))

;;; Agenda

(with-eval-after-load 'org-agenda
  (setq
   org-agenda-files
   (list sr/note-root-directory))

  (setq org-agenda-restore-windows-after-quit t)

  (setq org-agenda-todo-ignore-deadlines -1)
  (setq org-agenda-skip-deadline-prewarning-if-scheduled t)
  (setq org-agenda-skip-timestamp-if-deadline-is-shown t)
  (setq org-agenda-sorting-strategy
        '((agenda habit-up priority-down deadline-up category-keep)
  	      (todo urgency-down category-keep)
  	      (tags urgency-down category-keep)
  	      (search category-keep)))

  (setq org-agenda-span 14)
  (setq
   org-agenda-custom-commands
   '(("d" "Daily agenda"
	  ((agenda ""
		       ((org-agenda-span 'day)
		        (org-deadline-past-days 0)
		        (org-agenda-deadline-faces
		         '((1.0 . org-scheduled-today)
		           (0.5 . org-scheduled)
		           (0.0 . org-scheduled)))
		        (org-agenda-overriding-header "Events")
		        (org-super-agenda-groups
		         '((:name "Events"
			              :tag ("event"))
		           (:discard (:anything))))
		        (org-agenda-buffer-name "*Org Daily Agenda*")))
	   (agenda ""
		       ((org-agenda-span 'day)
		        (org-agenda-overriding-header "Today")
		        (org-super-agenda-groups
		         '((:discard (:tag "event"))
                   (:name "Goals"
                          :tag ("#weekly" "#monthly" "okr"))
                   (:name "Work"
			              :tag ("work"))
		           (:name "Todo"
			              :and (:todo ("TODO" "WORKING")
                                      :not (:tag "trivial")))
                   (:name "Trivial tasks"
			              :and (:todo ("TODO" "WORKING")
					                  :tag "trivial"))))))))))

  (require 'org-super-agenda)
  (org-super-agenda-mode))

;;; Capturing

(with-eval-after-load 'org-capture
  (keymap-unset org-capture-mode-map "C-c C-c")
  (keymap-set org-capture-mode-map "C-c C-f" 'org-capture-finalize)

  (setq
   org-capture-templates

   `(
     ("t" "Todo"
      entry (file ,(expand-file-name "todo.org" sr/note-root-directory))
      "* TODO %?"
      :prepend t))))

;;; Citation

(with-eval-after-load 'oc
  (setq org-cite-global-bibliography
        (list (expand-file-name "refs/pkm.bib" sr/note-root-directory))))

;;; _

(provide 'sr-org)

;;; sr-org.el ends here
