;;; sr-latex.el --- Latex configurations  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Auctex

(require 'auctex)
(require 'tex)
(require 'latex)

(setq TeX-auto-save t)
(setq TeX-parse-self t)

(setq-default TeX-master t)

(defun sr/TeX-open-pdf-as-buffer ()
  "Open the pdf output as a buffer.
Used in `TeX-view-program-list'."
  (unless TeX-PDF-mode
    (error "PDF Tools only work with PDF output"))
  (let* ((pdf (TeX-active-master (TeX-output-extension)))
         (buffer (or (find-buffer-visiting pdf)
                     (find-file-noselect pdf))))
    (display-buffer buffer)))

(add-to-list
 'TeX-view-program-list
 '("PDF Buffer" sr/TeX-open-pdf-as-buffer))

(add-to-list
 'TeX-view-program-selection
 '(output-pdf "PDF Buffer"))

(setq TeX-save-query nil)

;;; Math-delimiters

(keymap-set org-mode-map "$" #'math-delimiters-insert)
(keymap-set LaTeX-mode-map "$" #'math-delimiters-insert)

(require 'cdlatex)

;;; Cdlatex

(with-eval-after-load 'cdlatex
  (setq cdlatex-math-symbol-alist
        '(
          ( ?a  ("\\alpha"          ))
          ( ?A  ("\\forall"         "\\aleph"))
          ( ?b  ("\\beta"           ))
          ( ?B  (""                 ))
          ( ?c  (""                 ""                "\\cos"))
          ( ?C  (""                 ""                "\\arccos"))
          ( ?d  ("\\delta"          "\\partial"))
          ( ?D  ("\\Delta"          "\\nabla"))
          ( ?e  ("\\epsilon"        "\\varepsilon"    "\\exp"))
          ( ?E  ("\\exists"         ""                "\\ln"))
          ( ?f  ("\\phi"            "\\varphi"))
          ( ?F  ("\\Phi"                 ))
          ( ?g  ("\\gamma"          ""                "\\lg"))
          ( ?G  ("\\Gamma"          ""                "10^{?}"))
          ( ?h  ("\\eta"            "\\hbar"))
          ( ?H  (""                 ))
          ( ?i  ("\\in"             "\\imath"))
          ( ?I  (""                 "\\Im"))
          ( ?j  (""                 "\\jmath"))
          ( ?J  (""                 ))
          ( ?k  ("\\kappa"          ))
          ( ?K  (""                 ))
          ( ?l  ("\\lambda"         "\\ell"           "\\log"))
          ( ?L  ("\\Lambda"         ))
          ( ?m  ("\\mu"             ))
          ( ?M  (""                 ))
          ( ?n  ("\\nu"             ""                "\\ln"))
          ( ?N  ("\\nabla"          ""                "\\exp"))
          ( ?o  ("\\omega"          ))
          ( ?O  ("\\Omega"          "\\mho"))
          ( ?p  ("\\pi"             "\\varpi"))
          ( ?P  ("\\Pi"             "\\textt{++}"))
          ( ?q  ("\\theta"          "\\vartheta"))
          ( ?Q  ("\\Theta"          ))
          ( ?r  ("\\rho"            "\\varrho"))
          ( ?R  (""                 "\\Re"))
          ( ?s  ("\\sigma"          "\\varsigma"      "\\sin"))
          ( ?S  ("\\Sigma"          ""                "\\arcsin"))
          ( ?t  ("\\tau"            ""                "\\tan"))
          ( ?T  (""                 ""                "\\arctan"))
          ( ?u  ("\\upsilon"        ))
          ( ?U  ("\\Upsilon"        ))
          ( ?v  ("\\vee"            ))
          ( ?V  (""            ))
          ( ?w  ("\\xi"             ))
          ( ?W  ("\\Xi"             ))
          ( ?x  ("\\chi"            ))
          ( ?X  (""                 ))
          ( ?y  ("\\psi"            ))
          ( ?Y  ("\\Psi"            ))
          ( ?z  ("\\zeta"           ))
          ( ?Z  (""                 ))
          ( ?   (""                 ))
          ( ?0  ("\\varnothing"     ))
          ( ?1  (""                 ))
          ( ?2  (""                 ))
          ( ?3  (""                 ))
          ( ?4  (""                 ))
          ( ?5  (""                 ))
          ( ?6  (""                 ))
          ( ?7  (""                 ))
          ( ?8  ("\\infty"          ))
          ( ?9  (""                 ))
          ( ?!  ("\\neg"            ))
          ( ?@  (""                 ))
          ( ?#  (""                 ))
          ( ?$  (""                 ))
          ( ?%  (""                 ))
          ( ?^  ("\\uparrow"        ))
          ( ?&  ("\\wedge"          ))
          ( ?\? (""                 ))
          ( ?~  ("\\approx"         "\\simeq"))
          ( ?_  ("\\downarrow"      ))
          ( ?+  ("\\cup"            "\\bigcup"))
          ( ?-  ("\\leftrightarrow" "\\longleftrightarrow" ))
          ( ?*  ("\\times"          "\\bigcap"))
          ( ?/  ("\\not"            ))
          ( ?|  ("\\mapsto"         "\\longmapsto"))
          ( ?\\ ("\\setminus"       ))
          ( ?\" (""                 ))
          ( ?=  ("\\Leftrightarrow" "\\Longleftrightarrow"))
          ( ?\( ("\\langle"         ))
          ( ?\) ("\\rangle"         ))
          ( ?\[ ("\\Leftarrow"      "\\Longleftarrow"))
          ( ?\] ("\\Rightarrow"     "\\Longrightarrow"))
          ( ?{  ("\\subset"         "\\subseteq"))
          ( ?}  ("\\supset"         "\\supseteq"))
          ( ?<  ("\\leftarrow"      "\\longleftarrow"     "\\min"))
          ( ?>  ("\\rightarrow"     "\\longrightarrow"    "\\max"))
          ( ?`  (""                 ))
          ( ?'  ("\\prime"          ))
          ( ?.  ("\\cdot"           ))
          )))

;;; _

(provide 'sr-latex)

;;; sr-latex.el ends here
