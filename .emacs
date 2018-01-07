(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

(defun js-mode-bindings ()
   "Sets a hotkey for using the json-snatcher plugin"
     (when (string-match  "\\.(geojson|json)$" (buffer-name))
           (local-set-key (kbd "C-c C-g") 'jsons-print-path)))
   (add-hook 'js-mode-hook 'js-mode-bindings)
   (add-hook 'js2-mode-hook 'js-mode-bindings)
(setq-default truncate-lines t)
(org-babel-do-load-languages 'org-babel-load-languages
			     '((sh . t)
			       (R . t)
			       (python . t)
			       (ipython . t)
			       (sql . t)))



(eval-after-load "sql"
  '(load-library "~/.emacs.d/sql-indent"))


(setq load-path
      (append '("~/.emacs.d/polymode/"  "~/.emacs.d/polymode/modes")
              load-path))


(add-to-list 'load-path "~/Documents/ESS/lisp/")
(load "ess-site")

(require 'poly-R)
(require 'poly-markdown)
(require 'ess-site)

(ess-toggle-underscore nil)

(set-face-attribute 'default nil :height 180)

;;(add-to-list 'default-frame-alist '(font .  "Ubuntu Mono Regular" ))
;;(set-face-attribute 'default t :font  "Ubuntu Mono Regular")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(custom-enabled-themes (quote (manoj-dark)))
 '(package-selected-packages
   (quote
    (markdownfmt markdown-mode+ markdown-mode go-mode jq-mode racket-mode geiser slime wcheck-mode synosaurus cider pgdevenv sql-indent pg ejc-sql ob-ipython babel org flycheck org-beautify-theme format-sql csv-mode sicp xkcd json-mode js2-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
;; turn on colour isn bash
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(set-variable (quote scheme-program-name) "guile")

(defun rmd-mode ()
  "ESS Markdown mode for rmd files"
  (interactive)
  (setq load-path 
    (append (list "~/.emacs.d/polymode/" "~/.emacs.d/polymode/modes")
        load-path))
  (require 'poly-R)
  (require 'poly-markdown)     
  (poly-markdown+r-mode))
(setq org-confirm-babel-evaluate nil)
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images 'append)
;; (setq tramp-default-method "ssh")
(put 'set-goal-column 'disabled nil)
(setq inferior-lisp-program "/usr/local/bin/sbcl")


(add-hook 'racket-mode-hook
          (lambda ()
            (define-key racket-mode-map (kbd "C-c r") 'racket-run)))
(menu-bar-mode     -1)
(toggle-scroll-bar -1)
(tool-bar-mode     -1) 
(show-paren-mode t)
;; (setq ido-enable-flex-matching t)
;; (setq ido-everywhere t)
;; (ido-mode 1)
;; (setq ido-create-new-buffer 'always)
;; (setq ido-file-extensions-order '(".org" ".sql" ".R" ".emacs"  ".el"".txt" ".py"))
;;(setq ido-ignore-buffers '())	Takes a list of buffers to ignore in C-x b
;;(setq ido-ignore-directories'())	Takes a list of directories to ignore in C-x d and C-x C-f
;;(setq ido-ignore-files '())
;; ido-work-directory-list


(global-set-key "\C-x\C-k" 'kill-region)
;;(global-set-key "\C-c\C-k" 'kill-region)

;; convert R's names output into a comma seperated list
(defun names-to-c (start-point end-point)
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start-point end-point)
      ;;(message (number-to-string end-point))
      (goto-char (point-min))
      ;; match: the [8] at the start of each line
      ;; replace: blank
      (while (re-search-forward
	      "[[:space:]]?\\[[0-9]+\\][[:space:]]+" nil t)
	(replace-match ""))
      (goto-char (point-min))
      ;; match: the spaces between the fields on the same line
      ;; replace: new line
      (while (re-search-forward
	      "[[:space:]]+" nil t)
	(replace-match "\n"))
      (goto-char (point-min))
      ;; match: field name
      ;; replacd: remove the double quotes "field-name"
      (while (re-search-forward
	      "\"\\(.*\\)\"" nil t)
	(replace-match "\\1"))
      (goto-char (point-min))
      ;; remove the blank lines
      (while (re-search-forward
	      "^\n" nil t)
	(replace-match ""))
      (goto-char (point-min))
      ;; replace the new lines with ,
      ;; this makes all the fields on one line
      (while (re-search-forward
	      "\n" nil t)
	(replace-match ", "))
      (goto-char (point-min))
      ;; Remove any starting ,
      (while (re-search-forward
	      "^," nil t)
	(replace-match ""))
      (goto-char (point-min))
      ;;remove traling , and any traling white-space
      (while (re-search-forward
	      ",[[:space:]]*?$" nil t)
	(replace-match "")))))


;; put the path of the current buffer in the kill ring
;; insert the word above at point

;; This is from https://sites.google.com/site/steveyegge2/my-dot-emacs-file


(defun swap-windows ()
  "If you have 2 windows, it swaps them."
  (interactive)
  (cond ((not (= (count-windows) 2)) (message "You need exactly 2 windows to do this."))
 (t
 (let* ((w1 (first (window-list)))
	 (w2 (second (window-list)))
	 (b1 (window-buffer w1))
	 (b2 (window-buffer w2))
	 (s1 (window-start w1))
	 (s2 (window-start w2)))
 (set-window-buffer w1 b2)
 (set-window-buffer w2 b1)
 (set-window-start w1 s2)
 (set-window-start w2 s1)))))

(defun rename-file-and-buffer (new-name)
 "Renames both current buffer and file it's visiting to NEW-NAME." (interactive "sNew name: ")
 (let ((name (buffer-name))
	(filename (buffer-file-name)))
 (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
 (if (get-buffer new-name)
	 (message "A buffer named '%s' already exists!" new-name)
	(progn 	 (rename-file filename new-name 1) 	 (rename-buffer new-name) 	 (set-visited-file-name new-name) 	 (set-buffer-modified-p nil)))))) ;;
;; Never understood why Emacs doesn't have this function, either.
;;
(defun move-buffer-file (dir)
  "Moves both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
 (let* ((name (buffer-name))
	 (filename (buffer-file-name))
	 (dir
	 (if (string-match dir "\\(?:/\\|\\\\)$")
	 (substring dir 0 -1) dir))
	 (newname (concat dir "/" name)))

 (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
   (progn
     (copy-file filename newname 1)
     (delete-file filename)
     (set-visited-file-name newname)
     (set-buffer-modified-p nil)
		t))))

;; set up gmail

(setq user-mail-address "pizzadave108@gmail.com"
      user-full-name "David Morrisroe")

(setq gnus-select-method
      '(nnimap "gmail"
	       (nnimap-address "imap.gmail.com")  ; it could also be imap.googlemail.com if that's your server.
	       (nnimap-server-port "imaps")
	       (nnimap-stream ssl)))

(setq smtpmail-smtp-server "imap.gmail.com"
      smtpmail-smtp-service 587
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

;; create a new M-x key binding
(global-set-key "\C-x\C-m" 'execute-extended-command)
;; converting C-w to a backspace like command
(global-set-key "\C-w" 'kill-region)
(defalias 'rr 'replace-regexp)
(defalias 'cr 'comment-region)
(defalias 'rm 'rectangle-mark-mode)

;; do not make annoying sounds I don't think this is an issues on linux
;; like it is on stupid windows
;;(set-message-beep 'silent)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; ess-eavl-pipe.el
;; evaluate a magrittr pipe %>% in R
;; identify the start and end of a multiline foward pipe
;; command and send it the ess-eval-region

;; Copyright (C) 2017 D. J. Morrisroe <davidjmorrisroe@gmail.com>

;; Author David J. Morrisroe <davidjmorrisroe@gmail.com>
;; Created 2017 Feburary 25

;; This file is not part of ess
;; This file is not part of emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; A copy of the GNU General Public License is available at
;; http://www.r-project.org/Licenses/

;;; Commentary:

;; ess-eval-pipe was created for the quicj evaluation of
;; multiline R commands linked tograther using the magrittr
;; forward pipe %>% operater.

;; It will also work on many other multi-line commands
;; such as + , <- etc

;; it does not work on multiline commands where the comma is placed
;; at the beginning of the next line
;; it should work anywhare the indation in emacs works.

;; Please report all bugs to davidjmorrisroe@gmail.com

;; function to 
(defun ess-eval-pipe (&optional vis)
     (interactive "P")
     (save-excursion

       (setq save-point (point))
       (goto-char
	(re-search-backward
	 ;; search for a line NOT ending in a continuation operator
	 "[^,*+%=(-]$"  nil t 1))
       (end-of-line)
       (forward-char 1)
       (setq beg (point))

       (goto-char save-point)
       ;; search forward to find the next line not ending with a
       ;; continuation operator
       (goto-char
	(re-search-forward
	 ;; search for a line NOT ending in a continuation operator
	 "[^,*+%=(-]$" nil t 1))
       (end-of-line)
       (setq end (point))
       (message "beg %d end %d" beg end)
       (ess-eval-region beg end vis "Eval pipe")))
