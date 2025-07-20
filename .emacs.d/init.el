;;; Core Emacs Setup
(package-initialize) ; Initializes the Emacs package system.

(setq custom-file "~/.emacs.d/emacs.custom.el") ; Sets the file where Emacs saves custom settings from `customize` interface.

(load-file "~/.emacs.d/emacs.rc/rc.el") ; Loads a custom initialization file, likely containing `rc/require` and other personal functions.

(add-to-list 'default-frame-alist `(font . "Iosevka Nerd Font-22")) ; Sets the default font and size for Emacs frames.

;; Theme Loading with Warning Suppression
(with-no-warnings
  (rc/require-theme 'gruber-darker))

;;; UI Enhancements & Basic Features
(ido-mode 1) ; Activates Ido mode for interactive completion in the minibuffer.
(ido-everywhere 1) ; Extends Ido completion to more commands.
;;(ido-ubiquitous-mode 1) ; Further extends Ido completion to nearly all interactive commands.
(menu-bar-mode 0) ; Disables the graphical menu bar.
(tool-bar-mode 0) ; Disables the graphical tool bar.
(scroll-bar-mode 0) ; Disables the graphical scroll bar.
(global-display-line-numbers-mode) ; Globally enables line numbers in all buffers.

;;; Smex (Enhanced M-x)
(rc/require 'smex 'ido-completing-read+) ; Loads Smex and its Ido completion dependency.
(global-set-key (kbd "M-x") 'smex) ; Binds `M-x` to `smex` for enhanced command completion.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command) ; Binds `C-c C-c M-x` to the original `M-x` (execute-extended-command).
(require 'ido-completing-read+) ; Ensures `ido-completing-read+` is loaded.

;;; Local Modes
(add-to-list 'load-path "~/.emacs.d/emacs.local/") ; Adds a local directory to Emacs's load path for custom modes.
(require 'simpc-mode) ; Loads the `simpc-mode` definition.
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode)) ; Associates .c, .h, .cpp, .hpp files with `simpc-mode`.
(require 'fasm-mode) ; Loads the `fasm-mode` definition.
(require 'basm-mode) ; Loads the `basm-mode` definition.


;;;;;;;;;;;;;;;;;;;;;;;;;;;; Extended Features Configuration ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Multiple Cursors
(rc/require 'multiple-cursors) ; Loads the `multiple-cursors` package.

(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines) ; Activates multiple cursors for selected lines.
(global-set-key (kbd "C->") 'mc/mark-next-like-this) ; Adds next occurrence to multiple cursors.
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this) ; Adds previous occurrence to multiple cursors.
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this) ; Adds all occurrences to multiple cursors.
(global-set-key (kbd "C-\"") 'mc/skip-to-next-like-this) ; Skips to next occurrence without adding cursor.
(global-set-key (kbd "C-:") 'mc/skip-to-previous-like-this) ; Skips to previous occurrence without adding cursor.

;;; Auto-Loaded Packages (No Specific Configuration Shown)
(rc/require ; Loads a list of packages that typically work out-of-the-box or have minimal custom setup.
 'scala-mode
 'd-mode
 'yaml-mode
 'glsl-mode
 'tuareg ; OCaml mode
 'lua-mode
 'less-css-mode
 'graphviz-dot-mode
 'clojure-mode
 'cmake-mode
 'rust-mode
 'csharp-mode
 'nim-mode
 'jinja2-mode
 'markdown-mode
 'purescript-mode
 'nix-mode
 'dockerfile-mode
 'toml-mode
 'nginx-mode
 'kotlin-mode
 'go-mode
 'php-mode
 'racket-mode
 'qml-mode
 'ag ; The Silver Searcher integration
 'elpy ; Python development environment
 'typescript-mode
 'rfc-mode
 'sml-mode
 'magit ; Git porcelain
 )

;;; C-Mode Specific Configuration
(setq-default c-basic-offset 4 ; Sets the default indentation for C-like modes to 4 spaces.
              c-default-style '((java-mode . "java") ; Sets Java style for Java mode.
                                (awk-mode . "awk") ; Sets AWK style for AWK mode.
                                (other . "bsd"))) ; Sets BSD style as default for other C-like modes.

(add-hook 'c-mode-hook (lambda () ; Adds a function to `c-mode-hook`.
                          (interactive)
                          (c-toggle-comment-style -1))) ; Sets the comment style in C mode (e.g., toggles between block and line comments).

;;; Magit (Git Interface)
(setq magit-auto-revert-mode nil) ; Disables automatic reverting (refreshing) of Magit buffers.

(global-set-key (kbd "C-c m s") 'magit-status) ; Binds `C-c m s` to open the Magit status buffer.
(global-set-key (kbd "C-c m l") 'magit-log) ; Binds `C-c m l` to open the Magit log buffer.

;;; LaTeX Mode
(add-hook 'tex-mode-hook ; Adds a function to `tex-mode-hook`.
          (lambda ()
            (interactive)
            (add-to-list 'tex-verbatim-environments "code"))) ; Adds "code" as a verbatim environment in LaTeX, which affects how it's handled (e.g., not spell-checked).

(setq font-latex-fontify-sectioning 'color) ; Configures `font-latex` to colorize sectioning commands in LaTeX.

;;; Eldoc Mode (Live Documentation)
(defun rc/turn-on-eldoc-mode () ; Defines a function to turn on Eldoc mode.
  (interactive)
  (eldoc-mode 1)) ; Activates Eldoc mode for the current buffer.

(add-hook 'emacs-lisp-mode-hook 'rc/turn-on-eldoc-mode) ; Enables Eldoc mode for Emacs Lisp files.

;;; Move Text (Rearrange Lines)
(rc/require 'move-text) ; Loads the `move-text` package.
(global-set-key (kbd "M-p") 'move-text-up) ; Binds `M-p` to move the current line (or region) up.

;;; Company (Code Completion)
(rc/require 'company) ; Loads the `company` package (likely a custom wrapper).
(require 'company) ; Ensures `company` is loaded (standard require).

(global-company-mode) ; Activates Company mode globally for all buffers.

(add-hook 'tuareg-mode-hook ; Adds a function to `tuareg-mode-hook`.
          (lambda ()
            (interactive)
            (company-mode 0))) ; Deactivates Company mode specifically for Tuareg (OCaml) buffers.

;;; Yasnippet (Snippets/Templates)
(rc/require 'yasnippet) ; Loads the `yasnippet` package (likely a custom wrapper).
(require 'yasnippet) ; Ensures `yasnippet` is loaded (standard require).

(setq yas/triggers-in-field nil) ; Prevents snippet expansion when inside a snippet field.
(setq yas-snippet-dirs '("~/.emacs.d/emacs.snippets/")) ; Sets the directory where Yasnippet looks for custom snippets.

(yas-global-mode 1) ; Activates Yasnippet globally for all buffers.

;;; Emacs Lisp Specific Configuration
(add-hook 'emacs-lisp-mode-hook ; Adds a function to `emacs-lisp-mode-hook`.
          '(lambda ()
              (local-set-key (kbd "C-c C-j") ; Binds `C-c C-j` locally in Emacs Lisp mode.
                             (quote eval-print-last-sexp)))) ; To evaluate and print the result of the last S-expression.
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode)) ; Associates files named "Cask" with `emacs-lisp-mode`.

;;; Word Wrap
(defun rc/enable-word-wrap () ; Defines a function to enable word wrap.
  (interactive)
  (toggle-word-wrap 1)) ; Activates visual word wrapping for the current buffer.

(add-hook 'markdown-mode-hook 'rc/enable-word-wrap) ; Enables word wrap for Markdown files.

;;; NXML Mode (XML/HTML Editing)
(add-to-list 'auto-mode-alist '("\\.html\\'" . nxml-mode)) ; Associates .html files with `nxml-mode`.
(add-to-list 'auto-mode-alist '("\\.xsd\\'" . nxml-mode)) ; Associates .xsd files with `nxml-mode`.
(add-to-list 'auto-mode-alist '("\\.ant\\'" . nxml-mode)) ; Associates .ant files with `nxml-mode`.

;;; Whitespace Mode (Visualizing and Cleaning Whitespace)
(defun rc/set-up-whitespace-handling () ; Defines a function for whitespace handling.
  (interactive)
  (whitespace-mode 1) ; Activates whitespace-mode to visualize problematic whitespace.
  (add-to-list 'write-file-functions 'delete-trailing-whitespace)) ; Automatically deletes trailing whitespace on save.

;; Hooks to enable whitespace handling for various modes:
(add-hook 'tuareg-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c++-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'simpc-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'emacs-lisp-mode 'rc/set-up-whitespace-handling)
(add-hook 'java-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'lua-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'rust-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'scala-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'markdown-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'haskell-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'python-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'erlang-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'asm-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'fasm-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'go-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'nim-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'yaml-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'porth-mode-hook 'rc/set-up-whitespace-handling)

;;; Simpc Mode Specific Configuration
(add-hook 'simpc-mode-hook ; Adds a function to `simpc-mode-hook`.
          (lambda ()
            (interactive)
            (setq-local fill-paragraph-function 'astyle-buffer))) ; Sets the paragraph filling function locally to `astyle-buffer`.

(load-file custom-file) ; Loads custom Emacs settings that are saved by the `customize` interface.
