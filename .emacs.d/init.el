(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;;(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages"))
(package-initialize)
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;;;;

(use-package ag)

(use-package f) ;; copilot
(use-package s) ;; copilot
(use-package dash) ;; copilot
(use-package editorconfig) ;; copilot
(use-package copilot
  :after (f s dash editorconfig)
  :load-path (lambda() (expand-file-name "copilot.el" user-emacs-directory))
  :config
  (add-hook 'prog-mode-hook 'copilot-mode)
  (defun copilot-tab()
    (interactive)
    (or (copilot-accept-completion)
    (my-tab nil)))
  (global-set-key [tab] 'copilot-tab)
  (global-set-key [?\t] 'copilot-tab)
  )

(use-package dockerfile-mode)
(use-package eglot
  :config
  (defun my-eglot-ensure-except-lisp ()
    "Run `eglot-ensure` except in Lisp-related modes."
    (unless (or (derived-mode-p 'emacs-lisp-mode))
      (eglot-ensure)))

  (add-hook 'prog-mode-hook 'my-eglot-ensure-except-lisp)
  ;;(add-hook 'prog-mode-hook 'eglot-ensure)
  )

(use-package emacs
  :bind
  (("C-x C-b" . bs-show)
   ("C-c e" . eval-region)
   ("C-x n" . next-error)
   ("C-x N" . previous-error)
   ("C-c r" . revert-buffer)
   ("C-x O"  . (lambda ()
                 (interactive)
                 (other-window -1))))
  :config
  (global-auto-revert-mode t)
  (setq use-short-answers t)
  (setq-default tab-width 4)
  (setq inhibit-startup-screen t)
  ;;(setq indent-line-function 'insert-tab)
  ;;(setq gc-cons-threshold (* 2 1000 1000)) ;; Make GC pauses faster by decreasing the threshold.
  (setq eldoc-echo-area-use-multiline-p nil)
  (setq lock-file-name-transforms
        '(("\\`/.*/\\([^/]+\\)\\'" "~/.emacs.d/aux/\\1" t)))
  (setq auto-save-file-name-transforms
        '(("\\`/.*/\\([^/]+\\)\\'" "~/.emacs.d/aux/\\1" t)))
  (setq backup-directory-alist
        '((".*" . "~/.emacs.d/aux/")))
  (setq warning-minimum-level :error)
  ;;(setq split-height-threshold nil) ;; always split vertically
  ;;(setq split-width-threshold 0) ;; always split vertically
  ;; Make scrolling less stuttered
  (customize-set-variable 'fast-but-imprecise-scrolling t)
  (customize-set-variable 'scroll-conservatively 101)
  (customize-set-variable 'scroll-margin 0)
  (customize-set-variable 'scroll-preserve-screen-position t)
  (savehist-mode 1) ;; Enable savehist-mode for command history
  (setq compilation-scroll-output t)
  (setq completion-styles '(basic substring flex))
  (winner-mode 1)
  ;;(global-hl-line-mode 1)
  ;;(setq native-comp-async-report-warnings-errors 'silent) ; emacs28 with native compilation
  ;;(setq compilation-auto-jump-to-first-error t)
  ;;(setq compilation-window-height 10)
  ;; Enable horizontal scrolling
  (setq mouse-wheel-tilt-scroll t)
  (setq mouse-wheel-flip-direction t)
  (setq-default mode-line-buffer-identification
    (list 'buffer-file-name
      (propertized-buffer-identification "%12f")
      (propertized-buffer-identification "%12b")))
  (add-hook 'before-save-hook 'whitespace-cleanup)
  (global-set-key (kbd "C-x 2") (lambda () (interactive)(split-window-vertically) (other-window 1)))
  (global-set-key (kbd "C-x 3") (lambda () (interactive)(split-window-horizontally) (other-window 1)))
  (xterm-mouse-mode 1)
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (show-paren-mode 1)
  (defun my-python-ruff-fix-before-save ()
    "Run `ruff --fix` on the current file before saving."
    (interactive)
    (when (eq major-mode 'python-mode)
      (let ((ruff-command (format "ruff --fix %s"
                                  (shell-quote-argument (buffer-file-name)))))
        (shell-command ruff-command)
        ;; Optionally, reload the buffer to get changes
        (revert-buffer t t t))))

  (defun my-python-black-before-save ()
    "Run `black` on the current file before saving."
    (interactive)
    (when (eq major-mode 'python-mode)
      (let ((black-command (format "black %s"
                                  (shell-quote-argument (buffer-file-name)))))
        (shell-command black-command)
        ;; Optionally, reload the buffer to get changes
        (revert-buffer t t t))))

  ;; (add-hook 'before-save-hook 'my-python-ruff-fix-before-save)
  ;; (add-hook 'before-save-hook 'my-python-black-before-save)

  )
(use-package go-mode)
(use-package gptel
  :load-path "gptel"
  :config
  (load "gptel-curl")
  (defvar gptel--gpt4all
    (gptel-make-openai "GPT4All"
      :host "localhost:4891"
      ;;:key "does-not-matter"
      :protocol "http"
      :models '("mistral-7b-openorca.Q4_0.gguf")))


  (defvar gptel--perplexity
    (gptel-make-openai "Perplexity"         ;Any name you want
      ;;:header (lambda () `(("Authorization" . ,(concat "Bearer " (gptel--get-api-key )))))
      :host "api.perplexity.ai"
      :key 'gptel-api-key
      ;;:key "your-api-key"                   ;can be a function that returns the key
      ;;:protocol "https"
      :endpoint "/chat/completions"
      :stream t
      :models '(;; has many more, check perplexity.ai
                "pplx-7b-chat"
                "pplx-70b-chat"
                "pplx-7b-online"
                "pplx-70b-online"
                "codellama-34b-instruct"
                "codellama-70b-instruct")))

  ;; better centering behavior during isearch
  (defadvice isearch-update (before my-isearch-update activate)
    (sit-for 0)
    (if (and
         ;; not the scrolling command
         (not (eq this-command 'isearch-other-control-char))
         ;; not the empty string
         (> (length isearch-string) 0)
         ;; not the first key (to lazy highlight all matches w/o recenter)
         (> (length isearch-cmds) 2)
         ;; the point in within the given window boundaries
         (let ((line (count-screen-lines (point) (window-start))))
           (or (> line (* (/ (window-height) 4) 3))
               (< line (* (/ (window-height) 9) 1)))))
        (let ((recenter-position 0.3))
          (recenter '(4)))))

  (add-hook 'gptel-post-stream-hook 'db/gptel-auto-scroll)
  (add-hook 'gptel-post-response-functions 'gptel-end-of-response)
  ;;(customize-set-variable 'gptel-default-mode 'text-mode)
  ;; perplexity.ai
  ;;(customize-set-variable 'gptel-backend gptel--perplexity)
  ;;(customize-set-variable 'gptel-model "gpt-4-turbo-preview")
  (customize-set-variable 'gptel-model "gpt-3.5-turbo-0125")
  )
(use-package jsonrpc) ;; an updated version is required for other packages to work properly
(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)
         ("C-x y" . db/git-br)
         ("C-x p =" . magit-diff-buffer-file)
         ("C-x f" . db/dbt-cloud-fixup)
         )
  :config
  (setq magit-commit-skip-confirm t)
  (transient-append-suffix 'magit-commit "c"
    '("g" "Generate commit message" db/ai-gen-commit-msg))


  ;; (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1); fullframe magit
  )
(use-package marginalia)
(use-package markdown-mode)
(use-package protobuf-mode)
(use-package recentf
  :bind
  ("C-x C-r" . recentf)
  :config
  (setq recentf-max-menu-items 2000)
  (setq recentf-max-saved-items 2000))
(use-package terraform-mode)
(use-package yaml-mode)
(use-package vertico
  :config
  (define-key vertico-map "\r" #'vertico-directory-enter)
  (define-key vertico-map "\d" #'vertico-directory-delete-char)
  (define-key vertico-map "\M-\d" #'vertico-directory-delete-word)
  (define-key vertico-map "\C-f" #'vertico-exit)
  (customize-set-variable 'vertico-cycle t)
  (vertico-mode 1))
(use-package vterm
  :bind
  ("C-c C-v" . vterm-copy-mode)
  )
(use-package xref
  :hook (xref-after-return . recenter))

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
    (indent-for-tab-command))))
;;    (indent-according-to-mode))))

(defun db/pbcopy (&optional b e)
  (interactive "r") ;; The argument to interactive tells Emacs to pass
                    ;; the region (point and mark) in as the first two
                    ;; arguments to the command.
  (shell-command-on-region b e "pbcopy"))


(defvar db/current-date-time-format "%Y-%M-%d %H:%M:%S"
  "Format of date to insert with `insert-current-date-time' func
See help of `format-time-string' for possible replacements")

(defun db/insert-current-date-time ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
       (interactive)
       (insert (format-time-string db/current-date-time-format (current-time)))
       (insert "\n")
       )

;;(add-to-list 'load-path "~/src/gptel-extensions.el")
;;(require 'gptel-extensions)

(defvar db/temp-commit-msg nil "Temporary storage for the generated commit message.")
(defun my/insert-generated-commit-msg ()
  (when db/temp-commit-msg
    ;; Remove leading and trailing double-quotes from the commit message
    (let ((clean-msg (string-trim db/temp-commit-msg "\"" "\"")))
      (goto-char (point-min))
      (insert clean-msg)
      ;; Save the buffer after inserting the commit message
      (save-buffer))
    ;; Clear the temporary variable to avoid re-insertion
    (setq db/temp-commit-msg nil)
    ;; Remove the hook to clean up
    (remove-hook 'git-commit-setup-hook 'my/insert-generated-commit-msg)))

(defun db/generate-and-edit-commit-message ()
  (interactive)
  (let* ((diff-command "git diff --cached")
         (diff-output (shell-command-to-string diff-command)))
    (when (string= diff-output "") (user-error "No staged changes found."))
    (let ((prompt (concat "Generate a concise commit message in a single sentence for the following changes:\n" diff-output)))
      (gptel-request
       prompt
       :callback
       (lambda (response info)
         (if (not response)
             (message "Failed to generate commit message: %s" (plist-get info :status))
           (setq db/temp-commit-msg response) ;; Set the global variable
           (add-hook 'git-commit-setup-hook 'my/insert-generated-commit-msg)
           (magit-commit-create '("-e"))))))))


(defun db/ai-gen-commit-msg ()
  (interactive)
  (let* ((diff-command "git diff --cached")
         (diff-output (shell-command-to-string diff-command)))
    (when (string= diff-output "") (user-error "No staged changes found."))
    (setenv "AI_GEN_COMMIT_MSG" "1")
    (magit-commit-create '("-e")))
    (setenv "AI_GEN_COMMIT_MSG" ""))


(defvar gptel-quick--history nil)
(defun db/gptel-quick--old (prompt)
  (interactive (list (read-string "Ask perplexity: " nil gptel-quick--history)))
  (when (string= prompt "") (user-error "A prompt is required."))
  (gptel-request
      prompt
    :callback
    (lambda (response info)
      (if (not response)
          (message "gptel-quick failed with message: %s" (plist-get info :status))
        (let ((buffer (get-buffer-create "*gptel-quick*")))
          (with-current-buffer buffer
            (let ((inhibit-read-only t))
              (erase-buffer)
              (insert response))
            (special-mode))
           (pop-to-buffer buffer))))))


(defun db/gptel-quick (prompt)
  (interactive (list (read-string "Ask perplexity: " nil gptel-quick--history)))
  (when (string= prompt "") (user-error "A prompt is required."))
  (gptel-request
      (if (use-region-p)
          (buffer-substring (region-beginning) (region-end)) ; use just the region
        (buffer-substring-no-properties (point-min) (point-max)) ; otherwise use the whole buffer
        )
    :system (concat "Respond concisely, avoid all extra detail other than what is being asked: " prompt)
    :callback
    (lambda (response info)
      (if (not response)
          (message "gptel-quick failed with message: %s" (plist-get info :status))
        (let ((buffer (get-buffer-create "*gptel-quick*")))
          (with-current-buffer buffer
            (let ((inhibit-read-only t))
              (erase-buffer)
              (insert response))
            (special-mode))
           (pop-to-buffer buffer))))))


(defun db/diff-comment ()
  (interactive)
  (gptel-request
      (buffer-substring-no-properties (point-min) (point-max)) ;the prompt
    :system "You are a large language model and a careful programmer. Provide a concise commit message for the following diff. Only respond with the commit message and nothing else so that it is suitable for use in git."
    :callback
    (lambda (response info)
      (if (not response)
          (message "gptel-quick failed with message: %s" (plist-get info :status))
        (message "Reponse copied: %s" response)
        (with-temp-buffer
          (insert response)
          (shell-command-on-region (point-min) (point-max) "pbcopy" t t))
        (kill-new response)))))



;; dbt-labs

(defun my-vterm-exit-hook (proc name)
  (message "Process %s %s has exited" name proc)
  )

(add-hook 'vterm-exit-functions 'my-vterm-exit-hook)


(defun my-vterm-execute-command (command &optional vterm-buffer-name)
  "Open a vterm buffer, execute the given COMMAND, and display it without stealing focus from the previously active buffer."
  (interactive "sCommand: ")
  (unless vterm-buffer-name
    (setq vterm-buffer-name "*vterm-command*"))
  (if (require 'vterm nil 'noerror)
      (let ((vterm-buffer (get-buffer-create vterm-buffer-name)))
        ;; Ensure the buffer is in vterm-mode.
        (with-current-buffer vterm-buffer
          (unless (eq major-mode 'vterm-mode)
            (vterm-mode)))
        ;; Display the vterm buffer if not already visible, but do not switch focus.
        (unless (get-buffer-window vterm-buffer 'visible)
          (display-buffer vterm-buffer '(display-buffer-below-selected)))
        ;; Send the command to the vterm buffer.
        (with-current-buffer vterm-buffer
          (vterm-send-string command)
          (vterm-send-return)))
    (message "vterm is not installed. Please install it to use this function.")))

(defvar db/dbt-cloud-tests-history nil
  "History for `db/dbt-cloud-tests' prompt.")

(defun db/dbt-cloud-tests ()
  "Run tests as a custom compile command."
  (interactive)
  (let* ((last-value (car db/dbt-cloud-tests-history))
        (prompt (concat "Enter additional parameters: "
                         (if last-value (concat "(default: " last-value ") ") "")))
        (params (completing-read prompt db/dbt-cloud-tests-history nil nil nil 'db/dbt-cloud-tests-history)))
    (setq db/dbt-cloud-tests-history (cons params (delete params db/dbt-cloud-tests-history)))
    (my-vterm-execute-command (concat "cd ~/src/dbt-cloud/sinter &&  task -d ~/src/building-blocks sync:source:dbt-cloud-app && task -d ~/src/building-blocks test:app -- " params) "*vterm-dbt-cloud-tests*")))


(defun db/git-br ()
  (interactive)
  (let ((output-buffer (get-buffer-create "*MRU Branches*")))
    (with-current-buffer output-buffer
      ;; Temporarily disable read-only mode to modify the buffer
      (let ((buffer-read-only nil))
        (erase-buffer)
        ;; Insert the output of the git command. Consider using `git for-each-ref` as mentioned earlier for MRU sorting
        (insert (shell-command-to-string "git br")))
      ;; Enable `special-mode` again to make the buffer read-only with navigational keybindings
      (special-mode))
    ;; Display the buffer
    (pop-to-buffer output-buffer)))


(defun db/dbt-cloud-fixup ()
  "Black and ruff."
  (interactive)
  (let* ((compilation-buffer-name "*vterm-dbt-cloud-fixup*"))
    (compilation-start (concat "(cd ~/src/dbt-cloud && black sinter && ruff --fix sinter)") nil (lambda (more) compilation-buffer-name))
    (let ((compilation-buffer (get-buffer-create compilation-buffer-name)))
      (unless (get-buffer-window compilation-buffer 'visible)
        (display-buffer compilation-buffer '(display-buffer-below-selected)))
      (select-window (get-buffer-window compilation-buffer 'visible))
      )))


(defun db/open-dbt-cloud-url ()
  "Open a URL that includes the suffix of the current buffer's file path after '/Users/db/src/dbt-cloud'."
  (interactive)
  (let ((file-path (buffer-file-name)))
    (if file-path
        (let* ((prefix "/Users/db/src/dbt-cloud")
               (suffix (string-remove-prefix prefix file-path))
               (current-line (line-number-at-pos))
               (url (concat "https://github.com/dbt-labs/dbt-cloud/tree/master" suffix "#L" (format "%d" current-line)))) ; Ensure the base URL is correct
          (message url)
          (shell-command (concat "/Applications/Vivaldi.app/Contents/MacOS/Vivaldi " url))
      (message "Buffer is not visiting a file!")))))


(defun db/magit-convert-git-url-to-http (url)
  "Convert a Git remote URL to an HTTP URL."
  (replace-regexp-in-string
   "\\`git@\\([^:]+\\):\\(.*\\)\\'" "http://\\1/\\2"
   (replace-regexp-in-string
    "\\.git\\'" "" url)))

(defun db/open-magit-remote-repo ()
  "Open the remote repository URL in a browser from the Magit status buffer."
  (interactive)
  (let ((url (magit-get "remote" "origin" "url")))
    (if url
        (browse-url (db/magit-convert-git-url-to-http url))
      (message "Remote 'origin' not found or has no URL."))))


(defun db/git-br ()
  (interactive)
  (let ((output-buffer (get-buffer-create "*MRU Branches*")))
    (with-current-buffer output-buffer
      ;; Temporarily disable read-only mode to modify the buffer
      (let ((buffer-read-only nil))
        (erase-buffer)
        ;; Insert the output of the git command. Consider using `git for-each-ref` as mentioned earlier for MRU sorting
        (insert (shell-command-to-string "git br")))
      ;; Enable `special-mode` again to make the buffer read-only with navigational keybindings
      (special-mode))
    ;; Display the buffer
    (pop-to-buffer output-buffer)))


(defun db/notes-open-year-month-file ()
  "Generate filename based on current year and month in ~/Documents/notes/ directory and create the file if it does not exist."
  (let* ((year (format-time-string "%Y"))
         (month (format-time-string "%m"))
         (directory "~/Documents/notes/")
         (filename (format "%s%s-%s.txt" directory year month)))
    ;; Check if the file exists
    (unless (file-exists-p filename)
      ;; If the file doesn't exist, create it
      (write-region "" nil filename))
    filename))

(defun db/notes-open ()
  "Open a file with filename based on current year and month in ~/Documents/notes/ directory and scroll to the end for editing."
  (interactive)
  (let ((filename (db/notes-open-year-month-file)))
    (find-file filename)
    (goto-char (point-max))))


(defun db/gptel-auto-scroll ()
  "Scroll the current buffer so the last line is at the bottom of the window."
  (interactive)
  (let ((window-line-count (count-lines (window-start) (point-max))))
    (if (> window-line-count (window-body-height))
        (progn
          (goto-char (point-max))
          (recenter -1))
      (goto-char (point-max)))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(indent-tabs-mode nil)
 '(package-selected-packages
   '(vterm vertico yaml-mode terraform-mode protobuf-mode markdown-mode marginalia magit go-mode dockerfile-mode editorconfig ag)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-blue ((t (:foreground "lightskyblue"))))
 '(highlight ((t (:background "darkslategray")))))
