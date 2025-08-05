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
      yaml-mode
  )
)

;; Run this once to ensure package archives are up-to-date
;(package-refresh-contents)

(dolist (package my-required-packages)
  (unless (package-installed-p package)
    (message "Installing %s package..." package)
    (package-install package)
    (message "%s package installed." package)))


;; --- exec-path-from-shell
(require 'exec-path-from-shell)

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

;; Enable synchronization with the system clipboard
(setq select-enable-clipboard t)

;; On Linux (X11), also enable synchronization with the primary selection.
;; This allows you to paste with the middle mouse button.
(setq select-enable-primary t)

;; --- Shell ---
(global-set-key (kbd "C-t") 'shell)

;; Add a hook that checks the filename before starting LSP
(add-hook 'sh-mode-hook
          (lambda ()
            ;; Only start LSP if the file is NOT your zshrc
            (unless (string-match-p "zshrc" (buffer-file-name))
              (lsp-deferred))

            ;; This is the most reliable way to set a key in a mode map.
            ;; It explicitly modifies the sh-mode-map to bind C-c C-r to your function.
            (define-key sh-mode-map (kbd "C-c C-r") 'my-eval-region)))

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
    ((eq major-mode 'emacs-lisp-mode)
     (eval-region (region-beginning) (region-end)))
    ((eq major-mode 'python-mode)
     (python-shell-send-region))
    ((eq major-mode 'sh-mode)
     (process-send-region "*shell*" (region-beginning) (region-end))
     (process-send-string "*shell*" "\n"))
	;; Default to `eval-region`
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

;; Tell Emacs to get its PATH from zsh.
;; The `exec-path-from-shell-shell-name` variable can be customized.
;; This needs to run early in your init.el, after package setup.
(exec-path-from-shell-initialize)

;; --- Magit ---
(require 'magit)

;; Remove background for diff-added and diff-removed
(custom-set-faces
 '(diff-added ((t (:foreground "green" :background nil))))
 '(diff-removed ((t (:foreground "red" :background nil))))
 ;; For magit-specific faces
 '(magit-diff-added ((t (:foreground "green" :background nil))))
 '(magit-diff-removed ((t (:foreground "red" :background nil))))
 '(magit-diff-added-highlight ((t (:foreground "green" :background nil))))
 '(magit-diff-removed-highlight ((t (:foreground "red" :background nil))))
)

;; --- Recentf and Counsel ---
(require 'recentf)
(require 'counsel)
(recentf-mode 1)
(setq recentf-max-menu-items 100)
(setq recentf-max-saved-items 10000)
(run-with-timer 0 (* 30 60) 'recentf-save-list)
(global-set-key (kbd "C-c o r") 'counsel-recentf)

;; --- Swiper ---
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

(setq org-todo-keyword-faces
 '(
    ("NEXT" .
      (:foreground "khaki"
       :background "dark goldenrod"
       :weight bold))
    ("CURR" .
      (:foreground "light blue"
       :background "midnight blue"
       :weight bold))
  )
)

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

;; Optional: Customize company-mode settings
(setq company-idle-delay 0.2)
(setq company-minimum-prefix-length 2)

;; Optional: Set up keybindings for company
;; C-n and C-p for navigating completions (same as standard Emacs)
(global-set-key (kbd "M-p") 'company-complete)

;; --- ripgrep ---
(global-set-key (kbd "C-c r g") 'rg)
(global-set-key (kbd "C-c p r g") 'projectile-ripgrep)

;; -- Language-specific configs ---
;; --- LSP ---
(require 'lsp-mode)
(require 'lsp-ui)

;(add-to-list 'safe-local-variable-values '(lsp-enable-client . nil))

;; Combined LSP clients list
(setq lsp-enabled-clients '(pyright perls bash-ls))

;; --- Python ---
;; Bugs begin here ...
;; --- Python with LSP (pyright) ---
(require 'lsp-pyright)

;; Explicitly set the executable path for the pyright client.
;; This is the location `lsp-mode` will use when you tell it to.
(setq lsp-pyright-executable "/usr/bin/pyright-langserver")

;; Tell lsp-mode that pyright is the default server for Python.
;; This is still a good idea, as it provides a clear preference.
(setq lsp-python-default-server 'pyright)

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
(add-to-list 'auto-mode-alist '("\\.p[lm]\\'" . cperl-mode))

;; --- custom ---
(setq custom-file "~/.emacs.d/custom.el")

(when (file-exists-p custom-file)
  (load custom-file))
