;;; thefuzz --- Fuzzy file searching in Emacs
;;; Commentary:
;; The Fuzz is a plugin for Emacs which allows users to match files in the current directory or any subdirectories using fuzzy file matching.  It will place precedence on the filename rather than the folder name by default
;; For example:
;; diin could match ./docs/info/input
;;; Code:

;; Global variables
(defvar fuzz-max-depth 5 "Max number of subfolders to search [Default: 5].")
(defvar fuzz-files-boring '(
			    ".git"
			    ))

(defvar fuzz-dir-alist nil "An alist in the form of (directory-name . (list-of-files)).")
(setq fuzz-dir-alist nil)
(defvar helm-source-thefuzz
  '((name . "The Fuzz")
    (candidates . fuzz-dir-alist)
    (action . (("Open file" . fuzz-open-file)))))


;; Local variables
(defvar files-list)
(defvar fuzz-isboring)
(setq fuzz-isboring nil)

;; Functions
(defun fuzz-cache-directory (directory max-depth boring)
  "Cache DIRECTORY until MAX-DEPTH ignoring BORING."
  (setq files-list (directory-files directory t))
  (setq )
  (mapc (lambda(d) (if (or (not (or (equal (substring d (- (length d) 2)) "..")
				    (equal (substring d (- (length d) 1)) "."))))
		       (if (file-directory-p d)
			   (fuzz-cache-directory d (- max-depth 1) boring)
			 (add-to-list 'fuzz-dir-alist d)))) files-list))

(defun fuzz-find-file ()
  "Fuzzy-find SEARCH-STRING in current directory and all subdirectories until MAX-DEPTH ignoring BORING."
  (interactive)
  (setq fuzz-dir-alist nil)
  (fuzz-cache-directory default-directory fuzz-max-depth fuzz-files-boring)
  (helm :sources '(helm-source-thefuzz)))

(defun fuzz-open-file (name)
  "Used to open a file NAME."
  (find-file name))

(provide 'thefuzz)
;;; thefuzz.el ends here
