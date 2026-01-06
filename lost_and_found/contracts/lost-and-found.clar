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

;; Read-only functions
;; #[allow(unchecked_data)]
(define-read-only (get-item (item-id uint))
  (map-get? lost-items item-id)
)

;; #[allow(unchecked_data)]
(define-read-only (get-user-report-count (user principal))
  (default-to u0 (map-get? user-reports user))
)

;; #[allow(unchecked_data)]
(define-read-only (get-user-claim-count (user principal))
  (default-to u0 (map-get? user-claims user))
)

;; #[allow(unchecked_data)]
(define-read-only (get-user-found-count (user principal))
  (default-to u0 (map-get? user-found-items user))
)

;; #[allow(unchecked_data)]
(define-read-only (get-item-nonce)
  (var-get item-nonce)
)

;; #[allow(unchecked_data)]
(define-read-only (get-total-items-reported)
  (var-get total-items-reported)
)

;; #[allow(unchecked_data)]
(define-read-only (get-total-items-claimed)
  (var-get total-items-claimed)
)

;; #[allow(unchecked_data)]
(define-read-only (get-total-items-found)
  (var-get total-items-found)
)

;; #[allow(unchecked_data)]
(define-read-only (get-item-rating (item-id uint))
  (default-to u0 (map-get? item-ratings item-id))
)

;; #[allow(unchecked_data)]
(define-read-only (get-user-reputation (user principal))
  (default-to u0 (map-get? user-reputation user))
)

;; #[allow(unchecked_data)]
(define-read-only (is-item-verified (item-id uint))
  (match (map-get? lost-items item-id)
    item (ok (get verified item))
    err-not-found
  )
)

;; #[allow(unchecked_data)]
(define-read-only (get-item-status (item-id uint))
  (match (map-get? lost-items item-id)
    item (ok (get status item))
    err-not-found
  )
)

;; #[allow(unchecked_data)]
(define-read-only (get-item-category (item-id uint))
  (match (map-get? lost-items item-id)
    item (ok (get category item))
    err-not-found
  )
)

;; #[allow(unchecked_data)]
(define-read-only (get-item-reward (item-id uint))
  (match (map-get? lost-items item-id)
    item (ok (get reward item))
    err-not-found
  )
)