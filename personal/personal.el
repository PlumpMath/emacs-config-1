;;; package -- This is the personal customization file for emacs (not aquamacs)
;;;
;;; Commentary:
;;;
;;; My personal customizations for Emacs.  I'm using Emacs prelude.
;;; I use Emacs mainly for Clojure.
;;;
;;; Code:
;;;
;;; ### General Custom Functions:
;;;
;;; Instant access to my personal init file.
;;; http://emacsredux.com/blog/2013/05/18/instant-access-to-init-dot-el/

(defun find-user-init-file ()
  "Edit the `user-init-file-personal', in another window."
  (interactive)
  (find-file-other-window user-init-file-personal))

;;; Disable bell on various commnand (like scrolling past the end of file)
(defun my-bell-function ()
  (unless (memq this-command
                '(isearch-abort abort-recursive-edit exit-minibuffer
                                keyboard-quit mwheel-scroll down up next-line previous-line
                                backward-char forward-char))
    (ding)))
(setq ring-bell-function 'my-bell-function)

(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name))
  (kill-new (file-truename buffer-file-name)))
(global-set-key "\C-cn" 'show-file-name)

(defun quick-copy-line ()
  "Copy the whole line that point is on and move to the beginning of the next line.
    Consecutive calls to this command append each line to the
    kill-ring."
  (interactive)
  (let ((beg (line-beginning-position 1))
        (end (line-beginning-position 2)))
    (if (eq last-command 'quick-copy-line)
        (kill-append (buffer-substring beg end) (< end beg))
      (kill-new (buffer-substring beg end))))
  (beginning-of-line 2))

(defun copy-to-end-of-line ()
  "Copy from point to the end of line without marking it"
  (interactive)
  (if (equal mark-active nil)
      (kill-ring-save (point) (line-end-position)) (kill-ring-save (point) (mark))))
;;(global-set-key "\M-w" 'copy-to-end-of-line)

(defun duplicate-current-line (&optional n)
  "Duplicate current line, make more than 1 copy given a numeric argument"
  (interactive "p")
  (save-excursion
    (let ((nb (or n 1))
    	  (current-line (thing-at-point 'line)))
      ;; when on last line, insert a newline first
      (when (or (= 1 (forward-line 1)) (eq (point) (point-max)))
    	(insert "\n"))
      ;; now insert as many time as requested
      (while (> n 0)
    	(insert current-line)
    	(decf n)))))
;;(global-set-key (kbd "C-S-d") 'duplicate-current-line)

(defun select-current-block ()
  "Select the current block of next between empty lines."
  (interactive)
  (let (p1 p2)
    (progn
      (if (re-search-backward "\n[ \t]*\n" nil "move")
          (progn (re-search-forward "\n[ \t]*\n")
                 (setq p1 (point) ) )
        (setq p1 (point) )
        )
      (if (re-search-forward "\n[ \t]*\n" nil "move")
          (progn (re-search-backward "\n[ \t]*\n")
                 (setq p2 (point) ))
        (setq p2 (point) )))
    (set-mark p1)))

(defun other-window-kill-buffer ()
  "Kill the buffer in the other window"
  (interactive)
  ;; Window selection is used because point goes to a different window
  ;; if more than 2 windows are present
  (let ((win-curr (selected-window))
        (win-other (next-window)))
    (select-window win-other)
    (kill-this-buffer)
    (select-window win-curr)))

(defun reindent-whole-buffer ()
  "Reindent the whole buffer."
  (interactive)
  (indent-region (point-min)
                 (point-max)))

;;(global-set-key (kbd "M-Q") 'reindent-whole-buffer)


;;; ### General Customizations
;;;
;;; Smart Tabs
(require 'smart-tab)
(global-smart-tab-mode 1)
(setq-default smart-tab-using-hippie-expand t)

;;; Dired
(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map (kbd "^")
              (lambda () (interactive) (find-alternate-file "..")))))

;;; (global-set-key (kbd "C-x K") 'other-window-kill-buffer)

;;; ### Org Mode
;; Set to the location of your Org files on your local system
(require 'org)
(setq org-directory "~/org")
;; Set to the name of the file where new notes will be stored
(setq org-mobile-inbox-for-pull "~/org/flagged.org")
;; Set to <your Dropbox root directory>/MobileOrg.
(setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")

;;; #### Programming Modes
;;;
;;; ### Clojure Mode
;;;
;;; Paredit adds a space after the "#" char which breaks anonymous funs
;;; Tells paredit not to put a space after a #
;;; http://stackoverflow.com/questions/11135315/prevent-paredit-from-inserting-a-space-when-inserting-parentheses-and-other-is

;; (defun paredit-space-for-delimiter-predicates-clojure (endp delimiter)
;;   "Do not automatically insert a space when a '#' precedes parentheses."
;;   (or endp
;;       (cond ((eq (char-syntax delimiter) ?\()
;;              (not (looking-back "#\\|#hash")))
;;             (else t))))

;; Note: to force deletion of one char in Paredit preceed with "C-u"
;; Note: to force insertion of one char in Paredit preceed with "C-q"

;;; (require 'rainbow-delimiters)
;;; (global-rainbow-delimiters-mode 1)

;;; Clojure-mode doesn't indent by default out of the box.

;; (add-hook 'clojure-mode-hook '(lambda ()
;;                                 (local-set-key (kbd "RET") 'newline-and-indent)))

;; (defun clojure-mode-paredit-hook ()
;;   (enable-paredit-mode)
;;   (add-to-list (make-local-variable 'paredit-space-for-delimiter-predicates)
;;                'paredit-space-for-delimiter-predicates-clojure))
;; (add-hook 'clojure-mode-hook 'clojure-mode-paredit-hook)

;;; ### Paredit-mode
;;(require 'paredit)
;;(add-hook 'clojure-mode-hook 'paredit-mode)
;;(global-set-key [f7] 'paredit-mode)
;;(define-key paredit-mode-map (kbd "C-d") 'er/expand-region)

;;; ### Nrepl - disabled. Using Cider instead
;; (require 'nrepl)
;; (setq nrepl-hide-special-buffers t)
;; (setq nrepl-popup-stacktraces nil)
;; (setq nrepl-history-file "~/.emacs.d/nrepl-history")
;; (add-hook 'nrepl-interaction-mode-hook 'nrepl-turn-on-eldoc-mode)

;;; Opens nrepl in the same window :
;; (add-to-list 'same-window-buffer-names "*nrepl*")
;; (add-hook 'nrepl-mode-hook 'paredit-mode)
;; (add-hook 'nrepl-mode-hook 'clojure-mode-paredit-hook)
;; (add-hook 'nrepl-mode-hook 'subword-mode)
;; (add-hook 'nrepl-mode-hook 'rainbow-delimiters-mode)
;; (global-set-key [f9] 'nrepl-jack-in)
;; (define-key nrepl-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc)

;; ### Nrepl-inspect
;; (load-file "/Users/zand/Library/nrepl-inspect.el")
;; (load-file "/Users/zand/Library/Application Support/Aquamacs Emacs/nrepl-inspect.el")
;; (load-file "~/.emacs.d/vendor/nrepl-inspect.el")
;; (require 'nrepl-inspect)
;; (define-key nrepl-repl-mode-map (kbd "C-c C-i") 'nrepl-inspect)

;; Note: nRepl inspect also requires the following config in ~/.lein/profiles.clj
;; {:user {:dependencies [[nrepl-inspect "0.3.0-SNAPSHOT"]]
;;        :repl-options {:nrepl-middleware
;;                      [inspector.middleware/wrap-inspect]}}}

;; ;; Nrepl-ritz (debugging) - Disabled doesn't play well with Cider
;; (add-hook 'nrepl-interaction-mode-hook 'my-nrepl-mode-setup)
;; (defun my-nrepl-mode-setup ()
;;   (require 'nrepl-ritz))

;; ;; Ritz middleware
;; (define-key nrepl-interaction-mode-map (kbd "C-c C-j") 'nrepl-javadoc)
;; (define-key nrepl-repl-mode-map (kbd "C-c C-j") 'nrepl-javadoc)
;; (define-key nrepl-interaction-mode-map (kbd "C-c C-a") 'nrepl-apropos)
;; (define-key nrepl-repl-mode-map (kbd "C-c C-a") 'nrepl-apropos)

;; ac-nrepl : Auto-complete for nrepl
;; (require 'ac-nrepl)
;; (add-hook 'nrepl-mode-hook 'ac-nrepl-setup)
;; (add-hook 'nrepl-interaction-mode-hook 'ac-nrepl-setup)
;; (eval-after-load "auto-complete" '(add-to-list 'ac-modes 'nrepl-mode))
;; (define-key nrepl-interaction-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc)

;;; ### Cider - Clojure Mode for Emacs
;; Enable eldoc in Clojure buffers
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
;; hide special nrepl buffers from buffer switcher
(setq nrepl-hide-special-buffers t)
;; Prevent the auto-display of the REPL buffer in a separate window after connection
;; (setq cider-repl-pop-to-buffer-on-connect nil)
;; Stop the error buffer from popping up while working in buffers other than the REPL:
(setq cider-popup-stacktraces nil)
;; Enable error buffer popping also in the REPL:
;; (setq cider-repl-popup-stacktraces t)

;; To auto-select the error buffer when it's displayed:
;; (setq cider-auto-select-error-buffer t)
;; To make the REPL history wrap around when its end is reached:
(setq cider-repl-wrap-history t)
;; To adjust the maximum number of items kept in the REPL history:
;; (setq cider-repl-history-size 1000) ; the default is 500
;; To store the REPL history in a file:
(setq cider-repl-history-file "~/.emacs.d/personal/nrepl-history")
;; Enable camelCase filename support
(add-hook 'cider-repl-mode-hook 'subword-mode)

;; Enable paredit mode
;;(add-hook 'cider-repl-mode-hook 'paredit-mode)
;; Enable smartparens mode - same as paredit but betterer
(add-hook 'cider-repl-mode-hook 'smartparens-strict-mode)
;; Enable rainbow delimiters
(add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode)

;; ### Cider Key bindings

;; Expand region is set globally below - disabling
;; (eval-after-load "cider"
;;   '(define-key cider-mode-map (kbd "C-d") 'er/expand-region))

(eval-after-load 'company
  '(progn
     (define-key company-active-map (kbd "\C-n") 'company-select-next)
     (define-key company-active-map (kbd "\C-p") 'company-select-previous)))

;; Auto complete - disabled to try out company mode which is part of prelude
;; (require 'auto-complete-config)
;; (ac-config-default)
;; (define-key ac-completing-map "\M-/" 'ac-stop) ; use M-/ to stop completion

;; Auto complete in nrepl
;; (require 'ac-nrepl)
;; (add-hook 'cider-repl-mode-hook 'ac-nrepl-setup)
;; (add-hook 'cider-mode-hook 'ac-nrepl-setup)
;; (eval-after-load "auto-complete"
;;   '(add-to-list 'ac-modes 'cider-repl-mode))

;; Trigger auto-complete using Tab in repl buffers:
;; (defun set-auto-complete-as-completion-at-point-function ()
;;   (setq completion-at-point-functions '(auto-complete)))
;; (add-hook 'auto-complete-mode-hook 'set-auto-complete-as-completion-at-point-function)
;; (add-hook 'cider-repl-mode-hook 'set-auto-complete-as-completion-at-point-function)
;; (add-hook 'cider-mode-hook 'set-auto-complete-as-completion-at-point-function)

;; Use ac-nrepl-popup-doc to show in-line docs in a clojure buffer
;; (eval-after-load "cider"
;;   '(define-key cider-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc))

;; ;; Use ac-nrepl-popup-doc to show in-line docs in a repl buffer
;; (eval-after-load "cider"
;;   '(define-key cider-repl-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc))

;;; ### AppleScript Mode
(autoload 'applescript-mode "applescript-mode"
  "Major mode for editing AppleScript source." t)
(add-to-list 'auto-mode-alist '("\\.applescript$" . applescript-mode))
(add-to-list 'auto-mode-alist '("\\.scpt$" . applescript-mode))

;;; ### Web-mode Config
;; (load-file "/Users/zand/.emacs.d/personal/web-mode-config.el")
;; Web mode customizations - seems complicated but that's how prelude does it.

;; (eval-after-load 'web-mode
;;   '(progn
;;      (defun web-mode-customizations ()
;;        ;; (setq web-mode-disable-autocompletion t)
;;        ;; (local-set-key (kbd "RET") 'newline-and-indent) 
;;        )
;;      (setq web-mode-customizations-hook 'web-mode-customizations)
;;      (add-hook 'web-mode-hook (lambda ()
;;                                 (run-hooks 'web-mode-customizations-hook)))))

;;; ### General Settings:
;;;
;;; Tell Emacs not to pause to accept keyboard and mouse input
;;; May speed up the Emacs display engine under some conditions
(setq redisplay-dont-pause t)

;;; Set path to personal config file (this one)
(setq user-init-file-personal "~/.emacs.d/personal/personal.el")

;;; Add the themes directory to the theme load path
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

;;; Disable whitespace mode:
(setq prelude-whitespace nil)

;;; Disable spell checking on the fly because it seems to slow down Emacs.
(setq prelude-flyspell nil)
(remove-hook 'text-mode-hook 'turn-on-flyspell)
(setq flyspell-issue-message-flag nil)
;;(ac-flyspell-workaround)

;;; Disable Guru Mode which prevents cetain keybinding and forces you to use the Emacs defaults
;;; which I think are not ergonomical (or easy to remember for that matter).
(defun disable-guru-mode ()
  (guru-mode -1))
(add-hook 'prelude-prog-mode-hook 'disable-guru-mode t)

;;; Make the cursor a bar
(setq-default cursor-type 'bar)

;;; Blink the cursor
(blink-cursor-mode t)

;;; Make smex display items vertically 
(require 'ido-vertical-mode)
(ido-vertical-mode 1)

;;; Projectile Configuration
;;; Not sure if this is required with prelude
(projectile-global-mode)
;;; Set the projectile completion system to grizzl
(setq projectile-completion-system 'grizzl)

;;; Disable the line highlight because it interferes with dark themes
;; (global-hl-line-mode -1)

;;; Key Frequencies
;;; And use keyfreq-show to see how many times you used a command.
(require 'keyfreq)
(keyfreq-mode 1)
(keyfreq-autosave-mode 1)

;;; To add additional packages:
;;; Add to the package list in .emacs.d/personal/00-packages.el
;;;
;;; ### Personal Keybindings:
;;;
;;; I have Keyboard Maestro setup to grab bindings at the OS level.
;;; Caps-Lock is set to Command in System Preferences.
;;; Movement keys are bound by KeyRemap4MacBook (KR4MB) to send Emacs specific movement keys: C-f, C-b, C-n, C-p
;;;
;;; Options for Mac Modifier keys are:
;;; mac-function-modifier
;;;
;;; mac-control-modifier
;;; mac-command-modifier
;;; mac-option-modifier
;;; mac-right-command-modifier
;;; mac-right-control-modifier
;;; mac-right-option-modifier
;;;
;;; values can be 'control, 'alt, 'meta, 'super, 'hyper, nil (setting to nil allows the OS to assign values)
;;; Example:
;;; (when (eq system-type 'darwin) ;; mac specific settings
;;;     (setq mac-option-modifier 'alt)
;;;     (setq mac-command-modifier 'meta)
;;;     (global-set-key [kp-delete] 'delete-char) ;; sets fn-delete to be right-delete)
;;;
;;; Make Command key send control (Caps-lock is aleady set to Command in Prefs)
;;; (setq mac-command-modifier 'control)
;;;
;;; Make option key send meta
;;; (setq mac-option-modifier 'meta)

;; Sets the mac function key to "control" in emacs
;; it's easier to hit the fn key than the control key on the mac keyboard
;; Example : (global-set-key (kbd "H-b") 'backward-word) ; H is for hyper
(setq ns-function-modifier 'control)

;;; How to Remove or Alter Minor Mode Keybindings from Minor Mode Keymaps
;;; http://emacsredux.com/blog/2013/09/25/removing-key-bindings-from-minor-mode-keymaps/
;;; 
;;; Another approach from Ergo Emacs
;;; http://ergoemacs.org/emacs/keyboard_shortcuts.html

;;; ### No Prefix Keybindings

;;; Note: Shift-Command-P is bound to 'smex in KR4MB
;;; Note: PageUp and PageDown and bound to Command-Alt-l and Command-Alt-k respectively in KR4MB

;;; Make C-q quit emacs
;;; (global-set-key (kbd "C-q") 'save-buffers-kill-terminal)

;;; Bind C-z to undo globally
(defalias 'redo 'undo-tree-redo)
(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "C-S-z") 'redo)

;;; unbind C-/ from undo-tree-undo
(define-key undo-tree-map (kbd "C-/") nil)

;;; unbind C-S-/ from undo-tree-redo
(define-key undo-tree-map (kbd "C-S-/") nil)

;;; Comment region
;;; This doesn't work for some reason, could be that I need to unbind it in the minor mode (undo)
;;;   or may be that I need to escape the forward slash... TBD
(global-set-key (kbd "C-/") 'comment-dwim)

;;; Set C-d to expand region
(global-set-key (kbd "C-d") 'er/expand-region)

;;; Hippie Expand
;;; Hippie expand is bound to tab via the smart-tab package
;;; This will tell Hippie Expand to use ispell completion to complete words (does not work)
(add-to-list 'hippie-expand-try-functions-list 'ispell-complete-word t)

;;; Projectile Keybindings
;;; (global-set-key (kbd "C-c h") 'helm-projectile)

;;; ### C-x prefixed commmands


;;; ### C-c prefixed commands

;;; Quick access to my personal init file
(global-set-key (kbd "C-c I") 'find-user-init-file)

;;; ### Look and Feel
;;;
(disable-theme 'zenburn)
;;; Set the theme to: base16-default
;;; (load-theme 'base16-zand)
;;; (load-theme 'zen-and-art)
(load-theme 'twilight-anti-bright-zand)

;;; Bring line wrapping into the 21st century
(global-visual-line-mode 1)

;;; Customize Mode-line to be more obvious which is the active buffer
;;; (set-face-foreground 'mode-line "white") ;; Doesn't work well with Zenburn Theme
;;; (set-face-background 'mode-line "light blue") Doesn't work well with Zenburn Theme

;;; Set the frame size
(if window-system
    (set-frame-size (selected-frame) 120 56)nil)

(provide 'personal)
;;; personal.el ends here
