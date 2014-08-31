;;; thefuzz --- Fuzzy file searching in emacs
;;; Commentary:
;; The Fuzz is a plugin for emacs which allows users to match files in the current directory or any subdirectories using fuzzy file matching. It will place precedence on the filename rather than the folder name by default
;; For example:
;; diin could match ./docs/info/input
;;; Code:

;; Global variables
(defvar fuzz-max-depth 5 "Max number of subfolders to search [Default: 5].")
(defvar fuzz-files-boring '(
		 "[a-zA-Z].*~"
		 ))

(defvar fuzz-dir-alist '("blank" nil) "An alist in the form of (directory-name . (list-of-files)).")

;; Local variables
(defvar files-list)

;; Functions
(defun fuzz-dir-alist-set()
  "Read thefuzz.cache file and generate alist"
  )

(defun fuzz-cache-directory(directory max-depth boring)
  "Cache DIRECTORY until MAX-DEPTH ignoring BORING for quicker searching in the future."
  (interactive)
  (setq files-list (directory-files directory t))
  (mapc (lambda(d) (if (not (or (equal (substring d (- (length d) 2)) "..") (equal (substring d (- (length d) 1)) ".")))
		       (if (file-directory-p d)
			(fuzz-cache-directory d (- max-depth 1) boring)
		      (if (assoc directory fuzz-dir-alist) (add-to-list (assoc 'directory 'fuzz-dir-alist) d) (add-to-list 'fuzz-dir-alist `(,directory ,d))))
	 ))
	files-list)
  )

(defun fuzz-find-file(search-string max-depth boring)
  "Fuzzy-find SEARCH-STRING in current directory and all subdirectories until MAX-DEPTH ignoring BORING."
  (interactive)
  )

(provide 'thefuzz)
;;; thefuzz.el ends here
