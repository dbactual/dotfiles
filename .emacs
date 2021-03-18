;; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(add-to-list 'load-path (locate-user-emacs-file "lisp/"))
(require 'bs)
(require 'nord-theme)
(setq nord-region-highlight "snowstorm")
(load-theme 'nord t)

(setq ag-highlight-search t)

(menu-bar-mode -1)
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq inhibit-startup-screen t)

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)
(require 'ido-vertical-mode)
(ido-vertical-mode 1)
(setq ido-vertical-define-keys 'C-n-and-C-p-only)
(setq ido-enable-prefix nil)

(setq scroll-step            1
      scroll-conservatively  10000)

;; (require 'ido-vertical-mode)
;; (ido-mode 1)
;; (ido-vertical-mode 1)
;; (setq ido-vertical-define-keys 'C-n-and-C-p-only)

(global-set-key "\C-x\C-b" 'bs-show)
(global-set-key "\C-cg" 'goto-line)
(global-set-key (kbd "C-c m c") 'mc/edit-lines)
(global-set-key (kbd "C-x =") 'ff-find-related-file)

;; this is for both Control-arrow and Meta-arrow navigation
;; use C-q <key> to get the keycodes
(global-set-key (kbd "<M-up>") 'backward-paragraph) ;; xterm
(global-set-key (kbd "<M-down>") 'forward-paragraph) ;; xterm

(defun my-tab (arg)
  "Do the right thing about tabs"
  (interactive "*P")
  (cond
   ;; in magit?
   ((string-match-p (regexp-quote "^#<buffer \\*magit.*") (buffer-name))
    (magit-section-toggle))
   ;; in the minibuffer?
   ((minibuffer-window-active-p (frame-selected-window))
    (minibuffer-complete))
   ;; in front of a word?
   ((save-excursion
      (forward-char -1)
      (looking-at "[a-zA-Z0-9]"))
    (dabbrev-expand arg))
   ;; ok, just indent
   (t
    (indent-according-to-mode))))
;; respect case
(setq dabbrev-case-fold-search nil)
(global-set-key [tab] 'my-tab)
(global-set-key [?\t] 'my-tab)

(setq-default indent-tabs-mode nil)
(setq tab-width 4)
(setq tab-stop-list (number-sequence 4 120 4 ))

(fset 'yes-or-no-p 'y-or-n-p)

;; 81a1c1
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (multiple-cursors markdown-mode ag ido-vertical-mode aggressive-indent))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-comment-delimiter-face ((t (:foreground "#d08770"))))
 '(font-lock-comment-face ((t (:foreground "#d08770"))))
 '(show-paren-match ((t (:background "#b48ead"))))
 '(trailing-whitespace ((t (:background "black" :foreground "brightblack")))))
 
