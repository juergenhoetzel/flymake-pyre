;;; flymake-pyre.el --- test                         -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Jürgen Hötzel

;; Author: Jürgen Hötzel <juergen@hoetzel.info>
;; URL: http://github.com/juergenhoetzel/flymake-pyre
;; Package-Version: 20210310.1640
;; Maintainer: Jürgen Hötzel
;; Keywords: tools, languages
;; Package-Requires: ((flymake-quickdef "1.0.0") (emacs "27.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;; A flymake handler for Python files using pyre -*- lexical-binding: t; -*-

(require 'flymake-quickdef)

(defgroup flymake-pyre nil "flymake-pyre preferences." :group 'flymake-pyre)

(defcustom flymake-pyre-executable "pyre"
  "The pyre executable to use for syntax checking."
  :safe #'stringp
  :type 'string
  :group 'flymake-pyre)

(flymake-quickdef-backend flymake-pyre-backend
  :pre-let ((pyre-exec (executable-find flymake-pyre-executable)))
  :pre-check (unless pyre-exec (error "Not found pyre on PATH"))
  :write-type 'file
  :proc-form `(,pyre-exec)
  :search-regexp "^\\(.*?\\):\\([[:digit:]]+\\):\\([[:digit:]]+\\) \\(.*\\)"
  :prep-diagnostic
  (let* ((fname (match-string 1))
	 (lnum (string-to-number (match-string 2)))
	 (col (string-to-number (match-string 3)))
	 (msg (match-string 4))
	 (pos (flymake-diag-region fmqd-source lnum col))
	 (beg (car pos))
	 (end (cdr pos))
	 (type :warning))
    (when (string-suffix-p fname (buffer-file-name fmqd-source))
      (message "Adding: %s" fname)
      (list fmqd-source beg end type msg))))

;;;###autoload
(defun flymake-pyre-setup ()
  "Enable flymake backend."
  (interactive)
  (add-hook 'flymake-diagnostic-functions
	    #'flymake-pyre-backend nil t))

(provide 'flymake-pyre)
;;; flymake-pyre.el ends here
