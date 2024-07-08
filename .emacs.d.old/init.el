;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; Speed up startup
(unless (or (daemonp) noninteractive init-file-debug)
  (let ((old-file-name-handler-alist file-name-handler-alist))
    (setq file-name-handler-alist nil)
    (add-hook 'emacs-startup-hook
              (lambda ()
                "Recover file name handlers."
                (setq file-name-handler-alist
                      (delete-dups (append file-name-handler-alist
                                          old-file-name-handler-alist)))))))

;; Defer garbage collection further back in the startup process
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
         (lambda ()
           "Recover GC values after startup."
           (setq gc-cons-threshold 800000)))


;; <leaf-install-code>
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org"   . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))
;; </leaf-install-code>


;; leaf
(leaf leaf
  :config
  (leaf leaf-convert
    :ensure t
    :config (leaf use-package :ensure t))

  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
	     (imenu-list-position . 'left))))


;;;;;;;;;;;; My Settings Starts ;;;;;;;;;;;;
(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp packages"
  :tag "builtin" "faces" "help"
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

(leaf cus-start
  :doc "define customizatio properties of builtins"
  :tag "builtin" "internal"
  :custom '((user-full-name . "Satoshi IMAMURA")
            (user-mail-address . "imsatomura@gmail.com")
            (user-login-name . "atosh")
            (recentf-mode . t)
            (history-length . 1000)
            (history-delete-duplicates . t)
            (savehist-mode . t)
            (save-place-mode . t)
            (initial-scratch-message . "")
            (inhibit-startup-message . t)
            (electric-pair-mode . t)
            (mac-auto-ascii-mode . t))
  :config
  (defalias 'yes-or-no-p 'y-or-n-p)
  ;; (leaf-keys (("C-h"     . forward-delete-char)
  ;;           ("C-c M-a" . align-regexp)
  ;;           ("C-c ;"   . comment-region)
  ;;           ("C-c M-;" . uncomment-region)
  ;;           ("C-/"     . undo)
  ;;           ("C-C M-R" . replace-regexp)
  ;;           ("C-c r"   . replace-string)
  ;;           ("<home>"  . beginning-of-buffer)
  ;;           ("C-c M-l" . toggle-truncate-lines)
  ;;           ("C-M-%"   . vr/query-replace)
  ;;           ("C-c v g" . magit-status)
  ;;           ("C-c m e" . emoji-cheat-sheet-plus-insert)))
  )





(leaf *utilities
  :config
  (leaf macrostep
    :ensure t
    :bind (("C-c e" . macrostep-expand)))
  
  (leaf which-key
    :ensure t
    :hook (after-init-hook)
    :custom
    (which-key-idle-secondary-delay . 0)
    :config
    (which-key-mode 1)
    (which-key-setup-minibuffer))
  (leaf auto-minor-mode
    :ensure t
    :config
    (add-to-list 'auto-minor-mode-alist
	         '("init.el" . leaf-tree-mode)))
  (leaf esup
    :ensure t))


(leaf *face-config
  :custom ((scroll-bar-mode)
           (mode-line-bell-mode . t))
  :config
  (leaf *line-number
    :custom-face
    (line-number . '((t :foreground "gray45")))
    (line-number-current-line . '((t :foreground "burlywood3")))
    :config
    (global-display-line-numbers-mode nil))
  
  (leaf doom-themes
    :ensure t
    :custom ((doom-themes-enable-italic . t)
             (doom-themes-enable-bold . t))
    :custom-face
    (doom-modeline-bar . '((t (:background "#6272a4"))))
    :config
    (load-theme 'doom-monokai-pro t)
    (doom-themes-neotree-config)
    (doom-themes-org-config))

  (leaf doom-modeline
    :ensure t
    :custom ((doom-modeline-buffer-file-name-style . 'truncate-with-project)
	     (doom-modeline-icon . t)
	     (doom-modeline-major-mode-icon . nil)
	     (doom-modeline-minor-modes . nil))
    :hook (after-init-hook)
    :config
    (doom-modeline-mode 1)
    (line-number-mode 0)
    (column-number-mode 0)
    (doom-modeline-def-modeline 'main
      '(bar window-number matches buffer-info remote-host buffer-position selection-info)
      '(misc-info persp-name lsp github debug minor-modes input-method major-mode process vcs checker))

    (leaf hide-mode-line
      :ensure t
      :hook (neotree-mode imenu-list-minor-mode minimap-mode imenu-list-major-mode)))
  
  (leaf beacon
    :disabled t
    :ensure t
    :custom ((beacon-size . 25)
	     (beacon-color . 'pink)
	     (beacon-blink-delay . 0.2)
	     (beacon-blink-duration . 0.5)
	     (beacon-blink-when-window-scrolls . nil)
	     (beacon-blink-when-window-changes . t))
    :config
    (beacon-mode t))

  (leaf volatile-highlights
    :ensure t
    :config
    (volatile-highlights-mode t))

  (leaf adaptive-wrap
    :ensure t
    :hook ((visual-line-mode-hook . adaptive-wrap-prefix-mode)
	   (org-mode-hook . visual-line-mode))
    ;:require t
    :setq-default ((adaptive-wrap-extra-indent . 1))
    :config
    (global-visual-line-mode t))
  

  (leaf smooth-scroll
    :ensure t
    )

  (leaf rainbow-mode
    :ensure t
    :config
    (rainbow-mode t))
  
  (leaf *font
    :config
    (set-face-font 'default "UDEV Gothic 35LG")
    (let ((alist '((33 . ".\\(?:\\(?:==\\|!!\\)\\|[!=]\\)")
		   (35 . ".\\(?:###\\|##\\|_(\\|[#(?[_{]\\)")
		   (36 . ".\\(?:>\\)")
		   (37 . ".\\(?:\\(?:%%\\)\\|%\\)")
		   (38 . ".\\(?:\\(?:&&\\)\\|&\\)")
		   (42 . ".\\(?:\\(?:\\*\\*/\\)\\|\\(?:\\*[*/]\\)\\|[*/>]\\)")
		   (43 . ".\\(?:\\(?:\\+\\+\\)\\|[+>]\\)")
		   (45 . ".\\(?:\\(?:-[>-]\\|<<\\|>>\\)\\|[<>}~-]\\)")
		   (47 . ".\\(?:\\(?:\\*\\*\\|//\\|==\\)\\|[*/=>]\\)")
		   (48 . ".\\(?:x[a-zA-Z]\\)")
		   (58 . ".\\(?:::\\|[:=]\\)")
		   (59 . ".\\(?:;;\\|;\\)")
		   (60 . ".\\(?:\\(?:!--\\)\\|\\(?:~~\\|->\\|\\$>\\|\\*>\\|\\+>\\|--\\|<[<=-]\\|=[<=>]\\||>\\)\\|[*$+~/<=>|-]\\)")
		   (61 . ".\\(?:\\(?:/=\\|:=\\|<<\\|=[=>]\\|>>\\)\\|[<=>~]\\)")
		   (62 . ".\\(?:\\(?:=>\\|>[=>-]\\)\\|[=>-]\\)")
		   (63 . ".\\(?:\\(\\?\\?\\)\\|[:=?]\\)")
		   (91 . ".\\(?:]\\)")
		   (92 . ".\\(?:\\(?:\\\\\\\\\\)\\|\\\\\\)")
		   (94 . ".\\(?:=\\)")
		   (119 . ".\\(?:ww\\)")
		   (123 . ".\\(?:-\\)")
		   (124 . ".\\(?:\\(?:|[=|]\\)\\|[=>|]\\)")
		   (126 . ".\\(?:~>\\|~~\\|[>=@~-]\\)"))))
      (dolist (char-regexp alist)
        (set-char-table-range composition-function-table
			      (car char-regexp)
			      `([,(cdr char-regexp)
			         0 font-shape-gstring]))))))





(leaf org-mode
  :setq ((org-todo-keyword-faces quote
				 (("WAIT" :foreground "#6272a4" :weight bold)
				  ("NEXT" :foreground "#f1fa8c" :weight bold)
				  ("CARRY/O" :foreground "#6272a4" :background "#373844" :weight bold))))
  :custom
  (org-link .  '((t (:foreground "#ebe087" :underline t))))
  (org-list-dt . '((t (:foreground "#bd93f9"))))
  (org-special-keyword . '((t (:foreground "#6272a4"))))
  (org-todo . '((t (:background "#272934" :foreground "#51fa7b" :weight bold))))
  (org-document-title . '((t (:foreground "#f1fa8c" :weight bold))))
  (org-done . '((t (:background "#373844" :foreground "#216933" :strike-through nil :weight bold))))
  (org-footnote . '((t (:foreground "#76e0f3"))))
  
  :config
  (leaf org-bullets
    :hook (org-mode-hook)
    :custom
    (org-bullets-bullet-list '("" "" "" "" "" "" "" "" "" ")"))))

;;;;;;;;;;;; My Settings Ends ;;;;;;;;;;;;

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
