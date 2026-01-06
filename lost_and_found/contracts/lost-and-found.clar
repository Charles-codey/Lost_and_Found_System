;; Lost and Found Contract
;; Blockchain-based lost and found tracking system

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-already-claimed (err u102))
(define-constant err-invalid-status (err u103))
(define-constant err-invalid-reward (err u104))
(define-constant err-item-not-claimable (err u105))
(define-constant err-insufficient-balance (err u106))
(define-constant err-invalid-category (err u107))