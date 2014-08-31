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

(defvar fuzz-dir-alist nil "An alist in the form of (directory-name . (list-of-files)).")
(defvar fuzz-cache-file "~/.emacs.d/fuzz-cache.el" "The file The Fuzz will use for caching.")
(setq fuzz-dir-alist nil)

;; Local variables
(defvar files-list)

;; Functions
(defun fuzz-dir-alist-set()
  "Read fuzz-dir-alist from fuzz-cache-file."
  (interactive)
  (load-file fuzz-cache-file)
  )

(defun fuzz-cache-directory(directory max-depth boring)
  "Cache DIRECTORY until MAX-DEPTH ignoring BORING for quicker searching in the future."
  (interactive)
  (setq files-list (directory-files directory t))
  (mapc (lambda(d) (if (not (or (equal (substring d (- (length d) 2)) "..") (equal (substring d (- (length d) 1)) ".")))
		       (if (file-directory-p d)
			   (fuzz-cache-directory-without-dumping d (- max-depth 1) boring)
			 (if (assoc directory fuzz-dir-alist) (setcdr (assoc directory fuzz-dir-alist) (cons d (cdr (assoc directory fuzz-dir-alist)))) (add-to-list 'fuzz-dir-alist `(,directory ,d))))
		     )
	  )
	files-list)
  (fuzz-dump-cache fuzz-cache-file)
  )

(defun fuzz-cache-directory-without-dumping(directory max-depth boring)
  "Cache DIRECTORY until MAX-DEPTH ignoring BORING, and don't save the list."
  (setq files-list (directory-files directory t))
  (mapc (lambda(d) (if (not (or (equal (substring d (- (length d) 2)) "..") (equal (substring d (- (length d) 1)) ".")))
		       (if (file-directory-p d)
			   (fuzz-cache-directory-without-dumping d (- max-depth 1) boring)
			 (if (assoc directory fuzz-dir-alist) (setcdr (assoc directory fuzz-dir-alist) (cons d (cdr (assoc directory fuzz-dir-alist)))) (add-to-list 'fuzz-dir-alist `(,directory ,d))))
		     )
	  )
	files-list)
  )

(defun fuzz-dump-cache(dump-file)
  "Dump the current fuzz cache to disk."
  (with-current-buffer (find-file-noselect dump-file)
    (erase-buffer)
    (print (list 'setq 'fuzz-dir-alist (list 'quote (symbol-value 'fuzz-dir-alist))) (current-buffer))
    (save-buffer)
    (kill-buffer)
    )
  )

(defun fuzz-clear-cache()
  "Clear fuzz cache."
  (interactive)
  (with-current-buffer (find-file-noselect fuzz-cache-file)
    (erase-buffer)
    (save-buffer)
    (kill-buffer)
    )
  )

(defun fuzz-find-file(search-string max-depth boring)
  "Fuzzy-find SEARCH-STRING in current directory and all subdirectories until MAX-DEPTH ignoring BORING."
  (interactive)
  (fuzz-cache-directory default-directory fuzz-max-depth fuzz-files-boring)
  )

(provide 'thefuzz)
;;; thefuzz.el ends here
