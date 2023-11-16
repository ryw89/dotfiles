;; init.el --- Emacs configuration

;; X-resources (Inhibit alpha)
(setq inhibit-x-resources t)

;; INSTALL PACKAGES
;; 

(require 'package)

(add-to-list 'package-archives
			 '("melpa" . "http://melpa.org/packages/") t)
;(add-to-list 'package-archives
;			 '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
(add-to-list 'package-archives
             '("xaldew" . "https://gustafwaldemarson.com/elpa/"))
(add-to-list 'package-unsigned-archives "xaldew")

;(package-refresh-contents)

(defvar myPackages '(alert pydoc markdown-mode magit evil-mc dash
 exec-path-from-shell gorepl-mode ace-window auctex
 better-defaults buffer-move counsel-projectile company dashboard
 elfeed elfeed-org elpy enh-ruby-mode ess ess-view evil
 fill-column-indicator flycheck go-mode gscholar-bibtex helm-ag
 helm-org-rifle helm-projectile hydra inf-ruby xml-rpc ivy-bibtex
 iy-go-to-char material-theme mu4e-alert multiple-cursors ob-go
 org-noter org-ref page-break-lines pdf-tools projectile
 py-autopep8 rainbow-delimiters ranger rg rubocop rubocopfmt
 slirm smooth-scrolling swiper undo-tree wc-mode wttrin yasnippet
 calfw calfw-org package-utils org-gcal use-package matlab-mode
 epm git-timemachine kotlin-mode eclim gradle-mode
 company-emacs-eclim csv-mode rust-mode cargo json-mode jq-format
 clang-format vterm yaml-mode py-yapf lsp-mode lsp-ui
 arduino-mode use-package leuven-theme js2-mode js2-refactor
 xref-js2 prettier-js flymake-jslint rjsx-mode tide notmuch
 counsel-notmuch helm-notmuch chess dockerfile-mode realgud
 flycheck-clang-analyzer pandoc-mode groovy-mode jenkinsfile-mode
 flycheck-rust rustic format-all flycheck-clang-tidy scala-mode
 sbt-mode lsp-metals lsp-java yasnippet-snippets elixir-mode
 nasm-mode ace-popup-menu org-roam))

(defvar myWindowsPackages '(alert pydoc markdown-mode magit
  evil-mc dash exec-path-from-shell gorepl-mode ace-window auctex
  better-defaults buffer-move counsel-projectile company
  dashboard elfeed elfeed-org elpy enh-ruby-mode ess ess-view
  evil fill-column-indicator flycheck go-mode gscholar-bibtex
  helm-ag helm-org-rifle helm-projectile hydra inf-ruby xml-rpc
  ivy-bibtex iy-go-to-char material-theme mu4e-alert
  multiple-cursors ob-go org-noter org-ref page-break-lines
  pdf-tools projectile py-autopep8 rainbow-delimiters ranger rg
  rubocop rubocopfmt slirm smooth-scrolling swiper undo-tree
  wc-mode wttrin yasnippet calfw calfw-org package-utils org-gcal
  use-package matlab-mode epm git-timemachine kotlin-mode eclim
  gradle-mode company-emacs-eclim csv-mode rust-mode cargo
  json-mode jq-format clang-format vterm yaml-mode py-yapf
  lsp-mode lsp-ui arduino-mode use-package leuven-theme js2-mode
  js2-refactor xref-js2 prettier-js flymake-jslint rjsx-mode tide
  notmuch counsel-notmuch helm-notmuch chess dockerfile-mode
  realgud flycheck-clang-analyzer pandoc-mode groovy-mode
  jenkinsfile-mode flycheck-rust rustic format-all ox-json poly-R
  flycheck-clang-tidy scala-mode sbt-mode lsp-metals
  yasnippet-snippets elixir-mode nasm-mode ace-popup-menu
 org-roam))

;; Maybe metaweblog? ob-go?

(unless (eq system-type 'windows-nt)
  (mapc #'(lambda (package)
	    (unless (package-installed-p package)
	      (package-install package)))
	myPackages))

(when (eq system-type 'windows-nt)
  (mapc #'(lambda (package)
	    (unless (package-installed-p package)
	      (package-install package)))
	myWindowsPackages))

(setq exec-path-from-shell-check-startup-files nil)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(unless (eq system-type 'windows-nt)
  (pdf-tools-install))

;; Personal Lisp directory
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; whitespace mode
(global-set-key (kbd "C-c w s") 'whitespace-mode)

;; untabify
(global-set-key (kbd "C-c u t") 'untabify)

;; LSP
(use-package lsp-ui)

(global-set-key (kbd "C-c p i") 'lsp-ui-imenu)
(global-set-key (kbd "C-c l s") 'lsp-describe-thing-at-point)

(setq lsp-ui-doc-show-with-cursor t)

;; Some LSP servers are expensive, especially metals. Close server
;; when last associated buffer is closed.
(setq lsp-keep-workspace-alive nil)

;; special font size for x260
(setq hostname (replace-regexp-in-string "\n$" "" (shell-command-to-string "hostname")))
;;(when (string= hostname "ryan-x260") (set-face-attribute 'default nil :height 105))
`
;; EXTRA FUNCTIONS
;;

(require 'ssh)

(defun rm-nonascii (beg end)
  "Delete binary characters in a region"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (re-search-forward "[^[:ascii:]]" nil t)
        (replace-match "")))))

(global-set-key (kbd "C-c r n") 'rm-nonascii)


(defun file-string (file)
  "Read the contents of a file and return as a string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defun insert-current-date ()
  (interactive)
  (insert (shell-command-to-string "echo -n $(date '+%B %d, %Y')")))

(global-set-key (kbd "C-c i d") 'insert-current-date)

(defhydra hydra-search (:color blue) 
  "Search"
  ("f" counsel-locate "Search for file name")
  ("h" helm-for-files "Expanded file name search")
  ("r" rg "Search files and their contents")
  ("o" helm-org-rifle "Search .org files"))

;;(global-set-key (kbd "C-c h f") 'hydra-search/body)
;; (global-set-key (kbd "C-c h s") 'hydra-search/body)

(defun buffer-file-name-kill-ring ()
  "Add current buffer's file name to kill ring."
  (interactive)
  (kill-new buffer-file-name)
  (message "Added %s to kill ring." (buffer-file-name)))

(global-set-key (kbd "C-c n b") 'buffer-file-name-kill-ring)

(defun shell-command-on-region-replace ()
  (interactive)
  (let ((current-prefix-arg 4)) ;; emulate C-u
    (call-interactively 'shell-command-on-region)))

(global-set-key (kbd "M-|") 'shell-command-on-region-replace)


;; UNUSED STUFF
;;

(defun ivy-org-command-list ()
  "Input commands from an Org file using Ivy."
  (interactive)
  (let (hist-cmd collection val)
    (setq collection
		  (split-string
		   (with-temp-buffer
			 (insert-file-contents
			  (file-truename "~/Dropbox/Emacs/test.org"))
			 (goto-char (point-min))
			 ;; Split commands at Org-headings
			 (buffer-string)) "* " t))
	;; Regex to remove leading asterisks if present
	(setq collection
		  (mapcar
		   (lambda (it) (replace-regexp-in-string "\*+" "" it)) collection))
	;; Another regex to remove trailing newlines
	(setq collection
		  (mapcar
		   (lambda (it) (replace-regexp-in-string "\n$" "" it)) collection))
    (when (and collection (> (length collection) 0)
               (setq val (if (= 1 (length collection)) (car collection)
                           (ivy-read (format "Command:")
									 collection))))
	  (kill-new val)
	  (yank))))


;; KEYBOARD MACROS
;;

;; none for now...

;; BASIC CUSTOMIZATION
;;

;; Why is this necessary?
(when (string= system-name "ryan-imac")
  (setq x-super-keysym 'meta))

;; path
(setq exec-path (append exec-path '("/home/ryanw/.local/bin")))

;;(setq blink-cursor-mode nil)
(blink-cursor-mode 0)
(global-auto-revert-mode)
(setq-default tab-width 4) ;; Preference for Golang

(setq ring-bell-function 'ignore)

;; Don't open new window when running async-shell-command
(add-to-list 'display-buffer-alist
			 (cons "\\*Async Shell Command\\*.*"
				   (cons #'display-buffer-no-window nil)))

; Unbind keys for ace-window and Org global links
;(dolist (key '("\M-o")
;	     '("\C-c L")
;	     '("\C-c O")
;	     )
;  (global-unset-key key))

(setq inhibit-startup-message t) ;; hide the startup message

(scroll-bar-mode -1) ;; turn off scroll bar
(setq split-height-threshold nil) ;; change default window split
(setq split-width-threshold 0)

(setq esf/proportional-font-inuse nil)
(defun esf/toggle-proportional-font ()
  (interactive)
  (if esf/proportional-font-inuse
      (custom-theme-set-faces 'user `(default ((t (:font "Deja Vu Sans Mono")))))
    (custom-theme-set-faces 'user `(default ((t (:font "Deja Vu Sans"))))))
  (setq esf/proportional-font-inuse (not esf/proportional-font-inuse)))

(put 'downcase-region 'disabled nil)

(add-hook 'before-save-hook 'time-stamp) ;; Update timestamp (Time-stamp: <>)
(setq time-stamp-format "%:y-%02m-%02d %02H:%02M:%02S ryanwhittingham89@gmail.com")

(global-set-key (kbd "C-c l n") 'display-line-numbers-mode) 
(global-set-key (kbd "C-c n l") 'display-line-numbers-mode) 

;; Dired

(eval-after-load "dired"
  '(progn
	 (defadvice dired-advertised-find-file (around dired-subst-directory activate)
	   "Replace current buffer if file is a directory."
	   (interactive)
	   (let* ((orig (current-buffer))
			  ;; (filename (dired-get-filename))
			  (filename (dired-get-filename t t))
			  (bye-p (file-directory-p filename)))
		 ad-do-it
		 (when (and bye-p (not (string-match "[/\\\\]\\.$" filename)))
		   (kill-buffer orig))))))

(global-set-key (kbd "C-x d") 'dired-other-window)

;; (org-agenda-list)

(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-c r p") 'query-replace-regexp)
(global-set-key (kbd "C-c m c") 'mc/edit-lines) ; multi-cursor
(global-set-key (kbd "C-x r d") 'rainbow-delimiters-mode)
(global-set-key (kbd "C-c f s") 'flyspell-mode)
(global-set-key (kbd "C-c d r") 'downcase-region)
(global-set-key (kbd "C-c h a") 'helm-ag) ;; Prefix with C-u to choose directory
(global-set-key (kbd "C-c p s h") 'helm-projectile-ag)
(global-set-key (kbd "C-c y") 'counsel-yank-pop)
;(global-set-key (kbd "C-x p") 'pianobar)

;; global org links
(global-set-key (kbd "C-c L") 'org-insert-link-global)
(global-set-key (kbd "C-c O") 'org-open-at-point-global)

;; Backups
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; Yes or no becomes y or n
(fset 'yes-or-no-p 'y-or-n-p)

(global-set-key (kbd "C-c v l") 'visual-line-mode)

;; CAL-FW
;;

(require 'calfw)
(require 'calfw-org)
(global-set-key (kbd "C-c o c") 'cfw:open-org-calendar)

;; COMINT HISTORY & COUNSEL
(global-set-key (kbd "C-c h s") 'counsel-shell-history)

;; COUNSEL-PROJECTILE
;;

(counsel-projectile-mode)

(global-set-key (kbd "C-c p p") 'counsel-projectile-switch-project)
(global-set-key (kbd "C-c p f") 'counsel-projectile-find-file)

;; external file functions. Use M-o to open menu where this will be found.
(defun counsel-locate-action-extern (x)
  "Use xdg-open shell command, or corresponding system command, on X."
  (interactive (list (read-file-name "File: ")))
  (if (and (eq system-type 'windows-nt)
           (fboundp 'w32-shell-execute))
      (w32-shell-execute "open" x)
    (call-process shell-file-name nil
                  nil nil
                  shell-command-switch
                  (format "%s %s"
                          (cl-case system-type
                            (darwin "open")
                            (t "xdg-open"))
                          (concat (shell-quote-argument x) " &")))))

;; PROJECTILE
;;

(if (file-exists-p "~/Dropbox/ResistanceLabs/")
	(setq projectile-project-search-path '("~/Dropbox/ResistanceLabs/")))

;; BIBTEX MODE
;;

(defun my-bibtex-mode-config ()
  "For use in `bibtex-mode-hook'."
  (local-set-key (kbd "C-c s b") 'bibtex-sort-buffer))

(add-hook 'bibtex-mode-hook 'my-bibtex-mode-config)

;; IVY-BIBTEX
;;

(require 'ivy-bibtex)
(setq bibtex-completion-bibliography
      '("~/Dropbox/Emacs/library.bib"))
(setq bibtex-completion-pdf-field "File")
;(setq bibtex-completion-pdf-open-function
;  (lambda (fpath)
;    (call-process "evince" nil 0 nil fpath))) ;Opens pdf with evince

(advice-add 'bibtex-completion-candidates ;Reverse list from .bib
            :filter-return 'reverse)

(global-set-key (kbd "C-x c") 'ivy-bibtex)

(ivy-set-actions
 'ivy-bibtex
 '(("p" ivy-bibtex-open-pdf "Open PDF file (if present)")
   ("b" ivy-bibtex-insert-bibtex "Insert BibTeX entry")
   ("u" ivy-bibtex-open-url-or-doi "Open URL or DOI in browser")
   ("c" ivy-bibtex-insert-citation "Insert citation")
   ("r" ivy-bibtex-insert-reference "Insert reference")
   ("k" ivy-bibtex-insert-key "Insert BibTeX key")
   ("x" ivy-bibtex-xdg-open "Open PDF with external application")
   ("a" ivy-bibtex-add-PDF-attachment "Attach PDF to email")
   ("e" ivy-bibtex-edit-notes "Edit notes")
   ("s" ivy-bibtex-show-entry "Show entry")
   ; ("l" ivy-bibtex-add-pdf-to-library "Add PDF to library")
   ("d" ivy-bibtex-doi-download "Download PDF")
   ("t" ivy-bibtex-doi-title "Get DOI from title")
   ; ("n" (ivy-bibtex-doi-title ivy-bibtex-doi-download) "Get DOI & download PDF")
   ("f" (lambda (_candidate) (ivy-bibtex-fallback ivy-text)) "Fallback options")))

(defun bibtex-doi-download (keys)
  "Download an article from ivy-bibtex using its DOI, using
   doi-download.py"
  (dolist (key keys)
    (let* ((entry (bibtex-completion-get-entry key))
           (doi (bibtex-completion-get-value "doi" entry)))
      (if doi
          (progn
			(message (concat "Running doi-download.py with DOI: " doi " ..."))
			(shell-command (concat "python3 $HOME/Dropbox/Emacs/scripts/doi-download.py " doi))
			(setq doi-download-exit-msg
				  (file-string "/tmp/.doi-download-exit-msg"))
			(message doi-download-exit-msg))			
		(message "No DOI found for this entry: %s" key)))))

(defun bibtex-doi-title (keys)
  "Get an article's DOI from its title and add it to library.bib."
  (dolist (key keys)
    (let* ((entry (bibtex-completion-get-entry key))
		   (title (bibtex-completion-get-value "title" entry)))
      (if title
		  (let*
			  ((doi
			   (shell-command-to-string
				(concat "python3 $HOME/Dropbox/Emacs/scripts/title-doi.py " "'"title"'"))))
			(message "Added DOI %s" doi))))))

(defun bibtex-doi-title-download ()
  "Get DOI, then attempt to download PDF."
  (bibtex-doi-title (keys))
  (bibtex-doi-download (keys)))

(defun bibtex-xdg-open (keys)
  "Open PDF with xdg-open rather than Emacs."
  (dolist (key keys)
    (let* ((entry (bibtex-completion-get-entry key))
           (file (bibtex-completion-get-value "file" entry)))
      (if file
          (progn
			(message (concat "Opening " file " ..."))
			(shell-command (concat "~/Dropbox/Emacs/scripts/ivy-bibtex-xdg-open.sh " file)))
		(message "No PDF found for this entry: %s" key)))))

(ivy-bibtex-ivify-action bibtex-doi-download ivy-bibtex-doi-download)
(ivy-bibtex-ivify-action bibtex-doi-title ivy-bibtex-doi-title)
(ivy-bibtex-ivify-action bibtex-doi-title-download ivy-bibtex-doi-title-download)
(ivy-bibtex-ivify-action bibtex-xdg-open ivy-bibtex-xdg-open)

;; DASHBOARD
;;

(require 'dashboard)

;; Hangs on Emacs 25.1.1 on ryan-asus w/ Debian 9
(unless (string= system-name "ryan-asus")
  (dashboard-setup-startup-hook))

(setq initial-buffer-choice
	  (lambda () (get-buffer "*dashboard*")))

(setq dashboard-items '((agenda . 20)
			(recents  . 5)
                        (projects . 10)
                        (bookmarks . 5)
                        (registers . 5)))

(setq dashboard-set-footer nil)

(defun my-dashboard-mode-config ()
  "For use in `dashboard-mode-hook'."
  (local-set-key (kbd "e") 'elfeed)
  (local-set-key (kbd "n") 'mu4e)
  )

(add-hook 'dashboard-mode-hook 'my-dashboard-mode-config)

;; Use counsel instead of vanilla projectile
;; (This is applied globally, but most useful in Dashboard.)
(advice-add 'projectile-find-file :override 'counsel-projectile-find-file)


;; IVY/COUNSEL/SWIPER
;;

(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
;; (global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
(define-key counsel-find-file-map (kbd "<left>") 'counsel-up-directory)
(define-key counsel-find-file-map (kbd "<right>") 'ivy-alt-done)


;; Use counsel to search through Bash history
;; NOTE: Should rewrite for Zsh
(defun counsel-yank-bash-history ()
  "Yank the bash history"
  (interactive)
  (let (hist-cmd collection val)
    (shell-command "history -r") ; reload history
	(shell-command "cat ~/.zsh_history | cut -d ';' -f2 > /tmp/zsh_hist") ; Just commands
    (setq collection
          (nreverse
           (split-string
	    (with-temp-buffer (insert-file-contents
					    (file-truename "/tmp/zsh_hist"))
                                           (buffer-string))
                         "\n" t)))
    (when (and collection (> (length collection) 0)
               (setq val (if (= 1 (length collection)) (car
               collection)
                           (ivy-read (format "Zsh history:")
									 collection))))
	  (kill-new val)
	  (yank))))

(defun ivy-bash-aliases ()
  "Use Ivy to list Bash aliases."
  (interactive)
  (setq inhibit-message t) ;; Avoid annoying messages
  ;; Process .bash_aliases with Ruby script, returning a single string.
  (shell-command "ruby $HOME/Dropbox/Emacs/scripts/ivy-bash-aliases.rb")
  (setq inhibit-message nil)
  ;; counsel-yank-search-bash-history portion begins here
  (let (hist-cmd collection val)
    (setq collection
			 (split-string
			  (with-temp-buffer (insert-file-contents
								 (file-truename "/tmp/ivy-bash-aliases"))
								(buffer-string)) "\n" t))
    (when (and collection (> (length collection) 0)
               (setq val (if (= 1 (length collection)) (car
														collection)
                           (ivy-read (format "Bash aliases:")
									 collection))))
	  (kill-new val)
	  (yank))))

(defun my-shell-mode-config ()
  "For use in `shell-mode-hook'."
  (local-set-key (kbd "M-p") 'counsel-yank-bash-history)
  (local-set-key (kbd "C-c C-a") 'ivy-bash-aliases)
  )

(add-hook 'shell-mode-hook 'my-shell-mode-config)


;; ORG-MODE
;;

(setq org-adapt-indentation nil)

(defun polisci-org-insert-links ()
  "Insert links to polisci files for current heading. Use with
   polisci.org."
  (interactive)
  (setq org-current-heading
		(nth 4 (org-heading-components)))
  (insert (shell-command-to-string
   (concat "ruby $HOME/Dropbox/Emacs/scripts/polisci-org.rb " "'"org-current-heading"'"))))

(setq org-todo-keywords
      '((sequence "TODO" "NEXT" "CURR" "|" "DONE" "CNCL" "SUSP")))

(setq org-todo-keyword-faces '(
        ("NEXT" .
	 (:foreground "khaki"
	  :background "dark goldenrod"
	  :weight bold))
        ("CURR" .
	 (:foreground "light blue"
	  :background "midnight blue"
	  :weight bold))
	))

(setq org-agenda-files
	  (quote
	   ("~/Dropbox/Emacs/flights.org"
		"~/Dropbox/Emacs/gcal.org"
		"~/Dropbox/Emacs/jobs.org"
		"~/Dropbox/Emacs/notes.org"
		"~/Dropbox/Emacs/todo.org")))

(defun my-org-agenda-write ()
  (interactive)
  (org-agenda-write "~/Dropbox/Emacs/agenda.ics"))

(run-with-timer 0 (* 60 60) 'my-org-agenda-write)

;; Org-gcal 
;;(unless (string= system-name "ryan-asus")
;;  (load "~/Dropbox/Emacs/org-gcal.el"))


;; Tags in Org-agenda at right margin, column 80
(setq org-agenda-tags-column -80)

;; Tags in org-mode just one space after
(setq org-tags-column 0)

;; Change states in Org buffers easily
(setq org-support-shift-select t)

;; Start the weekly agenda on Sunday
(setq org-agenda-start-on-weekday 0)

;; Deadlines
(setq org-deadline-warning-days 30)

;; Highlight LaTeX
;(setq org-highlight-latex-and-related '(latex script entities))

;; White text for LaTeX preview
(setq org-format-latex-header
	  (concat org-format-latex-header "\\AtBeginDocument{\\color{white}}"))

;; You may wish to try the commented-out line if Beamer or LaTeX is having trouble.
;; (setq org-latex-pdf-process '("texi2dvi --pdf --clean --verbose --batch %f")) 
(setq org-latex-pdf-process
      '("pdflatex -interaction nonstopmode -output-directory %o %f"
        "bibtex %b"
        "pdflatex -interaction nonstopmode -output-directory %o %f"
        "pdflatex -interaction nonstopmode -output-directory %o %f")) 


(org-agenda nil "a")
(setq org-default-notes-file (concat org-directory "/notes.org"))

(add-hook 'after-init-hook 'org-beamer-mode)
(add-hook 'after-init-hook 'org-agenda-list)

;; Repeated tasks show up for today and tomorrow
(setq org-agenda-show-future-repeats 'next)

(setq org-capture-templates
   (quote
    (("r" "Readings" entry
      (file+headline "~/Dropbox/Emacs/todo.org" "Readings")
      "* TODO %?\n  %t\n  %i\n  %a\n")
	 ("s" "Stocks" entry
      (file+headline "~/Dropbox/Emacs/stocks.org" "Stocks")
      "**** TODO %a\n %t\n")
	 ("j" "Jobs" entry
      (file+headline "~/Dropbox/Emacs/todo.org" "Jobs")
      "* TODO %?\n  %t\n  %i\n  %a\n")
     ("t" "To-Do" entry
      (file "~/Dropbox/Emacs/todo.org")
      "* TODO %?\n  %t\n  %i\n  %a\n")
     ("f" "Refile" entry (file "~/Dropbox/Emacs/refile.org")
      "* TODO %?\n  %t\n  %i\n  %a\n"))))

(global-set-key (kbd "C-c o s") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c b") 'org-iswitchb)

;; Org-noter keybinding in Org-mode
(defun my-org-mode-config ()
  "For use in `org-mode-hook'."
  (local-set-key (kbd "C-c o n") 'org-noter)
  )

(add-hook 'org-mode-hook 'my-org-mode-config)

;; flyspell mode for spell checking
(add-hook 'org-mode-hook 'flyspell-mode)

;; Disable certain keys in org-mode
(add-hook 'org-mode-hook
          '(lambda ()
             ;; Undefine C-c [ and C-c ] since this breaks my
             ;; org-agenda files when directories are included. It
             ;; expands the files in the directories individually
             (org-defkey org-mode-map "\C-c[" 'undefined)
             (org-defkey org-mode-map "\C-c]" 'undefined)
             (org-defkey org-mode-map "\C-c;" 'undefined)
             (org-defkey org-mode-map "\C-c\C-x\C-q" 'undefined))
          'append)

;; org-roam

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "/home/ryanw/Dropbox/Emacs/org-roam/"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
		 ("C-c n f" . org-roam-node-find)
                 ("C-c n s" . org-roam-node-search)
		 ("C-c n g" . org-roam-graph)
		 ("C-c n i" . org-roam-node-insert)
		 ("C-c n c" . org-roam-capture)
		 ;; Dailies
		 ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (org-roam-db-autosync-mode))

;; from: https://jethrokuan.github.io/org-roam-guide/
(setq org-roam-capture-templates
      '(("m" "main" plain
         "%?"
         :if-new (file+head "main/${slug}.org"
                            "#+title: ${title}\n")
         :immediate-finish t
         :unnarrowed t)
        ("r" "reference" plain "%?"
         :if-new
         (file+head "reference/${title}.org" "#+title: ${title}\n")
         :immediate-finish t
         :unnarrowed t)
        ("a" "article" plain "%?"
         :if-new
         (file+head "articles/${title}.org" "#+title: ${title}\n#+filetags: :article:\n")
         :immediate-finish t
         :unnarrowed t)))

(with-eval-after-load 'org-roam
  (cl-defmethod org-roam-node-type ((node org-roam-node))
	"Return the TYPE of NODE."
	(condition-case nil
		(find-name-nondirectory
		 (directory-file-name
		  (file-name-directory
		   (file-relative-name (org-roam-node-file node) org-roam-directory))))
	  (error ""))))

(setq org-capture-templates
	  '(("s" "Slipbox" entry (file "/home/ryanw/Dropbox/Emacs/org-roam/inbox.org")
		 "* %?\n")))

(defun org-capture-slipbox ()
  (interactive)
  (org-capture nil "s"))

(global-set-key (kbd "C-c s") 'org-capture-slipbox)
(global-set-key (kbd "C-c t a") 'org-roam-tag-add)
(global-set-key (kbd "C-c t r") 'org-roam-tag-remove)
(global-set-key (kbd "C-c d s") 'org-roam-db-sync)
  

;; EXPORT
(setq org-export-with-smart-quotes t)
(setq org-odt-preferred-output-format "docx")

;; ORG2HTML -- HIGHLIGHT JS SUPPORT

(defun org2html-trim-string (string)
  (replace-regexp-in-string "\\`[ \t\n]*" "" (replace-regexp-in-string "[ \t\n]*\\'" "" string)))

(defun org2html--char-to-string (ch)
  (let ((chspc 32)
        (chsq 39)
        (ch0 48)
        (ch9 57)
        (cha 97)
        (chz 122)
        (chA 65)
        (chZ 90)
        (chdot 46)
        (chminus 45)
        (chunderscore 95)
        rlt)
    (cond
     ((or (and (<= ch0 ch) (<= ch ch9))
          (and (<= cha ch) (<= ch chz))
          (and (<= chA ch) (<= ch chZ))
          (= chunderscore ch)
          (= chminus ch)
          )
      (setq rlt (char-to-string ch)))
     ((or (= chspc ch) (= chsq ch) (= chdot ch))
      (setq rlt "-")))
    rlt
    ))

(defun org2html-get-slug (str)
  (let (slug )
    (setq slug (mapconcat 'org2html--char-to-string str ""))
    ;; clean slug a little bit
    (setq slug (replace-regexp-in-string "\-\-+" "-" slug))
    (setq slug (replace-regexp-in-string "^\-+" "" slug))
    (setq slug (replace-regexp-in-string "\-+$" "" slug))
    (setq slug (org2html-trim-string slug))
    (setq slug (downcase slug))
    slug))

(defun org2html-replace-pre (html)
  "Replace pre blocks with sourcecode shortcode blocks.
shamelessly copied from org2blog/wp-replace-pre()"
  (save-excursion
    (let (pos code lang info params header code-start code-end html-attrs pre-class)
      (with-temp-buffer
        (insert html)
        (goto-char (point-min))
        (save-match-data
          (while (re-search-forward "<pre\\(.*?\\)>" nil t 1)

            ;; When the codeblock is a src_block
            (unless
                (save-match-data
                  (setq pre-class (match-string-no-properties 1))
                  (string-match "example" pre-class))
              ;; Replace the <pre...> text
              (setq lang (replace-regexp-in-string ".*src-\\([a-zA-Z0-9]+\\).*" "\\1" pre-class)  )

              (replace-match "")
              (setq code-start (point))

              ;; Go to end of code and remove </pre>
              (re-search-forward "</pre.*?>" nil t 1)
              (replace-match "")
              (setq code-end (point))
              (setq code (buffer-substring-no-properties code-start code-end))

              ;; Delete the code
              (delete-region code-start code-end)
              ;; Stripping out all the code highlighting done by htmlize
              (setq code (replace-regexp-in-string "<.*?>" "" code))

              ;; default is highlight.js, it's the best!
              (insert (concat "\n<pre><code class=\"lang-"
                              lang
                              "\">\n"
                              code
                              "</code></pre>\n"))

              )))

        ;; Get the new html!
        (setq html (buffer-substring-no-properties (point-min) (point-max))))
      ))
  html)

(defun org2html--render-subtree ()
  "Render current subtree"
  (let ((org-directory default-directory)
         html-file
         tags
         title
         post-slug
         html-text)

    ;; set title
    (setq title (nth 4 (org-heading-components)))

    ;; set POST_SLUG if its does not exist
    (setq post-slug (org2html-get-slug title))
    ;; html file
    (setq html-file (concat (file-name-as-directory default-directory) post-slug ".html"))
    (setq html-text (org2html-export-into-html-text))

    (save-excursion
      (setq html-text (org2html-replace-pre html-text)))

    (with-temp-file html-file
      (insert html-text))
    (message "%s created" html-file)
    ))

(defun org2html-export-into-html-text ()
  (let (html-text b e)

    (save-excursion
      (org-mark-element)
      (forward-line) ;; donot export title
      (setq b (region-beginning))
      (setq e (region-end))
      )

    ;; org-export-as will detect active region and narrow to the region
    (save-excursion
      (setq html-text
            (cond
             ((version-list-< (version-to-list (org-version)) '(8 0 0))
              (if (fboundp 'org-export-region-as-html)
                  (org-export-region-as-html b e t 'string)))
             (t
              (if (fboundp 'org-export-as)
                  (org-export-as 'html t nil t)))
             )))
    html-text))

(defun org2html-export-subtree ()
  "Export current first level subtree into HTML"
  (interactive)
  (let ((org-directory default-directory)
        html-file
        tags
        title
        post-slug
        html-text)

    ;; just goto the root element
    (condition-case nil
        (outline-up-heading 8)
      (error
       (message "at the beginning ...")))

    ;; should be nil
    (org2html--render-subtree)
    ))


(defun org2html-wrap-blocks-in-code (src backend info)
  (if (org-export-derived-backend-p backend 'html)
      (org2html-replace-pre src)))

(eval-after-load 'ox
  '(progn
     (add-to-list 'org-export-filter-src-block-functions
                  'org2html-wrap-blocks-in-code)
     ))

;; ORG2BLOG

(setq load-path (cons "~/.emacs.d/org2blog/" load-path))
(require 'org2blog-autoloads)
;;(global-set-key (kbd "C-c o b l") 'org2blog/wp-login)
;;(global-set-key (kbd "C-c o b n") 'org2blog/wp-new-entry)
;;(setq org2blog/wp-blog-alist
;;      '(("wordpress"
;;         :url "https://ryanwhittingham.com/xmlrpc.php"
;;         :username "ryanpwhittingham"
;;         :default-title "Hello World"
;;         :default-categories ("emacs")
;;         :tags-as-categories nil)))

;; ORG-REFILE

(setq org-refile-targets (quote (("~/Dropbox/Emacs/flights.org" :maxlevel . 3)
								 ("~/Dropbox/Emacs/gcal.org" :maxlevel . 3)
								 ("~/Dropbox/Emacs/jobs.org" :maxlevel . 3)
								 ("~/Dropbox/Emacs/notes.org" :maxlevel . 3)
								 ("~/Dropbox/Emacs/archive.org" :maxlevel . 3)
								 ("~/Dropbox/Emacs/todo.org" :maxlevel . 3)
								 ("~/Dropbox/Emacs/chess.org" :maxlevel . 3)
								 ("~/Dropbox/Emacs/stocks.org" :maxlevel . 3))))


(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes 'confirm)

;; Save all Org files after refile
(advice-add 'org-refile :after
			(lambda (&rest _)
			  (org-save-all-org-buffers)))

;; ORG-REVEAL

;;(require 'ox-reveal)
;;(setq Org-Reveal-root "file://~/Dropbox/Emacs/reveal.js/js/reveal.js")
;;(setq Org-Reveal-title-slide nil)

;; ORG-CLOCK
(global-set-key (kbd "C-c C-x C-o") #'org-clock-out)
(global-set-key (kbd "C-c C-x C-x") #'org-clock-in-last)


;; ORG-MRU-CLOCK
;;

;; (require 'org-mru-clock)
;; (global-set-key (kbd "C-c C-x i") #'org-mru-clock-in)
;; (global-set-key (kbd "C-c C-x C-j") #'org-mru-clock-select-recent-task)
;; (setq org-mru-clock-completing-read #'ivy-completing-read)

;; ORG-LINK-MINOR MODE
;;

;; (unless (eq system-type 'windows-nt)
;;   (require 'org-link-minor-mode)
;;   (global-set-key (kbd "C-c o l") 'org-link-minor-mode)
;; 
;;   ;; Various hooks
;;   (add-hook 'ess-mode-hook 'org-link-minor-mode)
;;   (add-hook 'elpy-mode-hook 'org-link-minor-mode)
;;   (add-hook 'ruby-mode-hook 'org-link-minor-mode)
;;   (add-hook 'go-mode-hook 'org-link-minor-mode)
;;   (add-hook 'LaTeX-mode-hook 'org-link-minor-mode)
;;   (add-hook 'Shell-script-mode-hook 'org-link-minor-mode))
;; 


;; FLYSPELL

(defun mk-flyspell-correct-previous (&optional words)
  "Correct word before point, reach distant words.

WORDS words at maximum are traversed backward until misspelled
word is found.  If it's not found, give up.  If argument WORDS is
not specified, traverse 12 words by default.

Return T if misspelled word is found and NIL otherwise.  Never
move point."
  (interactive "P")
  (let* ((Δ (- (point-max) (point)))
         (counter (string-to-number (or words "12")))
         (result
          (catch 'result
            (while (>= counter 0)
              (when (cl-some #'flyspell-overlay-p
                             (overlays-at (point)))
                (flyspell-correct-word-before-point)
                (throw 'result t))
              (backward-word 1)
              (setq counter (1- counter))
              nil))))
    (goto-char (- (point-max) Δ))
    result))

(global-set-key (kbd "C-c s") 'mk-flyspell-correct-previous)

; Use TUI menu, not GUI

(require 'ace-popup-menu)
(ace-popup-menu-mode 1)

;; ACE-WINDOW
;;

(global-set-key (kbd "M-o") 'ace-window)


;; EVIL
;;

(require 'evil)
(global-set-key (kbd "C-c e") 'evil-local-mode)
(setf sentence-end-double-space nil) ;; Change Emacs' definition of a sentence

(global-evil-mc-mode 1)

;; MODE-LINE
;;

(define-minor-mode minor-mode-blackout-mode
  "Hides minor modes from the mode line."
  t)

(catch 'done
  (mapc (lambda (x)
          (when (and (consp x)
                     (equal (cadr x) '("" minor-mode-alist)))
            (let ((original (copy-sequence x)))
              (setcar x 'minor-mode-blackout-mode)
              (setcdr x (list "" original)))
            (throw 'done t)))
        mode-line-modes))

(global-set-key (kbd "C-c m b") 'minor-mode-blackout-mode)

;; NOTMUCH
;;

;; Thunderbird will handle the rlabs maildir -- Symlink to it in ~/Maildir

;; Use this cron:
;; */15 * * * * mbsync gmail && mbsync uf; notmuch new
;; Also: ~/Dropbox/bin/notmuch-config ==> ~/.notmuch-config

(autoload 'notmuch "notmuch" "notmuch mail" t)

(setq notmuch-search-oldest-first nil)
(setq notmuch-hello-logo nil)

(defun my-notmuch-show-mode-config ()
  "For use in `notmuch-show-mode-hook'."
  (local-set-key (kbd "p") 'notmuch-show-previous-message)
  (local-set-key (kbd "n") 'notmuch-show-next-message))

(add-hook 'notmuch-show-mode-hook 'my-notmuch-show-mode-config)

(global-set-key (kbd "C-c n m") 'notmuch-tree)
(global-set-key (kbd "C-c n o") 'notmuch)



;; MU4E
;;

;;(unless (eq system-type 'windows-nt)
;;  (load "~/Dropbox/Emacs/mu4e.el"))

;; PDF-VIEW-MODE
;;

(defun my-pdf-view-mode-config ()
  "For use in `pdf-view-mode-hook'."
  ;; Turn off swiper, use isearch instead
  (local-set-key (kbd "C-s") 'isearch-forward))
;  (local-set-key (kbd "C-c w") 'org-noter-yank)
;  (local-set-key (kbd "C-c o n") 'pdf-to-org-noter)
;  (local-set-key (kbd "C-c m w") 'manuscript-wordcount)
;  (local-set-key (kbd "C-c r f") 'citations-view))

(add-hook 'pdf-view-mode-hook 'my-pdf-view-mode-config)

;; Hydra with my scripts
(defhydra hydra-pdf-view (:color blue) 
  "PDF extras"
  ("o" pdf-to-org-noter "Open notes")
  ("c" citations-view "Get & view references from CrossRef")
  ("s" pdf-view-save-page "Save current page")
  ("l" pdf-view-load-page "Load current page"))


(unless (eq system-type 'windows-nt)(define-key pdf-view-mode-map "x" 'hydra-pdf-view/body)
		(define-key pdf-view-mode-map "h" 'image-backward-hscroll)
		(define-key pdf-view-mode-map "j" 'pdf-view-next-line-or-next-page)
		(define-key pdf-view-mode-map "k" 'pdf-view-previous-line-or-previous-page)
		(define-key pdf-view-mode-map "l" 'image-forward-hscroll))

(defun org-noter-yank ()
  "Send highlighted region of PDF to Org-noter note."
  (interactive)
  (setq inhibit-message t) ;; Avoid annoying messages
  (pdf-view-kill-ring-save-to-file)
  (shell-command (concat "ruby $HOME/Dropbox/Emacs/scripts/quote-process.rb"))
  (setq quote-process
		(file-string "/tmp/quote-process"))
  (kill-new quote-process)
  (org-noter-insert-note-toggle-no-questions)
  (org-yank)
  (fill-paragraph)
  (setq inhibit-message nil))

(defun pdf-view-kill-ring-save-to-file ()
  "Personal function to copy the region to a temporary file. Used
   in conjunction with quote-process.rb for further processing,
   and org-noter-yank."
  (interactive)
  ;; Delete and recreate quote-process file -- we don't want to append.
  (shell-command "rm /tmp/quote-process")
  (shell-command "touch /tmp/quote-process")
  (pdf-view-assert-active-region)
  (let* ((txt (pdf-view-active-region-text)))
    (pdf-view-deactivate-region)
    (write-region
	 (mapconcat 'identity txt "\n") nil "/tmp/quote-process" 'append)))

(defun pdf-to-org-noter ()
  "Use pdf-to-org-noter.rb to make or open an Org-noter file for
   the current document, then open the .org file and attached
   .pdf with Org-noter."
  (interactive)
  ;; Run Ruby script.
  (shell-command
   (concat "ruby $HOME/Dropbox/Emacs/scripts/pdf-to-org-noter.rb " "'"buffer-file-name"'"))
  ;; Load .org file path returned by Ruby script.
  (setq org-noter-path
		(file-string "~/Dropbox/Emacs/scripts/.pdf-to-org-noter"))
  ;; Launch Org-noter unless Ruby script failed to find a matching
  ;; BibTeX key.
  (unless (string= org-noter-path "Exit code 1.")
	(find-file org-noter-path)
	(delete-other-windows)
	(end-of-buffer)
	(org-noter)))

(defun manuscript-wordcount ()
  "Get wordcount of a personal manuscript."
  (interactive)
  (shell-command
   (concat "ruby ~/Dropbox/bin/manuscript-wordcount.rb "
		   buffer-file-name)))

(defun citations-sentinel (process event)
  "Process sentinel for citations-view."
  (message event)
  (cond ((string-match-p "finished" event)
		 (progn
		   (kill-buffer "*async citations.py*")
		   (setq citations-py-exit-code
				 (file-string "/tmp/.citations-py-exit-code"))
		   (if (string= citations-py-exit-code "0")
			   (progn
				 (setq bibtex-completion-bibliography "/tmp/citations_with_file.bib")
				 ;; Allow quitting as normal for ivy-bibtex 
				 (with-local-quit (ivy-bibtex)))
			 (message "No references found through CrossRef."))
		   ;; Reset bibliography after if/else block.
		   (setq bibtex-completion-bibliography "~/Dropbox/Emacs/library.bib")))))

(defun citations-view ()
  "Run citations.py on current file."
  (interactive)
  (let* ((file-name (shell-quote-argument (buffer-file-name)))
		 (process
		  (start-process-shell-command
		   "citations.py"
		   "*async citations.py*"
		   (concat "python3 ~/Dropbox/Emacs/scripts/citations.py "
				   "\""buffer-file-name"\""))))
	(set-process-sentinel process 'citations-sentinel)))

(defun pdf-view-save-page ()
  "Save the current page number for the document."
  (interactive)
  (let ((pdf-view-page-no (number-to-string (pdf-view-current-page))))
  (shell-command
   (concat "$HOME/Dropbox/Emacs/scripts/pdf-view-save.py "
		   pdf-view-page-no " \""buffer-file-name"\" " "save"))))

(defun pdf-view-load-page ()
  "Load the saved page number for the document."
  (interactive)
  ;; .py scripts wants three arguments, so we'll send 0 as a fake page
  ;; number.
  (shell-command
   (concat "$HOME/Dropbox/Emacs/scripts/pdf-view-save.py "
		   "0" " \""buffer-file-name"\" " "load"))
  (let ((pdf-view-saved-page-no
		(string-to-number
		 (file-string "/tmp/pdf-view-save"))))
	(if (= pdf-view-saved-page-no -1)
		(message "No saved page number.")
	  (pdf-view-goto-page pdf-view-saved-page-no))))
	

;; DOC-VIEW-MODE
;;

(defun my-doc-view-mode-config ()
  "For use in `doc-view-mode-hook'."
  (local-set-key (kbd "o") 'wps-open)
   local-set-key (kbd "C-c on") 'pdf-to-org-noter)

(add-hook 'doc-view-mode-hook 'my-doc-view-mode-config)

(defun wps-open ()
  "Open a Docview buffer with WPS writer."
  (interactive)
  (async-shell-command (concat "wps " buffer-file-name)))
  
(setq doc-view-continuous t)

;; COMPANY
;;

(require 'color)

(add-hook 'after-init-hook 'global-company-mode)

;; change colors
(defun company-colors ()
  (let ((bg (face-attribute 'default :background)))
	(custom-set-faces
	 `(company-tooltip ((t (:inherit default :background ,(color-lighten-name bg 2)))))
	 `(company-scrollbar-bg ((t (:background ,(color-lighten-name bg 10)))))
	 `(company-scrollbar-fg ((t (:background ,(color-lighten-name bg 5)))))
	 `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
	 `(company-tooltip-common ((t (:inherit font-lock-constant-face)))))))


;; RECENTF
;;

; gets rid of some unecessary files for recent files
(setq recentf-exclude '("^/var/folders\\.*"
                        "COMMIT_EDITMSG\\'"
                        ".*-autoloads\\.el\\'"
                        "[/\\]\\.elpa/"
						"/.emacs.d/"
						"/.elfeed/"))

(recentf-mode 1)
(setq recentf-max-menu-items 100)
(setq recentf-max-saved-items 10000)
(run-with-timer 0 (* 30 60) 'recentf-save-list)

(global-set-key (kbd "C-c o r") 'counsel-recentf)


;; UNDO-TREE
;;

(global-undo-tree-mode 1) ;; undo-tree
(global-set-key (kbd "C-z") 'undo) ;; make ctrl-z undo
(defalias 'redo 'undo-tree-redo) ;; make ctrl-Z redo
(global-set-key (kbd "C-S-z") 'redo)


;; IDO
;;

(ido-mode 1) ;; ido
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)


;; OPENWITH
;;

;(setq openwith-associations '(("\\.pdf\\'" "zathura" (file))
;			      ("\\.epub\\'" "ebook-viewer" (file))
;			      ("\\.doc\\'" "wps" (file))
;			      ("\\.docx\'" "wps" (file))
;			      ("\\.csv\\'" "et" (file))
;			      ))

;; titlecase.el --- convert text to title case
;; Copyright (C) 2013 Jason R. Blevins <jrblevin@sdf.org>
;; All rights reserved.
;; Requires titlecase perl script in /usr/bin

;; ORG-BABEL
;;

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . nil)
   (R . t)
   (python . t)
   (shell . t)
   (ruby . t)
   ))

(setq org-confirm-babel-evaluate nil)

;; MAGIT
;;

(global-set-key (kbd "C-x g") 'magit-status)
(setq magit-diff-hide-trailing-cr-characters t)

(global-set-key (kbd "C-c m f") 'magit-find-file)
(global-set-key (kbd "C-c m l") 'magit-log-buffer-file)

;; GIT-TIMEMACHINE
(global-set-key (kbd "C-c t m") 'git-timemachine)

;; SMERGE
(global-set-key (kbd "C-c k c") 'smerge-keep-current)

;; Fix colors in terminal
(custom-set-faces
 ;; other faces
 '(magit-diff-added ((((type tty)) (:foreground "green"))))
 '(magit-diff-added-highlight ((((type tty)) (:foreground "LimeGreen"))))
 '(magit-diff-context-highlight ((((type tty)) (:foreground "default"))))
 '(magit-diff-file-heading ((((type tty)) nil)))
 '(magit-diff-removed ((((type tty)) (:foreground "red"))))
 '(magit-diff-removed-highlight ((((type tty)) (:foreground "IndianRed"))))
 '(magit-section-highlight ((((type tty)) nil))))


;; ELFEED
;;

;; eww / browser stuff
;;(setq browse-url-browser-function 'eww-browse-url)

;; (advice-add 'url-http-user-agent-string :around
;;             (lambda (ignored)
;;               "Pretend to be a mobile browser."
;;               (concat
;;                "User-Agent: "
;;                "Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30")))

;;(defun elfeed-show-visit-gui ()
;;  "Wrapper for elfeed-show-visit to use gui browser instead of eww"
;;  (interactive)
;;  (let ((browse-url-generic-program "/usr/bin/xdg-open"))
;;    (elfeed-show-visit t)))
;;
;;(define-key elfeed-show-mode-map (kbd "B") 'elfeed-show-visit-gui)


(setq elfeed-feeds nil) ;; Using elfeed-org instead

(setq-default elfeed-search-filter "@1-week-ago +unread ")

;; Format
(setq elfeed-search-title-min-width 65)
(setq elfeed-search-trailing-width 20)

;; Load elfeed-org
(require 'elfeed-org)
(elfeed-org)
(setq rmh-elfeed-org-files (list "~/Dropbox/Emacs/elfeed.org"))

;; automatic tags
(add-hook 'elfeed-new-entry-hook
          (elfeed-make-tagger :feed-url "reddit\\.com"
                              :add '(reddit)))

(global-set-key (kbd "C-x e") 'elfeed)

;; add extra keys to elfeed-search-mode
(defun my-elfeed-search-mode-config ()
  "For use in `elfeed-search-mode-hook'."
  (local-set-key (kbd "w") 'elfeed-eww-open) ;; Command in keyboard macros
  ;(local-set-key (kbd "q") 'my-elfeed-save-db-and-bury)
  )

(add-hook 'elfeed-search-mode-hook 'my-elfeed-search-mode-config)

;; Custom Elfeed commands
(defun elfeed-send-to-pocket ()
  "Send Elfeed entry to Pocket using email."
  (interactive )
  ;; Write buffer to file
  (write-region (point-min) (point-max) "~/Dropbox/Emacs/.elfeed-entry-to-pocket")
  ;; Parse URL with .py script
  (shell-command (concat "python3 $HOME/Dropbox/Emacs/scripts/elfeed-to-pocket.py"))
  (message "Sending to Pocket ...")
  ;; tr -d allows sending of email without subject line for msmtp
  (shell-command (concat "tr -d ':' < $HOME/Dropbox/Emacs/.elfeed-entry-to-pocket | msmtp add@getpocket.com"))
  (message "Saved to Pocket."))

(defun elfeed-reddit-send-to-pocket ()
  "Send Reddit link from Elfeed entry to Pocket using email."
  (interactive )
  ;; Write buffer to file
  (write-region (point-min) (point-max) "~/Dropbox/Emacs/.elfeed-reddit-entry-to-pocket")
  ;; Parse URL with .py script
  (message "Running elfeed-reddit-to-pocket.py ...")
  (shell-command (concat "python3 $HOME/Dropbox/Emacs/scripts/elfeed-reddit-to-pocket.py"))
  ;; Get exit message from elfeed-reddit-to-pocket.py
  (setq elfeed-reddit-code
		(file-string "~/Dropbox/Emacs/scripts/.elfeed-reddit-exit"))
  ;; Test if exit message is 'Saved URL, use msmtp if so.
  (when (string= elfeed-reddit-code "Saved URL.")
	(message "Sending to Pocket ...")
	(shell-command (concat "tr -d ':' < $HOME/Dropbox/Emacs/.elfeed-reddit-entry-to-pocket | msmtp add@getpocket.com"))
	(message "Saved to Pocket."))
  ;; Otherwise, print error message from elfeed-reddit-to-pocket.py.
  (unless (string= elfeed-reddit-code "Saved URL.")
	(message elfeed-reddit-code)))

(defun elfeed-pdf ()
  "Download a journal article PDF and BibTeX info from an associated Elfeed entry."
  (interactive)
  ;; Write buffer to file
  (write-region (point-min) (point-max) "~/Dropbox/Emacs/.elfeed-pdf")
  ;; Parse out URL from buffer with .py script, download PDF and BibTeX entry.
  (message "Running elfeed-pdf.py ...")
  (shell-command (concat "python3 $HOME/Dropbox/Emacs/scripts/elfeed-pdf.py"))
  ;; Read and print exit message of .py script.
  (setq elfeed-pdf-msg
		(file-string "/tmp/.elfeed-pdf-exit-msg"))
  (message elfeed-pdf-msg))

(defun elfeed-pdf-open ()
  "Download a journal article with elfeed-pdf, then open."
  (interactive)
  ;; Write buffer to file
  (write-region (point-min) (point-max) "~/Dropbox/Emacs/.elfeed-pdf")
  ;; Parse out URL from buffer with .py script, download PDF and BibTeX entry.
  (message "Running elfeed-pdf.py ...")
  (shell-command (concat "python3 $HOME/Dropbox/Emacs/scripts/elfeed-pdf.py"))
  ;; Read and print exit message of .py script.
  (setq elfeed-pdf-msg
		(file-string "/tmp/.elfeed-pdf-exit-msg"))
  (message elfeed-pdf-msg)
  ;; Check exit code, then run Ruby script if elfeed-pdf.py had a good exit.
  (setq elfeed-pdf-code
		(file-string "/tmp/.elfeed-pdf-exit-code"))
  (unless (string= elfeed-pdf-code "1")
	(setq elfeed-pdf-path
		  (file-string "/tmp/elfeed-pdf-path"))
	(shell-command
	 (concat "ruby $HOME/Dropbox/Emacs/scripts/pdf-to-org-noter.rb " elfeed-pdf-path))
	;; Load .org file path returned by Ruby script.
	(setq org-noter-path
		  (file-string "~/Dropbox/Emacs/scripts/.pdf-to-org-noter"))
	;; Launch Org-noter unless Ruby script failed to find a matching
	;; BibTeX key.
	(unless (string= org-noter-path "Exit code 1.")
	  (find-file org-noter-path)
	  (delete-other-windows)
	  (end-of-buffer)
	  (org-noter))))
	 
;(defun my-elfeed-show-mode-config ()
;  "For use in `elfeed-show-mode-hook'."
;  (local-set-key (kbd "x") 'elfeed-send-to-pocket)
;  (local-set-key (kbd "z") 'elfeed-pdf)
;  (local-set-key (kbd "r") 'elfeed-reddit-send-to-pocket)
;  )

;(add-hook 'elfeed-show-mode-hook 'my-elfeed-show-mode-config)

;; Hydra with my scripts
(defhydra hydra-elfeed-show (:color blue) 
  "Elfeed extras"
  ("p" elfeed-send-to-pocket "Send to Pocket")
  ("r" elfeed-reddit-send-to-pocket "Send Reddit link to Pocket")
  ("j" elfeed-pdf "Download journal article")
  ("o" elfeed-pdf-open "Download journal article and open"))

(define-key elfeed-show-mode-map "h" 'hydra-elfeed-show/body)

;; REALGUD
;;

;; MATLAB
;;

(autoload 'matlab-mode "matlab" "Matlab Editing Mode" t)
(add-to-list
 'auto-mode-alist
 '("\\.m$" . matlab-mode))
(setq matlab-indent-function t)
(setq matlab-shell-command "~.local/MATLAB/bin/matlab")
(setq matlab-shell-command-switches (list "-nodesktop" "-nosplash"))

;; JSON
;;

(setq jq-format-sort-keys nil)
(setq jq-format-json-on-save-mode t)

(defun my-json-mode-config ()
  "For use in `Json-mode-hook'."
  (local-set-key (kbd "C-c C-c") 'jq-format-json-buffer)
  )

(add-hook 'json-mode-hook 'my-json-mode-config)



;; PYTHON
;;

;; Using Palantir's LSP even though deprecated -- Just works, but the
;; fork doesn't for me
(setq lsp-pyls-disable-warning t)

;; Load elpy commands but don't use elpy in Python buffers
(elpy-enable)
(elpy-disable)

(setq python-shell-interpreter "python3")

(add-hook 'python-mode-hook #'lsp)

(require 'py-yapf)
(add-hook 'python-mode-hook 'py-yapf-enable-on-save)
;(remove-hook 'python-mode-hook 'py-yapf-enable-on-save)
;(add-hook 'python-mode-hook 'flycheck-mode)

(setq pydoc-command "python3 -m pydoc")

(defun my-python-mode-config ()
  "For use in `python-mode-hook'."
  (local-set-key (kbd "<C-return>") 'elpy-shell-send-statement-and-step)
  (local-set-key (kbd "C-c p d") 'realgud:pdb))

(setq realgud-window-split-orientation 'horizontal)

(add-hook 'python-mode-hook 'my-python-mode-config)

;; ELIXIR
;;

(add-hook 'elixir-mode-hook #'lsp)

(add-hook 'elixir-mode-hook
          (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))

;; JAVA
;;

(require 'cc-mode)

(defun google-java-format-buffer ()
  "Format buffer using google-java-format"
  (interactive)
  (shell-command (format "google-java-format -i %s" buffer-file-name)))

(defun my-java-mode-config ()
  "For use in `java-mode-hook'."
  (local-set-key (kbd "C-c C-f") 'google-java-format-buffer))

(add-hook 'java-mode-hook 'my-java-mode-config)

(add-hook 'java-mode-hook
		  (lambda () (add-hook 'before-save-hook 'google-java-format-format-buffer nil t)))

(defun my-java-mode-before-save-hook ()
  (when (eq major-mode 'java-mode)
    (google-java-format-buffer)))

(require 'lsp-java)
(add-hook 'java-mode-hook #'lsp)

;;(require 'eclim)
;;(setq eclim-executable "/usr/lib/eclipse/eclim")
;;(setq eclimd-executable "/usr/lib/eclipse/eclimd")
;;
;;(add-hook 'java-mode-hook 'eclim-mode)
;;(define-key eclim-mode-map (kbd "C-c C-c") 'eclim-problems-correct)
;;
;;(require 'gradle-mode)
;;(add-hook 'java-mode-hook '(lambda() (gradle-mode 1)))
;;
;;(require 'company-emacs-eclim)
;;(company-emacs-eclim-setup)



;; JAVASCRIPT
;;

(setq flycheck-javascript-standard-executable "/usr/bin/eslint")

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . rjsx-mode))

;; Better imenu
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)

(add-hook 'js2-mode-hook #'js2-refactor-mode)
(js2r-add-keybindings-with-prefix "C-c C-r")
(define-key js2-mode-map (kbd "C-k") #'js2r-kill)

;; js-mode (which js2 is based on) binds "M-." which conflicts with xref, so
;; unbind it.
(define-key js-mode-map (kbd "M-.") nil)

(add-hook 'js2-mode-hook (lambda ()
  (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)))

;; prettier
(add-hook 'js-jsx-mode-hook 'prettier-js-mode)
(add-hook 'rjsx-mode-hook 'prettier-js-mode)
(add-hook 'js2-mode-hook 'prettier-js-mode)

(add-hook 'js2-mode-hook #'lsp)

;; tide
(defun setup-tide-mode ()
  "Setup function for tide."
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

(setq company-tooltip-align-annotations t)

(add-hook 'js-mode-hook #'setup-tide-mode)
(add-hook 'js2-mode-hook #'setup-tide-mode)
(add-hook 'rsjx-mode-hook #'setup-tide-mode)

;; jslint
;(add-hook 'js2-mode-hook 'flymake-jslint-load)

;; ASM

(add-to-list 'auto-mode-alist '("\\.asm\\'" . nasm-mode))

;; C / C++

(require 'clang-format)

(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)

(setq c-default-style "stroustrup"
	  c-basic-offset 4)

(defun my-c++-mode-config ()
  "For use in `c++-mode-hook'."
  (local-set-key (kbd "C-c C-f") 'clang-format-buffer)
  (setq clang-format-style "{BasedOnStyle: google, IndentWidth: 4, SortIncludes: false}"))

(add-hook 'c++-mode-hook 'my-c++-mode-config)
(add-hook 'c++-mode-hook 'flycheck-mode)

(defun my-c-mode-config ()
  "For use in `c-mode-hook'."
  (local-set-key (kbd "C-c C-f") 'clang-format-buffer)
  (setq clang-format-style "{BasedOnStyle: google, IndentWidth: 4, SortIncludes: false}"))

(add-hook 'c-mode-hook 'my-c-mode-config)
(add-hook 'c-mode-hook 'flycheck-mode)

(defun my-arduino-mode-config ()
  "For use in `arduino-mode-hook'."
  (local-set-key (kbd "C-c C-f") 'clang-format-buffer)
  (setq clang-format-style "{BasedOnStyle: google, IndentWidth: 4, SortIncludes: false}"))

(add-hook 'arduino-mode-hook 'my-arduino-mode-config)

(with-eval-after-load 'flycheck
  (require 'flycheck-clang-analyzer)
  (flycheck-clang-analyzer-setup))

;;(eval-after-load 'flycheck
;;  '(add-hook 'flycheck-mode-hook #'flycheck-clang-tidy-setup))

;; SWIG
(require 'swig-mode)
(add-to-list 'auto-mode-alist '("\\.i$" . swig-mode))

;; GO
;;

(add-hook 'go-mode-hook
		  (lambda () (add-hook 'before-save-hook
							   'gofmt-before-save nil 'local)))
(exec-path-from-shell-copy-env "GOPATH")

;;(add-to-list 'load-path (concat (getenv "GOPATH") "/golang.org/x/lint/misc/emacs"))
;;(add-to-list 'load-path (concat (getenv "GOPATH") "/src/golang.org/x/lint/misc/emacs"))

(unless (eq system-type 'windows-nt)
  (require 'golint)) ;; Must be in load-path

(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection "go-langserver")
                  :activation-fn (lsp-activate-on "go")
                  :server-id 'go-langserver))


(add-hook 'go-mode-hook #'lsp)



;;(add-hook 'go-mode-hook 'flycheck-mode)
;;(add-hook 'go-mode-hook #'gorepl-mode)


;; RUBY
;;

(add-to-list 'auto-mode-alist '("\\.rb$" . enh-ruby-mode))
(autoload 'inf-ruby-minor-mode "inf-ruby" "Run an inferior Ruby process" t)
(add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode)

(add-hook 'ruby-mode-hook
          (lambda () (local-set-key (kbd "C-<return>") #'ruby-send-line-and-step)))

(add-hook 'ruby-mode-hook
          (lambda () (local-set-key (kbd "C-c r f") 'rubocopfmt)))

(add-hook 'ruby-mode-hook 'flycheck-mode)

(setq rubocopfmt-use-bundler-when-possible nil)

(defun ruby-send-line-and-step ()
  (interactive)
  (ruby-send-line)
  (next-line))

(defun inf-ruby-or-ruby-send-line-and-step ()
  "Send the current line or open an inferior Ruby process."
  (interactive)
  ;; Check value of inf-ruby-buffer
  (if inf-ruby-buffer
	  ('ruby-send-line-and-step)
	'inf-ruby))

;; Auto-format with rubocop on save
(defun my-enh-ruby-mode-before-save-hook ()
  (when (eq major-mode 'enh-ruby-mode)
    (rubocopfmt)))

(add-hook 'before-save-hook #'my-enh-ruby-mode-before-save-hook)

;; SCALA
(add-to-list 'auto-mode-alist '("\\.sc$" . scala-mode))

(use-package scala-mode
  :interpreter
  ("scala" . scala-mode))

(use-package lsp-metals)

(add-hook 'scala-mode-hook 'format-all-mode)
(add-hook 'scala-mode-hook #'lsp)
(add-hook 'scala-mode-hook 'flycheck-mode)

(setq flycheck-scalastylerc "~/Dropbox/bin/scalastyle.xml")

;; Enable sbt mode for executing sbt commands
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false"))
)

(defun my-scala-mode-config ()
  "For use in `scala-mode-hook'."
  (local-set-key (kbd "C-c s s") 'sbt-start))

(add-hook 'scala-mode-hook 'my-scala-mode-config)

;; RUST
;;

(require 'rustic)
(add-hook 'rustic-mode-hook
          (lambda () (setq indent-tabs-mode nil)))

(add-to-list 'auto-mode-alist '("\\.rs$" . rustic-mode))
;; (setq rustic-format-on-save t)

(with-eval-after-load 'rustic-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;; rustfmt -- See: https://github.com/fbergroth/emacs-rustfmt/blob/master/rustfmt.el
(defcustom rustfmt-bin "rustfmt"
  "Path to rustfmt executable."
  :type 'string)

(defcustom rustfmt-popup-errors nil
  "Display error buffer when rustfmt fails."
  :type 'boolean)

(defun rustfmt--call (buf)
  "Format BUF using rustfmt."
  (with-current-buffer (get-buffer-create "*rustfmt*")
    (erase-buffer)
    (insert-buffer-substring buf)
    (if (zerop (call-process-region (point-min) (point-max) rustfmt-bin t t nil))
        (progn (copy-to-buffer buf (point-min) (point-max))
               (kill-buffer))
      (when rustfmt-popup-errors
        (display-buffer (current-buffer)))
      (error "Rustfmt failed, see *rustfmt* buffer for details"))))

(defun rustfmt-format-buffer ()
  "Format the current buffer using rustfmt."
  (interactive)
  (unless (executable-find rustfmt-bin)
    (error "Could not locate executable \"%s\"" rustfmt-bin))

  (let ((cur-point (point))
        (cur-win-start (window-start)))
    (rustfmt--call (current-buffer))
    (goto-char cur-point)
    (set-window-start (selected-window) cur-win-start))
  (message "Formatted buffer with rustfmt."))

(defun rustfmt-enable-on-save ()
  "Run rustfmt when saving buffer."
  (interactive)
  (add-hook 'before-save-hook #'rustfmt-format-buffer nil t))

(define-key rustic-mode-map (kbd "C-c C-f") #'rustfmt-format-buffer)

(defun my-rustic-mode-before-save-hook ()
  (when (eq major-mode 'rustic-mode)
    (rustfmt-format-buffer)))

(add-hook 'before-save-hook #'my-rustic-mode-before-save-hook)

;; ESS 
;;

(defun unstick-ansi-color-codes ()
  (interactive)
  (end-of-buffer)
  (insert "echo -e \"\033[m\"")
  (comint-send-input nil t))

;;(setq explicit-shell-file-name "/bin/bash")

;; turn off default indenting of R '#' comments
(setq ess-fancy-comments nil)
(require 'ess)

(eval-after-load "ess-mode" '(define-key ess-mode-map (kbd "C-RET") 'ess-eval-line-and-step))
(add-hook 'ess-mode-hook 'flycheck-mode) ;; lintr (syntax checker -- requires lintr package in R)
(add-hook 'ess-mode-hook (lambda () (add-hook
'before-save-hook 'delete-trailing-whitespace nil 'local)))

(defun ess-styler ()
  (interactive)
  (setq r-buffer-filename buffer-file-name)
  (shell-command (concat "/usr/local/bin/styler " r-buffer-filename)))

(defun my-ess-mode-config ()
  "For use in `ess-mode-hook'."
  (local-set-key (kbd "C-c r s") 'format-all-buffer))

(add-hook 'ess-mode-hook 'my-ess-mode-config)

(setq ess-indent-offset '2)


;; JAGS-mode
(require 'ess-jags-d)

;; command history
(add-hook 'inferior-ess-mode-hook
    '(lambda nil
          (define-key inferior-ess-mode-map [\C-up]
			'comint-previous-matching-input-from-input)
          (define-key inferior-ess-mode-map [\C-down]
	    'comint-next-matching-input-from-input)))

;; ESS-VIEW
(require 'ess-view)
(setq ess-view--spreadsheet-program "/usr/bin/et") ;; Use WPS spreadsheet


;; SHELL
;;

;; (setq explicit-shell-file-name "/bin/zsh")

(global-set-key (kbd "C-t") 'shell)
(global-set-key (kbd "C-c C-t") 'vterm-other-window)

(defun my-sh-mode-config ()
  "For use in `sh-mode-hook'."
  (local-set-key (kbd "C-c b s") 'format-all-buffer))

(add-hook 'sh-mode-hook 'my-sh-mode-config)

;; Emacs Speaks Shell

(unless (eq system-type 'windows-nt)
  (require 'essh)
  (defun essh-sh-hook ()
	(define-key sh-mode-map "\C-c\C-r" 'pipe-region-to-shell)
	(define-key sh-mode-map "\C-c\C-b" 'pipe-buffer-to-shell)
	(define-key sh-mode-map "\C-c\C-j" 'pipe-line-to-shell)
	(define-key sh-mode-map "\C-c\C-n" 'pipe-line-to-shell-and-step)
	(define-key sh-mode-map (kbd "<C-return>") 'pipe-line-to-shell-and-step)
	(define-key sh-mode-map "\C-c\C-f" 'pipe-function-to-shell)
	(define-key sh-mode-map "\C-c\C-d" 'shell-cd-current-directory))
  (add-hook 'sh-mode-hook 'essh-sh-hook))


;; ARDUINO
;;

(add-to-list 'auto-mode-alist '("\\.ino\\'" . c-mode))


;; TOGGLE WINDOW
;; 

(defun window-split-toggle ()
  "Toggle between horizontal and vertical split with two windows."
  (interactive)
  (if (> (length (window-list)) 2)
      (error "Can't toggle with more than 2 windows!")
    (let ((func (if (window-full-height-p)
                    #'split-window-vertically
                  #'split-window-horizontally)))
      (delete-other-windows)
      (funcall func)
      (save-selected-window
        (other-window 1)
        (switch-to-buffer (other-buffer))))))

(global-set-key (kbd "C-x t") 'window-split-toggle)


;; TRANSPOSE WINDOWS
;;

;;Source: https://www.emacswiki.org/emacs/TransposeWindows

 (defun transpose-windows (arg)
   "Transpose the buffers shown in two windows."
   (interactive "p")
   (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
     (while (/= arg 0)
       (let ((this-win (window-buffer))
             (next-win (window-buffer (funcall selector))))
         (set-window-buffer (selected-window) next-win)
         (set-window-buffer (funcall selector) this-win)
         (select-window (funcall selector)))
       (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

(global-set-key (kbd "C-x y") 'transpose-windows)
 

;; FILL COLUMN INDICATOR
;;

(add-hook 'c++-mode-hook 'fci-mode)
(add-hook 'c-mode-hook 'fci-mode)
(add-hook 'ess-mode-hook 'fci-mode)
(add-hook 'org-mode-hook 'fci-mode)
(add-hook 'LaTeX-mode-hook 'fci-mode)
(add-hook 'go-mode-hook 'fci-mode)
(add-hook 'java-mode-hook 'fci-mode)
(add-hook 'nasm-mode-hook 'fci-mode)
(add-hook 'python-mode-hook 'fci-mode)
(add-hook 'ruby-mode-hook 'fci-mode)
(add-hook 'rust-mode-hook 'fci-mode)
(add-hook 'scala-mode-hook 'fci-mode)
(add-hook 'sh-mode-hook 'fci-mode)

;; conflict with company
(defvar-local company-fci-mode-on-p nil)

 (defun company-turn-off-fci (&rest ignore)
   (when (boundp 'fci-mode)
     (setq company-fci-mode-on-p fci-mode)
     (when fci-mode (fci-mode -1))))

 (defun company-maybe-turn-on-fci (&rest ignore)
   (when company-fci-mode-on-p (fci-mode 1)))

 (add-hook 'company-completion-started-hook 'company-turn-off-fci)
 (add-hook 'company-completion-finished-hook 'company-maybe-turn-on-fci)
 (add-hook 'company-completion-cancelled-hook 'company-maybe-turn-on-fci)


;; RIPGREP
;;

(global-set-key (kbd "C-c r g") 'rg)
(global-set-key (kbd "C-c p r g") 'projectile-ripgrep)


;; AUCTEX
;;

(add-hook 'TeX-mode-hook #'TeX-fold-mode) ;; Automatically activate TeX-fold-mode.
(add-hook 'LaTeX-mode-hook #'outline-minor-mode)
(add-hook 'LaTeX-mode-hook 'turn-on-flyspell 'append)

;; Turn off subscript/superscript WYSIWYG stuff
(setq font-latex-fontify-script nil)

;; MARKDOWN
;;

(add-hook 'markdown-mode-hook 'flyspell-mode)


;; OUTLINE-MINOR-MODE & OUTLINE-MAGIC
;;

;; (global-unset-key "\C-o")
;; (add-hook 'outline-minor-mode-hook
;; 		  (lambda ()
;; 			(local-set-key "\C-o" outline-mode-prefix-map)))
;; 
;; (eval-after-load 'outline
;;   '(progn
;;     (require 'outline-magic)
;;     (define-key outline-minor-mode-map (kbd "<C-tab>") 'outline-cycle)))


;; REFTEX
;;

(add-hook 'LaTeX-mode-hook 'turn-on-reftex) ;; Turn on RefTeX in AUCTeX

(setq reftex-plug-into-AUCTeX t) ;; Activate nice interface between RefTeX and AUCTeX

(setq reftex-default-bibliography ;; Default library
      '("~/Dropbox/Emacs/library.bib"))


;; YASNIPPET
;;

(setq yas-snippet-dirs '("~/Dropbox/Emacs/Snippets/" yasnippet-snippets-dir))
                
;;(yas-recompile-all)
;;(yas-reload-all)
(yas-global-mode 1)

(use-package yasnippet-radical-snippets
  :ensure t
  :after yasnippet
  :config
  (yasnippet-radical-snippets-initialize))


;; TRAMP
;;

(defun rw-ssh ()
  "Quickly access ryanwhittingham.com."
  (interactive)
  (find-file "/ssh:ryanw@ryanwhittingham.com:"))

(global-set-key (kbd "C-c r w") 'rw-ssh)

(defun rw-hp ()
  "Quickly access ryan-hp."
  (interactive)
  (find-file "/ssh:ryanw@192.168.1.5:"))

(global-set-key (kbd "C-c h p") 'rw-hp)

(defun edit-current-file-as-root ()
  "Edit the file that is associated with the current buffer as root"
  (interactive)
  (let ((filep (buffer-file-name)))
    (if filep (find-file (concat "/sudo::" filep))
      (message "Current buffer does not have an associated file."))))

;; IY-GO-TO-CHAR
;;

;(add-to-list 'mc/cursor-specific-vars 'iy-go-to-char-start-pos)
;(global-set-key (kbd "C-c f") 'iy-go-up-to-char)
;(global-set-key (kbd "C-c F") 'iy-go-up-to-char-backward)


;; RANGER-MODE
;;

;;(global-set-key (kbd "C-c r m") 'ranger)


;; SMOOTH-SCROLLING
;;

(require 'smooth-scrolling)
(smooth-scrolling-mode 1)
(setq smooth-scroll-margin 5)

;; ASANA
;;

;;(setq asana-token (shell-command-to-string "gopass show -o misc/todo-sync"))
;;(setq global-asana-mode 1)

;; DOCKERFILE

(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

;; PROJECTILE
;;

;; Just add directories with .projectile
(setq projectile-project-root-files #'(".projectile"))
(projectile-global-mode t)


;; WTTRIN
;;

;(setq wttrin-default-cities '("San Jose, California"))
;(setq wttrin-default-accept-language '("Accept-Language" . "en-US"))

;; EMACS SERVER
;;

(unless (and (fboundp 'server-running-p)
             (server-running-p))
  (server-start))

;; Different commands for TTY vs. GUI
(defun contextual-menubar (&optional frame)
  "Display the menubar in FRAME (default: selected frame) if on a
    graphical display, but hide it if in terminal."
  (interactive)
  (set-frame-parameter frame 'menu-bar-lines 
                             (if (display-graphic-p frame)
								 1 0)))

(add-hook 'after-make-frame-functions 'contextual-menubar)

;; Load material for GUI only
(defvar my:theme 'material)
(defvar my:theme-window-loaded nil)
(defvar my:theme-terminal-loaded nil)

(if (daemonp)
    (add-hook 'after-make-frame-functions(lambda (frame)
                       (select-frame frame)
                       (if (window-system frame)
                           (unless my:theme-window-loaded
                             (if my:theme-terminal-loaded
                                 (enable-theme my:theme)
                               (load-theme my:theme t))
                             (setq my:theme-window-loaded t))
                         (unless my:theme-terminal-loaded
                           (if my:theme-window-loaded
                               (enable-theme my:theme)
                             (load-theme my:theme t))
                           (setq my:theme-terminal-loaded t)))))

  (progn
    (load-theme my:theme t)
    (if (display-graphic-p)
        (setq my:theme-window-loaded t)
      (setq my:theme-terminal-loaded t))))

;; SSH-AGENT
;(require 'exec-path-from-shell)
;(exec-path-from-shell-copy-env "SSH_AGENT_PID")
;(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")


;; My personally written commands end here
;;

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "PfEd" :slant normal :weight normal :height 111 :width normal)))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("b9cbfb43711effa2e0a7fbc99d5e7522d8d8c1c151a3194a4b176ec17c9a8215" "9a155066ec746201156bb39f7518c1828a73d67742e11271e4f24b7b178c4710" "a24c5b3c12d147da6cef80938dca1223b7c7f70f2f382b26308eba014dc4833a" "e11569fd7e31321a33358ee4b232c2d3cf05caccd90f896e1df6cab228191109" default)))
 '(package-selected-packages
   (quote
    (alert pydoc markdown-mode magit evil-mc evil-multiedit
    elfeed-web stan-mode dash academic-phrases
    exec-path-from-shell gorepl-mode hydra inf-ruby rubocopfmt
    enh-ruby-mode w3m go-mode ranger iy-go-to-char rg
    ace-popup-window org-link-minor-mode wttrUin ace-window
    oultine-magic org-ref org-noter elfeed-org dashboard
    page-break-lines evil elfeed slirm rainbow-delimiters
    gscholar-bibtex henlm-bibtex dired-sidebar undo-tree
    py-autopep8 multiple-cursors material-theme leuven-theme
    flycheck fill-column-indicator ess elpy buffer-move bind-key
    better-defaults auctex swiper smooth-scrolling calfw
    calfw-org ace-popup-menu projectile org-link-minor-mode
    ivy-bibtex inf-ruby helm-org-rifle go-mode ess-view
    enh-ruby-mode counsel-projectile counsel auth-source-pass
    wc-mode mu4e-alert org-gcal package-utils swiper projectile
    org-link-minor-mode mu4e-alert markdown-mode inf-ruby
    helm-org-rifle ivy-bibtex go-mode counsel-projectile counsel
    calfw-org calfw ace-popup-menu academic-phrases
    smooth-scrolling rubocopfmt package-utils inf-ruby ht
    magit-popup enh-ruby-mode wttrin outline-magic rust-mode
    cargo json-mode jq-format clang-format vterm yaml-mode))))
