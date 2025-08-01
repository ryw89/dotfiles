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
      magit
      counsel
      projectile
      counsel-projectile
      undo-tree
      material-theme
      multiple-cursors
      lsp-mode
      lsp-ui
      lsp-pyright
      company
      exec-path-from-shell
      ivy
  )
)

;; Run this once to ensure package archives are up-to-date
;(package-refresh-contents)

(dolist (package my-required-packages)
  (unless (package-installed-p package)
    (message "Installing %s package..." package)
    (package-install package)
    (message "%s package installed." package)))

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

;; --- Shell ---
(global-set-key (kbd "C-t") 'shell)

(add-hook 'sh-mode-hook
          (lambda ()
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
       (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

(global-set-key (kbd "C-x y") 'my-transpose-windows)

;; --- exec-path-from-shell
(require 'exec-path-from-shell)

;; Tell Emacs to get its PATH from zsh.
;; The `exec-path-from-shell-shell-name` variable can be customized.
;; This needs to run early in your init.el, after package setup.
(exec-path-from-shell-initialize)

;; --- Magit ---
(require 'magit)

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

;; You may also want to bind the other useful functions to have access
;; to both workflows. Here are some common bindings for them:
;; (global-set-key (kbd "C-c m n") 'mc/mark-next-like-this)
;; (global-set-key (kbd "C-c m p") 'mc/mark-previous-like-this)
;; (global-set-key (kbd "C-c m a") 'mc/mark-all-like-this)				

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
(setq lsp-pyright-executable "/usr/bin/pyright-langserver")

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
(add-hook 'yaml-mode-hook #'lsp)
;; You'll need to install the server: npm install -g yaml-language-server

;; --- shell ---
(add-hook 'sh-mode-hook #'lsp)
;; For Dockerfiles
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . sh-mode))
;; You'll need to install the server: npm install -g bash-language-server

;; --- Perl ---
(add-to-list 'auto-mode-alist '("\\.p[lm]\\'" . cperl-mode))
(add-hook 'cperl-mode-hook #'lsp)
;; You'll need to install the server: cpanm Perl::LanguageServer
