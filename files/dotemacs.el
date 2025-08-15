;; --- Emacs config ---

;; --- Basic customization ---
;; 1. Load the package library. This defines all package-related symbols.
(require 'package)

;; Ensure package system is ready (usually in main init, but doesn't hurt here)
(setq package-enable-at-startup nil)

;; Add MELPA Stable if you prefer more stable versions of packages
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Initialize packages
(package-initialize)

;; A list of all packages to be installed and loaded
(defvar my-required-packages
  '(
      company
      counsel
      counsel-projectile
      exec-path-from-shell
      gptel
      ivy
      lsp-mode
      lsp-pyright
      lsp-ui
      magit
      material-theme
      multiple-cursors
      projectile
      rg
      undo-tree
      use-package
  )
)

;; Run this once to ensure package archives are up-to-date
;(package-refresh-contents)

(dolist (package my-required-packages)
  (unless (package-installed-p package)
    (message "Installing %s package..." package)
    (package-install package)
    (message "%s package installed." package)))

;; load-path
(let ((lisp-dir (expand-file-name "lisp" user-emacs-directory)))
  ;; Support subdirectories in lisp/
  (when (file-directory-p lisp-dir)
    (add-to-list 'load-path lisp-dir)
    (let ((default-directory lisp-dir))
      (normal-top-level-add-subdirs-to-load-path))))

;; X-resources (Inhibit alpha)
(setq inhibit-x-resources t)

;; whitespace mode
(global-set-key (kbd "C-c w s") 'whitespace-mode)

;; line numbers
(global-set-key (kbd "C-c l n") 'display-line-numbers-mode)
(global-set-key (kbd "C-c n l") 'display-line-numbers-mode)

;; A few good ideas ...
(global-auto-revert-mode)

(setq-default tab-width 4) ;; Preference for Golang

(fset 'yes-or-no-p 'y-or-n-p)

(blink-cursor-mode 0)
(scroll-bar-mode -1) ;; turn off scroll bar

(setq split-height-threshold nil) ;; change default window split
(setq split-width-threshold 0)

;; Comment inserter -- Used in conjunction with occur
(defun my/insert-comment-below-matches-in-files (dir file-regexp line-regexp comment)
  "Recursively insert COMMENT below every line matching LINE-REGEXP in files under DIR whose names match FILE-REGEXP."
  (interactive
   (list
    (read-directory-name "Directory: ")
    (read-regexp "Filename regexp (e.g., \\.el$): ")
    (read-regexp "Line regexp to match: ")
    (read-string "Comment to insert: ")))
  (let ((files (directory-files-recursively dir file-regexp)))
    (dolist (file files)
      (with-current-buffer (find-file-noselect file)
        (save-excursion
          (goto-char (point-min))
          (let ((count 0))
            (while (re-search-forward line-regexp nil t)
              (end-of-line)
              (insert "\n" comment)
              (setq count (1+ count)))
            (when (> count 0)
              (save-buffer))))
        (kill-buffer)))))

;; trim whitespace
(defun my/trim-trailing-and-blank-whitespace-region (beg end)
  "Trim trailing whitespace in region.

   If a line in the region contains only whitespace, remove all
   whitespace, but keep the empty line."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (not (eobp))
        (let ((line-start (point))
              (line-end (line-end-position)))
          (if (string-match-p "\\`[ \t]+\\'" (buffer-substring line-start line-end))
              ;; Line is only whitespace: delete all
              (delete-region line-start line-end)
            ;; Else, just trim trailing whitespace
            (progn
              (goto-char line-end)
              (skip-chars-backward " \t" line-start)
              (delete-region (point) line-end)))
          (forward-line 1))))))

(global-set-key (kbd "C-c t w s") #'my/trim-trailing-and-blank-whitespace-region)

;; --- Shell ---
(global-set-key (kbd "C-t") 'shell)

(add-hook 'sh-mode-hook
          (lambda ()
            ;; This is the most reliable way to set a key in a mode map.
            ;; It explicitly modifies the sh-mode-map to bind C-c C-r to your function.
            (define-key sh-mode-map (kbd "C-c C-r") 'my-eval-region)))

(defun my/shell-history-file ()
  "Return the history file path for the current shell."
  (let* ((shell (or (getenv "SHELL") "/bin/bash"))
         (shell-name (file-name-nondirectory shell)))
    (cond
     ((string= shell-name "zsh")
      (expand-file-name "~/.zsh_history"))
     ((string= shell-name "bash")
      (expand-file-name "~/.bash_history"))
     (t
      (expand-file-name "~/.bash_history")))))

(defun my/read-shell-history (file)
  "Read shell history lines from FILE, cleaning up as needed."
  (when (file-readable-p file)
    (with-temp-buffer
      (insert-file-contents file)
      (let ((lines (split-string (buffer-string) "\n" t)))
        (cond
         ;; zsh history has : 1690000000:0;command
         ((string-match-p "\\.zsh_history\\'" file)
          (mapcar (lambda (line)
                    (if (string-match ";\\(.*\\)$" line)
                        (match-string 1 line)
                      line))
                  lines))
         ;; bash history is just lines of commands
         (t lines))))))

(defun my/counsel-shell-history ()
  "Counsel interface to shell history in *shell* buffers."
  (interactive)
  (let ((histfile (my/shell-history-file)))
    (ivy-read "Shell history: "
              (delete-dups (reverse (my/read-shell-history histfile)))
              :action (lambda (cmd)
                        (when (and (derived-mode-p 'shell-mode)
                                   (get-buffer-process (current-buffer)))
                          (goto-char (point-max))
                          (insert cmd)))
              :caller 'my/counsel-shell-history)))

;; bind to C-r in shell-mode
(with-eval-after-load 'shell
  (define-key shell-mode-map (kbd "C-r") #'my/counsel-shell-history))

(defun my/shell-cd-to-current-file-dir ()
  "Change *shell* buffer's directory to the directory of the current buffer's file."
  (interactive)
  (let* ((file (buffer-file-name))
         (dir (and file (file-name-directory file))))
    (if (not dir)
        (message "Current buffer is not visiting a file.")
      (let ((shell-buf (get-buffer "*shell*")))
        (if (not shell-buf)
            (message "No *shell* buffer found.")
          (with-current-buffer shell-buf
            (comint-send-string shell-buf (concat "cd " (shell-quote-argument dir) "\n")))
          (message "Sent 'cd' to *shell*: %s" dir))))))

(global-set-key (kbd "C-c C-d") #'my/shell-cd-to-current-file-dir)

(defvar my/shell-dir-history nil
  "List of directories sent to *shell* via cd commands.")

(defun my/shell-track-cd-command (input)
  "If INPUT is a cd command, add its directory to `my/shell-dir-history`."
  (when (and (string-match
              ;; Match "cd DIR" or "cd 'DIR'" or "cd \"DIR\""
              "^\\s-*cd\\s-+\\(['\"]?\\)\\([^'\"\n]+\\)\\1\\s-*$"
              input)
             ;; Only track absolute or ~-relative dirs for safety
             (let ((dir (expand-file-name (match-string 2 input))))
               (file-directory-p dir)))
    (let* ((dir-raw (match-string 2 input))
           (dir (expand-file-name dir-raw)))
      (setq my/shell-dir-history
            (cons dir (delete dir my/shell-dir-history))))))

(defun my/shell-enable-cd-tracking ()
  "Enable cd tracking in the current shell buffer."
  (add-hook 'comint-input-filter-functions #'my/shell-track-cd-command nil t))

(add-hook 'shell-mode-hook #'my/shell-enable-cd-tracking)

(defun my/shell-cd-to-dir-from-history ()
  "Prompt with counsel/ivy to select a directory from `my/shell-dir-history` and cd shell there."
  (interactive)
  (if (not my/shell-dir-history)
      (message "No shell directory history yet.")
    (let ((dir (ivy-read "Jump to shell dir: " my/shell-dir-history)))
      (let ((shell-buf (get-buffer "*shell*")))
        (if (not shell-buf)
            (message "No *shell* buffer found.")
          (with-current-buffer shell-buf
            (comint-send-string shell-buf (concat "cd " (shell-quote-argument dir) "\n")))
          (message "Sent 'cd' to *shell*: %s" dir))))))

(global-set-key (kbd "C-j") #'my/shell-cd-to-dir-from-history)

(defun my/shell-add-projectile-dirs-to-history ()
  "Add all Projectile project root directories to `my/shell-dir-history`."
  (interactive)
  (when (bound-and-true-p projectile-known-projects)
    (setq my/shell-dir-history
          (delete-dups
           (append (mapcar #'expand-file-name projectile-known-projects)
                   my/shell-dir-history)))))

(add-hook 'after-init-hook #'my/shell-add-projectile-dirs-to-history)

;; tmux-like functionality
;; 1. Define your tmux-style shell split functions
(defun my/shell-split-below ()
  "Split window below and open a new shell."
  (interactive)
  (split-window-below)
  (other-window 1)
  (shell (generate-new-buffer-name "*shell*")))

(defun my/shell-split-right ()
  "Split window right and open a new shell."
  (interactive)
  (split-window-right)
  (other-window 1)
  (shell (generate-new-buffer-name "*shell*")))

;; 2. Create a C-c b prefix keymap
(define-prefix-command 'my/tmux-prefix)
(global-set-key (kbd "C-c b") 'my/tmux-prefix)

;; 3. Bind tmux-style splits to your prefix
(define-key my/tmux-prefix (kbd "\"") #'my/shell-split-below)  ;; C-c b "
(define-key my/tmux-prefix (kbd "%")  #'my/shell-split-right)  ;; C-c b %

;; Backups
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; --- Custom functions, etc. ---
(defun file-string (file)
  "Read the contents of a file and return as a string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defun insert-current-date ()
  (interactive)
  (insert (shell-command-to-string "echo -n $(date '+%B %d, %Y')")))

(global-set-key (kbd "C-c i d") 'insert-current-date)

(defun shell-command-on-region-replace ()
  (interactive)
  (let ((current-prefix-arg 4)) ;; emulate C-u
    (call-interactively 'shell-command-on-region)))

(global-set-key (kbd "M-|") 'shell-command-on-region-replace)

(defun my-eval-region ()
  "Evaluate region based on the current major mode."
  (interactive)
  (cond
    ;; If it's an Elisp buffer, evaluate as Elisp
    ((eq major-mode 'emacs-lisp-mode)
     (eval-region (region-beginning) (region-end)))

    ;; If it's a Python buffer, send to the Python shell
    ((eq major-mode 'python-mode)
     (python-shell-send-region))

	;; Shell
    ((eq major-mode 'sh-mode)
     (process-send-region "*shell*" (region-beginning) (region-end))
     ;; We add an explicit newline character to execute the command.
     (process-send-string "*shell*" "\n"))

    ;; You could add more languages here
    ;; ((eq major-mode 'js-mode)
    ;;  (js-send-region ...))

    ;; Otherwise, use the standard `eval-region` for any other language
    (t (eval-region (region-beginning) (region-end)))))

(global-set-key (kbd "C-c C-r") 'my-eval-region)

;; toggle windows
(defun my-window-split-toggle ()
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

(global-set-key (kbd "C-x t") 'my-window-split-toggle)

;; transpose windows
(defun my-transpose-windows (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (> arg 0) (1- arg) (1+ arg))))))

(global-set-key (kbd "C-x y") 'my-transpose-windows)

;; --- exec-path-from-shell
(require 'exec-path-from-shell)

;; Tell Emacs to get its PATH from the shell.
;; The `exec-path-from-shell-shell-name` variable can be customized.
;; This needs to run early in your init.el, after package setup.
(exec-path-from-shell-initialize)

;; --- Magit ---
(require 'magit)

;; Remove background for diff-added and diff-removed
(custom-set-faces
 '(diff-added ((t (:foreground "green" :background nil))))
 '(diff-removed ((t (:foreground "red" :background nil))))
 ;; For Magit-specific faces (if needed)
 '(magit-diff-added ((t (:foreground "green" :background nil))))
 '(magit-diff-removed ((t (:foreground "red" :background nil))))
 ;; You might also want to adjust these:
 '(magit-diff-added-highlight ((t (:foreground "green" :background nil))))
 '(magit-diff-removed-highlight ((t (:foreground "red" :background nil))))
 )

(defun my/insert-jira-trailer-from-branch ()
  "Parse the branch from a COMMIT_EDITMSG buffer and insert a Jira trailer.
Looks for a line like '# On branch batsvr-17211' and inserts:
Jira: BATSVR-17211
at the end of the commit message (before comments), with a blank line before."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let (branch ticket trailer)
      ;; Find the branch name in the comment
      (when (re-search-forward "^# On branch \\([A-Za-z0-9_-]+\\)" nil t)
        (setq branch (match-string 1))
        ;; Try to match a JIRA ticket pattern (project-key-number)
        (when (string-match "^\\([a-zA-Z0-9]+\\)-\\([0-9]+\\)" branch)
          (setq ticket (concat (upcase (match-string 1 branch))
                               "-"
                               (match-string 2 branch)))
          (setq trailer (concat "Jira: " ticket))
          ;; Only insert if not already present
          (unless (save-excursion
                    (goto-char (point-min))
                    (re-search-forward (regexp-quote trailer) nil t))
            ;; Go to the last non-comment, non-empty line
            (goto-char (point-max))
            (while (and (not (bobp))
                        (or (looking-at-p "^\\s-*$")
                            (looking-at-p "^#")))
              (forward-line -1))
            (end-of-line)
            ;; Ensure exactly one blank line before the trailer
            (unless (looking-at-p "^$")
              (insert "\n"))
            (insert "\n" trailer "\n")))))))

(with-eval-after-load 'git-commit
  (define-key git-commit-mode-map (kbd "C-c j t") #'my/insert-jira-trailer-from-branch))

;; --- Recentf and Counsel ---
(require 'recentf)
(require 'counsel)
(recentf-mode 1)
(setq recentf-max-menu-items 100)
(setq recentf-max-saved-items 10000)
(run-with-timer 0 (* 30 60) 'recentf-save-list)
(global-set-key (kbd "C-c o r") 'counsel-recentf)

;; --- Swiper ---
;; Ensure the 'ivy' package is installed. Swiper depends on Ivy.
(unless (package-installed-p 'ivy)
  (message "Installing ivy package (required for swiper)...")
  (package-refresh-contents) ; Make sure package list is up-to-date
  (package-install 'ivy)
  (message "ivy package installed."))

(ivy-mode 1) ; Recommended for overall Ivy experience

(require 'swiper)
(global-set-key (kbd "C-s") 'swiper)

;; --- Projectile and Counsel-Projectile Setup ---
(require 'projectile)
(require 'counsel-projectile)

;; The core Projectile commands are automatically available, but we
;; enable the mode for extra features
(projectile-mode +1)

(global-set-key (kbd "C-c p p") 'counsel-projectile-switch-project)
(global-set-key (kbd "C-c p f") 'counsel-projectile-find-file)

;; --- Undo-tree ---
(require 'undo-tree)
(global-undo-tree-mode 1)
(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "C-S-z") 'undo-tree-redo)

;; Configure undo-tree to save all history files to a central directory
(setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo-history/")))

;; --- Org-mode ---
;; Change states in Org buffers easily
(setq org-support-shift-select t)

(setq org-todo-keywords
      '((sequence "TODO" "NEXT" "CURR" "|" "DONE" "CNCL" "SUSP" "VRFY")))

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

;; 1. Set your Org root directory
(defvar my/org-root "~/mw/"
  "Root directory for my Org files.")

;; 2. List your Org files using that root
(setq my/org-refile-files
      (mapcar (lambda (f) (expand-file-name f my/org-root))
              '("now.org" "archive.org")))

;; 3. Configure refile targets
(setq org-refile-targets
      `((,my/org-refile-files :maxlevel . 2)))

;; --- Theme ---
;; Optional: Disable other themes first for a clean slate
(dolist (theme custom-enabled-themes)
  (disable-theme theme))

;; Load your desired Material theme
(load-theme 'material t)

; Or for the light variant:
;; (load-theme 'material-light t)

;; -- multiple cursors --
(global-set-key (kbd "C-c m c") 'mc/edit-lines)

;; --- company ---
(require 'company)

;; Enable company-mode globally after Emacs has finished starting up
(global-company-mode)

(setq company-idle-delay 0.2)
(setq company-minimum-prefix-length 2)

(global-set-key (kbd "M-p") 'company-complete)

;; --- ripgrep ---
(global-set-key (kbd "C-c r g") 'rg)
(global-set-key (kbd "C-c p r g") 'projectile-ripgrep)

;; -- Language-specific configs ---
;; --- LSP ---
(require 'lsp-mode)
(require 'lsp-ui)

;; --- Python ---
;; Bugs begin here ...
;; --- Python with LSP (pyright) ---
(require 'lsp-pyright)

;; Explicitly set the executable path for the pyright client.
;; This is the location `lsp-mode` will use when you tell it to.
(setq lsp-pyright-executable "~/.local/venv/bin/pyright-langserver")

;; Tell lsp-mode that pyright is the default server for Python.
;; This is still a good idea, as it provides a clear preference.
(setq lsp-python-default-server 'pyright)
(setq lsp-enabled-clients '(pyright))

;; A simple hook to enable lsp-mode whenever you open a Python file.
(add-hook 'python-mode-hook #'lsp-deferred)

;; Optional: Enable lsp-ui mode for better UI elements (pop-ups, sidebar, etc.)
(add-hook 'lsp-mode-hook #'lsp-ui-mode)

;; --- YAML ---
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode))
;(add-hook 'yaml-mode-hook #'lsp)
;; You'll need to install the server: npm install -g yaml-language-server

;; --- shell ---
(add-hook 'sh-mode-hook #'lsp)
;; For Dockerfiles
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . sh-mode))
;; You'll need to install the server: npm install -g bash-language-server

;; --- Perl ---
;(add-to-list 'auto-mode-alist '("\\.p[lm]\\'" . cperl-mode))
;(add-hook 'cperl-mode-hook #'lsp)
;; You'll need to install the server: cpanm Perl::LanguageServer

;; --- gptel ---
;; Load gptel-cody
(let* ((file "gptel-cody.el")
       (found (locate-library file)))
  (when found
    (load file)
    (condition-case nil
        (progn
          (require 'gptel-cody)
          (setq gptel-model 'anthropic::2024-10-22::claude-3-5-sonnet-latest
                gptel-backend (gptel-make-cody "Cody" :host "sourcegraph.mathworks.com"))
          (init-cody gptel-backend))
      (error (message "gptel-cody feature could not be loaded")))))

(setq gptel-rewrite-default-action 'accept)
(global-set-key (kbd "C-c g r") 'gptel-rewrite)

;; --- custom ---
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Load the custom file if it exists
(when (file-exists-p custom-file)
  (load custom-file))
