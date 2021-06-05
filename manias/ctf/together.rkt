#lang racket
(require "defense.rkt")
(require "offense.rkt")
(require "../../racket/ctf/offense.rkt")

(run-dev offense-bot defense-bot #t)
