(require 'package)
(add-to-list 'package-archives
             '("melpa" .
               "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; My packages
(setq prelude-packages (append '(
                                 keyfreq
                                 zen-and-art-theme
                                 base16-theme
                                 applescript-mode
                                 js2-mode
                                 smart-tab
                                 ;; paredit
                                 auto-complete
                                 ido-vertical-mode
                                 ag
                                 srefactor
                                 ) prelude-packages))

;; Install my packages
(prelude-install-packages)
