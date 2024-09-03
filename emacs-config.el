(setq user-full-name "John Monteiro")

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun my/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'my/display-startup-time)

;; Initialize package sources
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; Automatically install packages
(require 'use-package)
(setq use-package-always-ensure t)

;; Never load a package until demanded or triggered
;;(setq use-package-always-defer t)

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

;; Change the user-emacs-directory to keep unwanted things out of ~/.emacs.d
(setq user-emacs-directory (expand-file-name "~/.cache/emacs/")
      url-history-file (expand-file-name "url/history" user-emacs-directory))

(use-package no-littering
  :demand t
  :config
  ;; Set the custom-file to a file that won't be tracked by Git
  (setq custom-file (if (boundp 'server-socket-dir)
                        (expand-file-name "custom.el" server-socket-dir)
                      (no-littering-expand-etc-file-name "custom.el")))
  (when (file-exists-p custom-file)
    (load custom-file t))

  ;; Don't litter project folders with backup files
  (let ((backup-dir (no-littering-expand-var-file-name "backup/")))
    (make-directory backup-dir t)
    (setq backup-directory-alist
          `(("\\`/tmp/" . nil)
            ("\\`/dev/shm/" . nil)
            ("." . ,backup-dir))))

  (setq auto-save-default nil)

  ;; Tidy up auto-save files
  (setq auto-save-default nil)
  (let ((auto-save-dir (no-littering-expand-var-file-name "auto-save/")))
    (make-directory auto-save-dir t)
    (setq auto-save-file-name-transforms
          `(("\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
             ,(concat temporary-file-directory "\\2") t)
            ("\\`\\(/tmp\\|/dev/shm\\)\\([^/]*/\\)*\\(.*\\)\\'" "\\3")
            ("." ,auto-save-dir t)))))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
