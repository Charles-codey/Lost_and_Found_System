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

;; Data Variables
(define-data-var item-nonce uint u0)
(define-data-var total-items-reported uint u0)
(define-data-var total-items-claimed uint u0)
(define-data-var total-items-found uint u0)

;; Data Maps
(define-map lost-items
  uint
  {
    reporter: principal,
    item-name: (string-ascii 100),
    description: (string-ascii 300),
    location: (string-ascii 100),
    date-reported: uint,
    status: (string-ascii 20),
    claimer: (optional principal),
    category: (string-ascii 50),
    reward: uint,
    verified: bool
  }
)

(define-map user-reports principal uint)
(define-map user-claims principal uint)
(define-map user-found-items principal uint)
(define-map item-ratings uint uint)
(define-map user-reputation principal uint)