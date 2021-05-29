#lang racket
(require "defense.rkt")
(require "offense.rkt")
(require "../../racket/ctf/offense.rkt")

(run offense-bot defense-bot #t)
