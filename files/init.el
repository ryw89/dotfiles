;; ~/.emacs

;; Load cl-lib for cl-return. It's often pre-loaded but good to be explicit.
(require 'cl-lib)

;; --- Alternate Init File Loader ---
(let* ((alt-init-files
        '("~/Dropbox/bin/dotfiles/files/dotemacs_working.el"   ;; Highest precedence
          "~/.emacs.d/init-personal.el"
          "~/.emacs.d/init-dev.el")) ;; Lowest precedence for alternates
       (loaded-alt-init nil))
  (dolist (file alt-init-files)
    (let ((expanded-file (expand-file-name file)))
      (when (file-exists-p expanded-file)
        (message "Loading alternate init file: %s" expanded-file)
        (load-file expanded-file)
        (setq loaded-alt-init t)
        (cl-return)))) ;; Exit the dolist loop once one is loaded
  (unless loaded-alt-init
    (message "No alternate init file found. Continuing with default ~/.emacs.")))
;; --- End Alternate Init File Loader ---


;; If an alternate file was loaded, it would have executed all its code.
;; What you put AFTER this block in your main ~/.emacs depends on your desired behavior:

;; Option 1: If an alternate file is loaded, you want *nothing else* from this ~/.emacs to run.
;; In this case, you'd effectively have nothing after the block above. The loaded alternate file
;; would take over.

;; Option 2: If an alternate file is loaded, you still want *some* common configuration to run
;; from this ~/.emacs, *after* the alternate has done its job.
;; In this case, put the common config here:
;; (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
;; (load custom-file 'noerror)
;; (setq-default fill-column 80)
;; ...

;; Option 3: You want this ~/.emacs to only run if *no* alternate file was found.
;; (This is achieved by putting the rest of your default configuration inside an `unless` block
;; that checks `loaded-alt-init`, but it's often simpler to just rely on the alternate file
;; taking over and either exiting or not returning control.)

;; A common pattern is for the *alternate* file to then explicitly exit or return control
;; to the main `init.el` if it's meant to be supplemental. If it's meant to be exclusive,
;; the alternate file just runs and then Emacs continues its startup.
