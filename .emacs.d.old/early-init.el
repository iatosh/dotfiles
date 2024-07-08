;;; early-init.el --- My early-init script -*- coding: utf-8 ; lexical-binding: t -*-

(setq debug-on-error t)

;; init version check
(let ((my-init-el (concat user-emacs-directory "init.el"))
      (my-init-elc (concat user-emacs-directory "init.elc"))
      (my-early-el (concat user-emacs-directory "early-init.el"))
      (my-early-elc (concat user-emacs-directory "early-init.el")))
  (when (or (file-newer-than-file-p my-init-el my-init-elc)
	    (file-newer-than-file-p my-early-el my-early-elc))
    (message "WARN: init.el is old.\n")))


;; For slightly faster startup
(setq package-enable-at-startup nil)

;; Always load newest byte code
(setq load-prefer-newer t)

;; Inhibit resizing frame
(setq frame-inhibit-implied-resize t)


(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)

(tool-bar-mode 1)
(tool-bar-mode 0)
;; Faster to disable these here (before they've been initialized)
;(push '(fullscreen . maximized) default-frame-alist)
;(push '(menu-bar-lines . 0) default-frame-alist)
;(push '(tool-bar-lines . 0) default-frame-alist)
;(push '(vertical-scroll-bars) default-frame-alist)

;; Suppress flashing at startup
(setq inhibit-redisplay t)
(setq inhibit-message t)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq inhibit-redisplay nil)
			(setq inhibit-message nil)
			(redisplay)))

;; Startup setting
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq byte-compile-warnings '(cl-functions))



(provide 'early-init)

;;; early-init.el ends here
