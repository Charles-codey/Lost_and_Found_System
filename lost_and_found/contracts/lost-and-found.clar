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

;; Public functions
;; #[allow(unchecked_data)]
(define-public (report-lost-item 
  (item-name (string-ascii 100)) 
  (description (string-ascii 300)) 
  (location (string-ascii 100))
  (category (string-ascii 50))
  (reward uint))
  (let
    (
      (item-id (var-get item-nonce))
      (sender tx-sender)
    )
    (map-set lost-items item-id
      {
        reporter: sender,
        item-name: item-name,
        description: description,
        location: location,
        date-reported: stacks-block-height,
        status: "lost",
        claimer: none,
        category: category,
        reward: reward,
        verified: false
      }
    )
    (map-set user-reports sender (+ (get-user-report-count sender) u1))
    (var-set item-nonce (+ item-id u1))
    (var-set total-items-reported (+ (var-get total-items-reported) u1))
    (ok item-id)
  )
)

;; #[allow(unchecked_data)]
(define-public (claim-item (item-id uint))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
      (sender tx-sender)
    )
    (asserts! (is-eq (get status item) "lost") err-already-claimed)
    (map-set lost-items item-id 
      (merge item { 
        status: "claimed", 
        claimer: (some sender) 
      })
    )
    (map-set user-claims sender (+ (get-user-claim-count sender) u1))
    (var-set total-items-claimed (+ (var-get total-items-claimed) u1))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (mark-as-found (item-id uint))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (map-set lost-items item-id (merge item { status: "found" }))
    (map-set user-found-items tx-sender (+ (get-user-found-count tx-sender) u1))
    (var-set total-items-found (+ (var-get total-items-found) u1))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (verify-item (item-id uint))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set lost-items item-id (merge item { verified: true }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (cancel-report (item-id uint))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (asserts! (is-eq (get status item) "lost") err-invalid-status)
    (map-set lost-items item-id (merge item { status: "cancelled" }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (reopen-report (item-id uint))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (asserts! (is-eq (get status item) "cancelled") err-invalid-status)
    (map-set lost-items item-id (merge item { status: "lost", claimer: none }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (resolve-claim (item-id uint) (approved bool))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
      (claimer-principal (unwrap! (get claimer item) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (asserts! (is-eq (get status item) "claimed") err-invalid-status)
    (if approved
      (begin
        (map-set lost-items item-id (merge item { status: "resolved" }))
        (map-set user-reputation claimer-principal (+ (get-user-reputation claimer-principal) u10))
        (ok true)
      )
      (begin
        (map-set lost-items item-id (merge item { status: "lost", claimer: none }))
        (ok false)
      )
    )
  )
)

;; #[allow(unchecked_data)]
(define-public (update-item-status (item-id uint) (new-status (string-ascii 20)))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (map-set lost-items item-id (merge item { status: new-status }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (update-item-location (item-id uint) (new-location (string-ascii 100)))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (map-set lost-items item-id (merge item { location: new-location }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (update-item-reward (item-id uint) (new-reward uint))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (asserts! (> new-reward u0) err-invalid-reward)
    (map-set lost-items item-id (merge item { reward: new-reward }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (update-item-description (item-id uint) (new-description (string-ascii 300)))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (map-set lost-items item-id (merge item { description: new-description }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (update-item-category (item-id uint) (new-category (string-ascii 50)))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (map-set lost-items item-id (merge item { category: new-category }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (transfer-item-ownership (item-id uint) (new-owner principal))
  (let
    (
      (item (unwrap! (map-get? lost-items item-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get reporter item)) err-unauthorized)
    (map-set lost-items item-id (merge item { reporter: new-owner }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (rate-item (item-id uint) (rating uint))
  (begin
    (asserts! (<= rating u5) (err u108))
    (map-set item-ratings item-id rating)
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (increase-user-reputation (user principal) (points uint))
  (let
    (
      (current-rep (get-user-reputation user))
    )
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set user-reputation user (+ current-rep points))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (decrease-user-reputation (user principal) (points uint))
  (let
    (
      (current-rep (get-user-reputation user))
    )
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set user-reputation user (if (>= current-rep points) (- current-rep points) u0))
    (ok true)
  )
)