;(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
;(menu-bar-mode -1)          ; Disable the menu bar

(setq-default fill-column 80)

;; Set up the visible bell
(setq visible-bell 1)
(setq ring-bell-function 'ignore)

;; Use UTF-8 by default
(set-default-coding-systems 'utf-8)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; mouse settings
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't)       ;; scroll window under mouse
(setq scroll-step 1)                     ;; keyboard scroll one line at a time

(setq large-file-warning-threshold nil)
(setq vc-follow-symlinks t)

;; (column-number-mode)
;; (global-display-line-numbers-mode t)
;; ;; Disable line numbers for some modes
;; (dolist (mode '(org-mode-hook
;;                 term-mode-hook
;;                 shell-mode-hook
;;                 treemacs-mode-hook
;;                 eshell-mode-hook))
;; (add-hook mode (lambda () (display-line-numbers-mode 0))))

(defvar my/fixed-pitch-font "JetBrainsMono Nerd Font"
  "The font used for `default' and `fixed-pitch' faces.")

(defvar my/fixed-pitch-size 120)

(defvar my/variable-pitch-font "Inter"
  "The font used for `variable-pitch' face.")

(defvar my/variable-pitch-size 120)

(defvar my/org-heading-font "Inter"
  "The font used for Org Mode headings.")

;; Set the default font face
(set-face-attribute 'default nil
                    :font my/fixed-pitch-font
                    :weight 'normal
                    :height my/fixed-pitch-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil
                    :font my/fixed-pitch-font
                    :weight 'normal
                    :height my/fixed-pitch-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil
                    :font my/variable-pitch-font
                    :height my/variable-pitch-size
                    :weight 'normal)

;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; Uncomment the following line if line spacing needs adjusting.
;;(setq-default line-spacing 0.12)

;; Set frame maximized
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Transparency
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; theme
(use-package doom-themes
  :init (load-theme 'doom-rouge t)
  :config
  (setq doom-themes-enable-bold t  ; if nil, bold is universally disabled
        doom-themes-enable-italic t))  ; if nil, italics is universally disabled

(use-package all-the-icons
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(column-number-mode)
;;(global-display-line-numbers-mode t)

(global-hl-line-mode t)

;; Enable line numbers for some modes
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 15      ;; sets modeline height
        doom-modeline-bar-width 5    ;; sets right bar width
        doom-modeline-persp-name t   ;; adds perspective name to modeline
        doom-modeline-persp-icon t)) ;; adds folder icon next to persp name

;; default tab size
(setq-default tab-width 2
  indent-tabs-mode nil)

;; Paren Matching

(use-package smartparens
  :hook (prog-mode . smartparens-mode)
  :config
  (sp-use-smartparens-bindings))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :hook (org-mode
         emacs-lisp-mode
         web-mode
         typescript-mode
         js2-mode))

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(global-set-key (kbd "C-c h w") 'whitespace-mode)
(global-set-key (kbd "C-c h l") 'visual-line-mode)

(use-package general
    :config
    (general-evil-setup)

    ;; set up 'SPC' as the global leader key
    (general-create-definer my/leader-keys
      :states '(normal insert visual emacs)
      :keymaps 'override
      :prefix "SPC" ;; set leader
      :global-prefix "M-SPC") ;; access leader in insert mode

    (my/leader-keys
      "SPC" '(counsel-M-x :wk "Counsel M-x")
      "." '(find-file :wk "Find file")
      "=" '(perspective-map :wk "Perspective") ;; Lists all the perspective keybindings
      "TAB TAB" '(comment-line :wk "Comment lines")
      "u" '(universal-argument :wk "Universal argument"))

    (my/leader-keys
      "b" '(:ignore t :wk "Bookmarks/Buffers")
      "b b" '(switch-to-buffer :wk "Switch to buffer")
      "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
      "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
      "b d" '(bookmark-delete :wk "Delete bookmark")
      "b i" '(ibuffer :wk "Ibuffer")
      "b k" '(kill-current-buffer :wk "Kill current buffer")
      "b K" '(kill-some-buffers :wk "Kill multiple buffers")
      "b l" '(list-bookmarks :wk "List bookmarks")
      "b m" '(bookmark-set :wk "Set bookmark")
      "b n" '(next-buffer :wk "Next buffer")
      "b p" '(previous-buffer :wk "Previous buffer")
      "b r" '(revert-buffer :wk "Reload buffer")
      "b R" '(rename-buffer :wk "Rename buffer")
      "b s" '(basic-save-buffer :wk "Save buffer")
      "b S" '(save-some-buffers :wk "Save multiple buffers")
      "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))

    (my/leader-keys
      "d" '(:ignore t :wk "Dired")
      "d d" '(dired :wk "Open dired")
      "d j" '(dired-jump :wk "Dired jump to current")
      "d n" '(neotree-dir :wk "Open directory in neotree")
      "d p" '(peep-dired :wk "Peep-dired"))

    (my/leader-keys
      "e" '(:ignore t :wk "Eshell/Evaluate")    
      "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
      "e d" '(eval-defun :wk "Evaluate defun containing or after point")
      "e e" '(eval-expression :wk "Evaluate and elisp expression")
      "e h" '(counsel-esh-history :which-key "Eshell history")
      "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
      "e r" '(eval-region :wk "Evaluate elisp in region")
      "e R" '(eww-reload :which-key "Reload current page in EWW")
      "e s" '(eshell :which-key "Eshell")
      "e w" '(eww :which-key "EWW emacs web wowser"))

    (my/leader-keys
      "f" '(:ignore t :wk "Files")    
      "f c" '((lambda () (interactive)
                (find-file "~/.config/emacs/config.org")) 
              :wk "Open emacs config.org")
      "f e" '((lambda () (interactive)
                (dired "~/.config/emacs/")) 
              :wk "Open user-emacs-directory in dired")
      "f d" '(find-grep-dired :wk "Search for string in files in DIR")
      "f g" '(counsel-grep-or-swiper :wk "Search for string current file")
      "f i" '((lambda () (interactive)
                (find-file "~/.config/emacs/init.el")) 
              :wk "Open emacs init.el")
      "f j" '(counsel-file-jump :wk "Jump to a file below current directory")
      "f l" '(counsel-locate :wk "Locate a file")
      "f r" '(counsel-recentf :wk "Find recent files")
      "f u" '(sudo-edit-find-file :wk "Sudo find file")
      "f U" '(sudo-edit :wk "Sudo edit file"))

    (my/leader-keys
      "g" '(:ignore t :wk "Git")    
      "g /" '(magit-displatch :wk "Magit dispatch")
      "g ." '(magit-file-displatch :wk "Magit file dispatch")
      "g b" '(magit-branch-checkout :wk "Switch branch")
      "g c" '(:ignore t :wk "Create") 
      "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
      "g c c" '(magit-commit-create :wk "Create commit")
      "g c f" '(magit-commit-fixup :wk "Create fixup commit")
      "g C" '(magit-clone :wk "Clone repo")
      "g f" '(:ignore t :wk "Find") 
      "g f c" '(magit-show-commit :wk "Show commit")
      "g f f" '(magit-find-file :wk "Magit find file")
      "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
      "g F" '(magit-fetch :wk "Git fetch")
      "g g" '(magit-status :wk "Magit status")
      "g i" '(magit-init :wk "Initialize git repo")
      "g l" '(magit-log-buffer-file :wk "Magit buffer log")
      "g r" '(vc-revert :wk "Git revert file")
      "g s" '(magit-stage-file :wk "Git stage file")
      "g t" '(git-timemachine :wk "Git time machine")
      "g u" '(magit-stage-file :wk "Git unstage file"))

    (my/leader-keys
      "h" '(:ignore t :wk "Help")
      "h a" '(counsel-apropos :wk "Apropos")
      "h b" '(describe-bindings :wk "Describe bindings")
      "h c" '(describe-char :wk "Describe character under cursor")
      "h d" '(:ignore t :wk "Emacs documentation")
      "h d a" '(about-emacs :wk "About Emacs")
      "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
      "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
      "h d m" '(info-emacs-manual :wk "The Emacs manual")
      "h d n" '(view-emacs-news :wk "View Emacs news")
      "h d o" '(describe-distribution :wk "How to obtain Emacs")
      "h d p" '(view-emacs-problems :wk "View Emacs problems")
      "h d t" '(view-emacs-todo :wk "View Emacs todo")
      "h d w" '(describe-no-warranty :wk "Describe no warranty")
      "h e" '(view-echo-area-messages :wk "View echo area messages")
      "h f" '(describe-function :wk "Describe function")
      "h F" '(describe-face :wk "Describe face")
      "h g" '(describe-gnu-project :wk "Describe GNU Project")
      "h i" '(info :wk "Info")
      "h I" '(describe-input-method :wk "Describe input method")
      "h k" '(describe-key :wk "Describe key")
      "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
      "h L" '(describe-language-environment :wk "Describe language environment")
      "h m" '(describe-mode :wk "Describe mode")
      "h r" '(:ignore t :wk "Reload")
      "h r r" '((lambda () (interactive)
                  (load-file "~/.config/emacs/init.el")
                  (ignore (elpaca-process-queues)))
                :wk "Reload emacs config")
      "h t" '(load-theme :wk "Load theme")
      "h v" '(describe-variable :wk "Describe variable")
      "h w" '(where-is :wk "Prints keybinding for command if set")
      "h x" '(describe-command :wk "Display full documentation for command"))

    (my/leader-keys
      "m" '(:ignore t :wk "Org")
      "m a" '(org-agenda :wk "Org agenda")
      "m e" '(org-export-dispatch :wk "Org export dispatch")
      "m i" '(org-toggle-item :wk "Org toggle item")
      "m t" '(org-todo :wk "Org todo")
      "m B" '(org-babel-tangle :wk "Org babel tangle")
      "m T" '(org-todo-list :wk "Org todo list"))

    (my/leader-keys
      "m b" '(:ignore t :wk "Tables")
      "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

    (my/leader-keys
      "m d" '(:ignore t :wk "Date/deadline")
      "m d t" '(org-time-stamp :wk "Org time stamp"))

    (my/leader-keys
      "o" '(:ignore t :wk "Open")
      "o d" '(dashboard-open :wk "Dashboard")
      "o e" '(elfeed :wk "Elfeed RSS")
      "o f" '(make-frame :wk "Open buffer in new frame")
      "o F" '(select-frame-by-name :wk "Select frame by name"))

    ;; projectile-command-map already has a ton of bindings 
    ;; set for us, so no need to specify each individually.
    (my/leader-keys
      "p" '(projectile-command-map :wk "Projectile"))

    (my/leader-keys
      "s" '(:ignore t :wk "Search")
      "s d" '(dictionary-search :wk "Search dictionary")
      "s m" '(man :wk "Man pages")
      "s t" '(tldr :wk "Lookup TLDR docs for a command")
      "s w" '(woman :wk "Similar to man but doesn't require man"))

    (my/leader-keys
      "t" '(:ignore t :wk "Toggle")
      "t e" '(eshell-toggle :wk "Toggle eshell")
      "t f" '(flycheck-mode :wk "Toggle flycheck")
      "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
      "t n" '(neotree-toggle :wk "Toggle neotree file viewer")
      "t o" '(org-mode :wk "Toggle org mode")
      "t r" '(rainbow-mode :wk "Toggle rainbow mode")
      "t t" '(visual-line-mode :wk "Toggle truncated lines")
      "t v" '(vterm-toggle :wk "Toggle vterm"))

    (my/leader-keys
      "w" '(:ignore t :wk "Windows")
      ;; Window splits
      "w c" '(evil-window-delete :wk "Close window")
      "w n" '(evil-window-new :wk "New window")
      "w s" '(evil-window-split :wk "Horizontal split window")
      "w v" '(evil-window-vsplit :wk "Vertical split window")
      ;; Window motions
      "w h" '(evil-window-left :wk "Window left")
      "w j" '(evil-window-down :wk "Window down")
      "w k" '(evil-window-up :wk "Window up")
      "w l" '(evil-window-right :wk "Window right")
      "w w" '(evil-window-next :wk "Goto next window")
      ;; Move Windows
      "w H" '(buf-move-left :wk "Buffer move left")
      "w J" '(buf-move-down :wk "Buffer move down")
      "w K" '(buf-move-up :wk "Buffer move up")
      "w L" '(buf-move-right :wk "Buffer move right"))
  )

(use-package evil
    :init      ;; tweak evil's configuration before loading it
    (setq evil-want-integration t  ;; This is optional since it's already set to t by default.
          evil-want-keybinding nil
          evil-want-C-u-scroll t
          evil-vsplit-window-right t
          evil-split-window-below t
          evil-undo-system 'undo-redo)  ;; Adds vim-like C-r redo functionality
    (evil-mode))

(use-package evil-collection
  :after evil
  :config
  ;; Do not uncomment this unless you want to specify each and every mode
  ;; that evil-collection should works with.  The following line is here 
  ;; for documentation purposes in case you need it.  
  ;; (setq evil-collection-mode-list '(calendar dashboard dired ediff info magit ibuffer))
  (add-to-list 'evil-collection-mode-list 'help) ;; evilify help mode
  (evil-collection-init))

(use-package evil-tutor)

;; Using RETURN to follow links in Org/Evil 
;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))
;; Setting RETURN key in org-mode to follow links
  (setq org-return-follows-link  t)

(use-package which-key
  :init
  (which-key-mode 1)  
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
	which-key-sort-order #'which-key-key-order
	which-key-allow-imprecise-window-fit nil
	which-key-sort-uppercase-first nil
	which-key-add-column-padding 1
	which-key-max-display-columns nil
	which-key-min-display-lines 6
	which-key-side-window-slot -10
	which-key-side-window-max-height 0.25
	which-key-idle-delay 0.8
	which-key-max-description-length 25
	which-key-allow-imprecise-window-fit nil
	which-key-separator " → " ))

(global-set-key [escape] 'keyboard-escape-quit)

;; Make ESC quit prompts
(global-set-key [escape] 'keyboard-escape-quit)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package neotree
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

(use-package magit)

(use-package hl-todo
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package hl-todo
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
