#lang racket
(begin
  (define (string->list s)
    (string->list/a s (string-length s) '()))

  (define (string->list/a s i cs)
    (cond [(zero? i) cs]
          [else (string->list/a s (sub1 i)
                                (cons (string-ref s (sub1 i)) cs))]))

  (define (list . xs) xs)

  ;; function form of and (not short-circuiting)
  (define (and . bs)
    (if (empty? bs)
        #t
        (if (car bs)
            (apply and (cdr bs))
            #f)))

  (define (not x) (if x #f #t))

  ;; type Regexp =
  ;; | 'zero
  ;; | 'one
  ;; | `(char ,Char)
  ;; | `(plus ,Regexp ,Regexp)
  ;; | `(times ,Regexp ,Regexp)
  ;; | `(star ,Regexp)

  ;; Regexp String -> Boolean
  (define (accepts r s)
    (matcher r (string->list s) (λ (cs) (empty? cs))))

  ;; Regexp (Listof Char) ((Listof Char) -> Bool) -> Bool
  (define (matcher r cs k)
    (cond [(eq? r 'zero) #f]
          [(eq? r 'one) (k cs)]
          [(eq? (car r) 'char)
           (cond [(empty? cs) #f]
                 [else (and (char=? (car (cdr r)) (car cs)) (k (cdr cs)))])]
          [(eq? (car r) 'plus)
           (let ((r1 (car (cdr r)))
                 (r2 (car (cdr (cdr r)))))
             (if (matcher r1 cs k)
                 #t
                 (matcher r2 cs k)))]
          [(eq? (car r) 'times)
           (let ((r1 (car (cdr r)))
                 (r2 (car (cdr (cdr r)))))
             (matcher r1 cs (λ (cs) (matcher r2 cs k))))]
          [(eq? (car r) 'star)
           (let ((r (car (cdr r))))
             (letrec ((matcher* (λ (cs) (if (k cs) #t (matcher r cs matcher*)))))
               (matcher* cs)))]             
          [else 'impossible]))

  (and (accepts (list 'char #\a) "a")
       (not (accepts (list 'char #\a) "b"))
       (not (accepts (list 'char #\a) ""))
       (accepts (list 'plus (list 'char #\a) (list 'char #\b)) "a")
       (accepts (list 'plus (list 'char #\a) (list 'char #\b)) "b")
       (not (accepts (list 'plus (list 'char #\a) (list 'char #\b)) "c"))
       (not (accepts (list 'plus (list 'char #\a) (list 'char #\b)) ""))
       (not (accepts (list 'plus (list 'char #\a) (list 'char #\b)) "ab"))
       (accepts (list 'times (list 'char #\a) (list 'one)) "a")
       (accepts (list 'times (list 'one) (list 'char #\a)) "a")
       (accepts (list 'times
                      (list 'plus (list 'char #\a) (list 'char #\b))
                      (list 'plus (list 'char #\b) (list 'char #\a)))
                "ab")
       (not (accepts (list 'times (list 'char #\a) (list 'char #\a)) "a"))
       (accepts (list 'star (list 'char #\a)) "aaaaa")
       (not (accepts (list 'star (list 'char #\a)) "aaaaab"))
       (accepts (list 'star (list 'plus (list 'char #\a) (list 'char #\b))) "aaaaab")))
