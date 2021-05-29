#lang racket
(require "defense.rkt")
(require "offense.rkt")
(require "../../racket/ctf/offense.rkt")
(require net/rfc6455)
(require net/url)

(run offense-bot defense-bot #f)
