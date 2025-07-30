;; --- ~/.emacs.d/init-personal.el ---

;; Ensure package system is ready (usually in main init, but doesn't hurt here)
(setq package-enable-at-startup nil) ; Optional
(package-initialize)

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

;; --- Require and Configure ---

;; Magit
(require 'magit)

;; Recentf and Counsel
(require 'recentf)
(require 'counsel)
(recentf-mode 1)
(setq recentf-max-menu-items 100)
(setq recentf-max-saved-items 10000)
(run-with-timer 0 (* 30 60) 'recentf-save-list)
(global-set-key (kbd "C-c o r") 'counsel-recentf)
(ivy-mode 1) ; Recommended for overall Ivy experience

;; Swiper

;; Ensure the 'ivy' package is installed. Swiper depends on Ivy.
(unless (package-installed-p 'ivy)
  (message "Installing ivy package (required for swiper)...")
  (package-refresh-contents) ; Make sure package list is up-to-date
  (package-install 'ivy)
  (message "ivy package installed."))

(require 'swiper)             ; Load the swiper library

(global-set-key (kbd "C-s") 'swiper) ; Bind C-s to swiper

;; Optional but Recommended: Enable Ivy mode globally
;; This makes other search/completion commands also use Ivy.
;; If you already have (ivy-mode 1) for counsel-recentf, you don't need this again.
(ivy-mode 1)

;; Undo-tree
(require 'undo-tree)
(global-undo-tree-mode 1)
(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "C-S-z") 'undo-tree-redo)

;; --- Theme ---
;; Optional: Disable other themes first for a clean slate
(dolist (theme custom-enabled-themes)
  (disable-theme theme))

;; Load your desired Material theme
(load-theme 'material t)
;; Or for the light variant:
;; (load-theme 'material-light t)

;; Add more of your personal configurations below...
