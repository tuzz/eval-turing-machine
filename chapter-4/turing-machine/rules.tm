; The following is a Turing Machine description that evaluates expressions
; as described in Chapter 4 of Types and Programming Languages.
;
; Key: t=TmTrue, f=TmFalse, i=TmIf, 0=TmZero, s=TmSucc, p=TmPred, z=TmIsZero
;
; Example expression:
;   (if
;     (iszero (if true zero (succ zero)))
;     (pred (succ (succ zero)))
;     (succ false)
;   )
;
; Tape for example: izit0s0pss0sf
;
; Other examples to try:
;
; pppssss0,
; ppppsss0,
; it0s0,
; iiittttftittf,
; pssit0s0,
; zppssssifits00pppss0

; we're going to evaluate right-left so scan past everything
start * * r start
start _ _ l eval

; skip past values because they don't evaluate to anything
eval t t l eval
eval f f l eval
eval 0 0 l eval
eval s s l eval

; the evaluation rules are simpler because of right-left evaluation
eval i x r eval-if
eval p x r eval-pred
eval z x r eval-iszero
eval _ _ r halt-accept

; evaluate TmIf
eval-if t _ r copy-if-true
eval-if f _ r clear1
if-true-copied * * r if-true-copied
if-true-copied _ _ l if-true-clear
if-true-clear * * r clear2

; evaluate TmPred
eval-pred 0 0 r eval-pred-zero
eval-pred-zero * * l copy-eval
eval-pred s s r eval-pred-s
eval-pred-s * * l isnumeric1
eval-pred-s-clear s _ r copy-eval

; evaluate TmIsZero
eval-iszero 0 _ l eval-iszero-true
eval-iszero s s r eval-iszero-s
eval-iszero-s * * l isnumeric2
eval-iszero-true x t l eval
eval-iszero-false s _ r eval-iszero-false
eval-iszero-false 0 _ r eval-iszero-false
eval-iszero-false * * l eval-iszero-scan
eval-iszero-scan _ _ l eval-iszero-scan
eval-iszero-scan x f l eval

; copy a value to an x marked on the left, then return to if-true-copied
copy-if-true _ _ r copy-if-true
copy-if-true s _ l copy-if-true-s
copy-if-true 0 _ l copy-if-true-0
copy-if-true t _ l copy-if-true-t
copy-if-true f _ l copy-if-true-f
copy-if-true-s _ _ l copy-if-true-s
copy-if-true-s x s r copy-if-true-next
copy-if-true-0 _ _ l copy-if-true-0
copy-if-true-0 x 0 l copy-if-true-scan
copy-if-true-t _ _ l copy-if-true-t
copy-if-true-t x t l copy-if-true-scan
copy-if-true-f _ _ l copy-if-true-f
copy-if-true-f x f l copy-if-true-scan
copy-if-true-next _ x r copy-if-true
copy-if-true-scan s s l copy-if-true-scan
copy-if-true-scan * * r if-true-copied

; copy a value to an x marked on the left, then return to eval
copy-eval _ _ r copy-eval
copy-eval s _ l copy-eval-s
copy-eval 0 _ l copy-eval-0
copy-eval t _ l copy-eval-t
copy-eval f _ l copy-eval-f
copy-eval-s _ _ l copy-eval-s
copy-eval-s x s r copy-eval-next
copy-eval-0 _ _ l copy-eval-0
copy-eval-0 x 0 l copy-eval-scan
copy-eval-t _ _ l copy-eval-t
copy-eval-t x t l copy-eval-scan
copy-eval-f _ _ l copy-eval-f
copy-eval-f x f l copy-eval-scan
copy-eval-next _ x r copy-eval
copy-eval-scan s s l copy-eval-scan
copy-eval-scan * * r eval

; clear a value from the tape
clear1 _ _ r clear1
clear1 t _ l clear1-scan
clear1 f _ l clear1-scan
clear1 0 _ l clear1-scan
clear1 s _ r clear1
clear1-scan _ _ l clear1-scan
clear1-scan * * r copy-eval

; clear a value from the tape
clear2 _ _ r clear2
clear2 t _ l clear2-scan
clear2 f _ l clear2-scan
clear2 0 _ l clear2-scan
clear2 s _ r clear2
clear2-scan _ _ l clear2-scan
clear2-scan * * l eval ; the state to return to

; check if a value is numeric, halts otherwise
isnumeric1 0 0 l isnumeric1-true
isnumeric1 s s r isnumeric1
isnumeric1-true 0 0 l isnumeric1-true
isnumeric1-true s s l isnumeric1-true
isnumeric1-true * * r eval-pred-s-clear ; the state to return to

; check if a value is numeric, halts otherwise
isnumeric2 0 0 l isnumeric2-true
isnumeric2 s s r isnumeric2
isnumeric2-true 0 0 l isnumeric2-true
isnumeric2-true s s l isnumeric2-true
isnumeric2-true * * r eval-iszero-false ; the state to return to
