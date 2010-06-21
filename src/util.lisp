;;; util.lisp --- Utility functions for the vecmath package
;;;        _   _ _
;;;  _   _| |_(_) |
;;; | | | | __| | |
;;; | |_| | |_| | |
;;;  \__,_|\__|_|_|

;;;
;;; Copyright (C) 2010 Ole Arndt <ole@sugarshark.com>
;;;

(in-package :vecmath)

(macrolet ((define-ensure-foo (place)
               `(defun ,(symbolicate '#:ensure- place) (place &optional (default place))
                (if (atom place) default (,place place)))))
  (define-ensure-foo car)
  (define-ensure-foo cadr))

(defmacro with-elements (vars vector &body body)
  "Like with-slots, only for arrays.
Each VAR in VARS can either be a symbol, or a list with a symbol as
the first element and a (row major) offset into the array as the
second element.
Offsets start with zero by default and will be the offset of the left
neighboring VAR increased by one for each symbol without an explicit
offset value.
"
  (let ((vec (gensym))
        (index-counter 0))
    (declare (type fixnum index-counter))
    `(let ((,vec ,vector))
       (declare (ignorable ,vec))
       (symbol-macrolet ,(mapcar (lambda (var-entry)
                                   (let ((var-name
                                          (if (symbolp var-entry)
                                              var-entry
                                              (car var-entry)))
                                         (index
                                          (if (symbolp var-entry)
                                              index-counter
                                              (cadr var-entry))))
                                     (declare (type fixnum index))
                                     (setf index-counter (1+ index))
                                     `(,var-name
                                       (row-major-aref ,vec ,index))))
                                 vars)
         ,@body))))

(defmacro with-place (conc-name (&rest slots) form &body body)
  (let* ((sm-prefix (ensure-car conc-name))
         (acc-prefix (ensure-cadr conc-name)))
    `(with-accessors
           ,(mapcar (lambda (slot)
                      (list (symbolicate sm-prefix (ensure-car slot))
                            (symbolicate acc-prefix (ensure-cadr slot))))
                    slots)
         ,form
       ,@body)))


;;; util.lisp ends here
