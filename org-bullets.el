;;; org-bullets.el --- Show bullets in org-mode as UTF-8 characters

;; Version: 0.2.4
;; Author: sabof
;; URL: https://github.com/sabof/org-bullets

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program ; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; The project is hosted at https://github.com/sabof/org-bullets
;; The latest version, and all the relevant information can be found there.

;;; Code:

(eval-when-compile (require 'cl))

(defgroup org-bullets nil
  "Display bullets as UTF-8 characters."
  :group 'org-appearance)

;; A nice collection of unicode bullets:
;; http://nadeausoftware.com/articles/2007/11/latency_friendly_customized_bullets_using_unicode_characters
(defcustom org-bullets-bullet-list
  '(;;; Large
    "◉"
    "○"
    "✸"
    "✿"
    ;; ♥ ● ◇ ✚ ✜ ☯ ◆ ♠ ♣ ♦ ☢ ❀ ◆ ◖ ▶
    ;;; Small
    ;; ► • ★ ▸
    )
  "List of bullets used in Org headings.
It can contain any number of symbols, which will be repeated."
  :group 'org-bullets
  :type '(repeat (string :tag "Bullet character")))

(defcustom org-bullets-face-name nil
  "Face used for bullets in Org mode headings.
If set to the name of a face, that face is used.
Otherwise the face of the heading level is used."
  :group 'org-bullets
  :type 'symbol)

(defvar org-bullets-bullet-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mouse-1] 'org-cycle)
    (define-key map [mouse-2] 'org-bullets-set-point-and-cycle)
    map)
  "Mouse events for bullets.
Should this be undesirable, one can remove them with

\(setcdr org-bullets-bullet-map nil\)")

(defun org-bullets-set-point-and-cycle (event)
  "Set `point' and where the user clicked and call `org-cycle'."
  (interactive "e")
  (mouse-set-point e)
  (org-cycle))

(defun org-bullets-level-char (level)
  (string-to-char
   (nth (mod (1- level)
             (length org-bullets-bullet-list))
        org-bullets-bullet-list)))

;;;###autoload
(define-minor-mode org-bullets-mode
  "Use UTF8 bullets in Org mode headings."
  nil nil nil
  (let* (( keyword
           `(("^\\*+ "
              (0 (let* (( level (- (match-end 0) (match-beginning 0) 1))
                        ( is-inline-task
                          (and (boundp 'org-inlinetask-min-level)
                               (>= level org-inlinetask-min-level))))
                   (compose-region (- (match-end 0) 2)
                                   (- (match-end 0) 1)
                                   (org-bullets-level-char level))
                   (when is-inline-task
                     (compose-region (- (match-end 0) 3)
                                     (- (match-end 0) 2)
                                     (org-bullets-level-char level)))
                   (when (facep org-bullets-face-name)
                     (put-text-property (- (match-end 0)
                                           (if is-inline-task 3 2))
                                        (- (match-end 0) 1)
                                        'face
                                        org-bullets-face-name))
                   (put-text-property (match-beginning 0)
                                      (- (match-end 0) 2)
                                      'face (list :foreground
                                                  (face-attribute
                                                   'default :background)))
                   (put-text-property (match-beginning 0)
                                      (match-end 0)
                                      'keymap
                                      org-bullets-bullet-map)
                   nil))))))
    (if org-bullets-mode
        (progn
          (font-lock-add-keywords nil keyword)
          (org-bullets--fontify-buffer))
      (save-excursion
        (goto-char (point-min))
        (font-lock-remove-keywords nil keyword)
        (while (re-search-forward "^\\*+ " nil t)
          (decompose-region (match-beginning 0) (match-end 0)))
        (org-bullets--fontify-buffer)))))

(defun org-bullets--fontify-buffer ()
  (when font-lock-mode
    (if (and (fboundp 'font-lock-flush)
             (fboundp 'font-lock-ensure))
        (save-restriction
          (widen)
          (font-lock-flush)
          (font-lock-ensure))
      (with-no-warnings
        (font-lock-fontify-buffer)))))

(provide 'org-bullets)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; org-bullets.el ends here
