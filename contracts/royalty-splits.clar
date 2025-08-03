(define-constant TOTAL_BASIS_POINTS u10000)

(define-map work-owners 
  { work-id: (buff 34) } 
  principal)

(define-map work-splits 
  { work-id: (buff 34), version: uint }
  (list 10 { recipient: principal, share: uint }))

(define-map work-version 
  { work-id: (buff 34) }
  uint)

(define-map balances 
  { recipient: principal }
  uint)

(define-public (register-work (work-id (buff 34)) (splits (list 10 { recipient: principal, share: uint })))
  (let (
        (already-registered (map-get? work-owners { work-id: work-id }))
        (total-share (fold 
                        (lambda (entry sum)
                          (+ sum (get share entry)))
                        u0
                        splits))
       )
    (begin
      (if already-registered
        (err u100) ;; Work already registered
        (if (not (is-eq total-share TOTAL_BASIS_POINTS))
          (err u101) ;; Shares must sum to 100%
          (begin
            (map-set work-owners { work-id: work-id } tx-sender)
            (map-set work-splits { work-id: work-id, version: u0 } splits)
            (map-set work-version { work-id: work-id } u0)
            (ok true)
          )
        )
      )
    )
  )
)

(define-public (set-splits (work-id (buff 34)) (splits (list 10 { recipient: principal, share: uint })))
  (let (
        (owner (map-get? work-owners { work-id: work-id }))
        (version (default-to u0 (map-get? work-version { work-id: work-id })))
        (total-share (fold 
                        (lambda (entry sum)
                          (+ sum (get share entry)))
                        u0
                        splits))
       )
    (match owner work-owner
      (if (is-eq tx-sender work-owner)
        (if (not (is-eq total-share TOTAL_BASIS_POINTS))
          (err u102) ;; Shares must sum to 100%
          (let ((next-version (+ version u1)))
            (begin
              (map-set work-splits { work-id: work-id, version: next-version } splits)
              (map-set work-version { work-id: work-id } next-version)
              (ok true)
            )
          )
        )
        (err u103) ;; Unauthorized
      )
    )
  )
)

(define-public (deposit (work-id (buff 34)) (amount uint))
  (let (
        (version (default-to u0 (map-get? work-version { work-id: work-id })))
        (splits (map-get? work-splits { work-id: work-id, version: version }))
       )
    (match splits actual-splits
      (begin
        (map
          (lambda (entry)
            (let (
                  (recipient (get recipient entry))
                  (share (get share entry))
                  (recipient-amount (/ (* amount share) TOTAL_BASIS_POINTS))
                  (current (default-to u0 (map-get? balances { recipient: recipient })))
                 )
              (map-set balances { recipient: recipient } (+ current recipient-amount))
            )
          )
          actual-splits)
        (ok true)
      )
    )
  )
)

(define-public (claim)
  (let (
        (balance (default-to u0 (map-get? balances { recipient: tx-sender })))
       )
    (if (> balance u0)
      (begin
        (map-delete balances { recipient: tx-sender })
        (stx-transfer? balance tx-sender tx-sender)
      )
      (err u104) ;; Nothing to claim
    )
  )
)

(define-public (transfer-ownership (work-id (buff 34)) (new-owner principal))
  (let ((owner (map-get? work-owners { work-id: work-id })))
    (match owner current-owner
      (if (is-eq tx-sender current-owner)
        (begin
          (map-set work-owners { work-id: work-id } new-owner)
          (ok true)
        )
        (err u105) ;; Unauthorized
      )
    )
  )
)
