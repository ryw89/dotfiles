;; --- Emacs config ---

;; --- Basic customization ---
;; Ensure package system is ready (usually in main init, but doesn't hurt here)
(setq package-enable-at-startup nil)
(package-initialize)

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

    ;; You could add more languages here
    ;; ((eq major-mode 'js-mode)
    ;;  (js-send-region ...))

    ;; Otherwise, use the standard `eval-region` for any other language
    (t (eval-region (region-beginning) (region-end)))))

(global-set-key (kbd "C-c C-r") 'my-eval-region)

;; --- Install Packages ---
;; Auto-install Magit
(unless (package-installed-p 'magit)
  (message "Installing magit package...")
  (package-refresh-contents)
  (package-install 'magit)
  (message "magit package installed."))

;; Auto-install Counsel
(unless (package-installed-p 'counsel)
  (message "Installing counsel package...")
  (package-refresh-contents)
  (package-install 'counsel)
  (message "counsel package installed."))

;; Ensure projectile is installed
(unless (package-installed-p 'projectile)
  (message "Installing projectile package...")
  (package-refresh-contents)
  (package-install 'projectile))

;; Ensure counsel-projectile is installed
(unless (package-installed-p 'counsel-projectile)
  (message "Installing counsel-projectile package...")
  (package-refresh-contents)
  (package-install 'counsel-projectile))

;; Auto-install undo-tree
(unless (package-installed-p 'undo-tree)
  (message "Installing undo-tree package...")
  (package-refresh-contents)
  (package-install 'undo-tree)
  (message "undo-tree package installed."))

;; Auto-install material-theme
(unless (package-installed-p 'material-theme)
  (message "Installing material-theme package...")
  (package-refresh-contents)
  (package-install 'material-theme)
  (message "material-theme package installed."))

;; Auto-install lsp-mode
(unless (package-installed-p 'lsp-mode)
  (message "Installing lsp-mode package...")
  (package-refresh-contents)
  (package-install 'lsp-mode)
  (message "lsp-mode package installed."))

;; Auto-install lsp-ui (highly recommended for better UI integration)
(unless (package-installed-p 'lsp-ui)
  (message "Installing lsp-ui package...")
  (package-refresh-contents)
  (package-install 'lsp-ui)
  (message "lsp-ui package installed."))

;; Auto-install company-mode if not already installed
(unless (package-installed-p 'company)
  (message "Installing company-mode package...")
  (package-refresh-contents)
  (package-install 'company)
  (message "company-mode package installed."))

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
(ivy-mode 1) ; Recommended for overall Ivy experience

;; --- Swiper ---
;; Ensure the 'ivy' package is installed. Swiper depends on Ivy.
(unless (package-installed-p 'ivy)
  (message "Installing ivy package (required for swiper)...")
  (package-refresh-contents) ; Make sure package list is up-to-date
  (package-install 'ivy)
  (message "ivy package installed."))

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

;; Optional but Recommended: Enable Ivy mode globally
;; This makes other search/completion commands also use Ivy.
;; If you already have (ivy-mode 1) for counsel-recentf, you don't need this again.
(ivy-mode 1)

;; --- Undo-tree ---
(require 'undo-tree)
(global-undo-tree-mode 1)
(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "C-S-z") 'undo-tree-redo)

;; --- Org-mode ---
;; Change states in Org buffers easily
(setq org-support-shift-select t)

;; --- Theme ---
;; Optional: Disable other themes first for a clean slate
(dolist (theme custom-enabled-themes)
  (disable-theme theme))

;; Load your desired Material theme
(load-theme 'material t)
;; Or for the light variant:
;; (load-theme 'material-light t)

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
;; Enable lsp-mode in Python mode
(add-hook 'python-mode-hook #'lsp)

;; Optional: Enable lsp-ui mode for better UI elements (pop-ups, sidebar, etc.)
(add-hook 'lsp-mode-hook #'lsp-ui-mode)

;; Tell lsp-mode to use pyright for Python
;; You'll need to install pyright in your Python environment: pip install pyright
;; Or install it globally via npm: npm install -g pyright
(setq lsp-pyright-executable (executable-find "pyright-langserver")) ;; Or "pyright" if installed via pip
