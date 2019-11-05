#lang racket
(letrec ((map (λ (f ls)
                (letrec ((mapper (λ (ls)
                                   (if (empty? ls)
                                     '()
                                     (cons (f (car ls)) (mapper (cdr ls)))))))
                  (mapper ls)))))
  (map (λ (f) (f 0))
       (cons (λ (x) (add1 x))
             (cons (λ (x) (sub1 x))
                   '()))))