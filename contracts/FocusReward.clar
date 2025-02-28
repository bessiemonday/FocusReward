;; Constants
(define-constant MAX_TOKEN_POOL u1000000)
(define-constant CORE_INCENTIVE_AMOUNT u10)
(define-constant CONSISTENCY_BONUS u2)
(define-constant MAX_CONSISTENCY_LEVEL u7)
(define-constant ERR_INVALID_ACTIVITY u1)
(define-constant ERR_NO_INCENTIVES u2)
(define-constant ERR_POOL_DEPLETED u3)
(define-constant BLOCKS_PER_DAY u144)
(define-constant LOCKUP_MULTIPLIER u2)
(define-constant MIN_LOCKUP_PERIOD u288)
(define-constant EARLY_WITHDRAWAL_FEE u10)

;; Data Variables
(define-data-var total-tokens-distributed uint u0)
(define-data-var total-activities uint u0)
(define-data-var protocol-admin principal tx-sender)

;; Data Maps
(define-map user-activities principal uint)
(define-map user-incentives principal uint)
(define-map user-activity-start principal uint)
(define-map user-consistency principal uint)
(define-map user-last-activity principal uint)
(define-map user-locked-tokens principal uint)
(define-map user-lockup-start-block principal uint)

;; Public Functions

(define-public (begin-activity (timeframe uint))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (> timeframe u0) (err ERR_INVALID_ACTIVITY))
    (map-set user-activity-start caller burn-block-height)
    (ok true)
  )
)

(define-public (finish-activity (timeframe uint))
  (let
    (
      (caller tx-sender)
      (start-block (default-to u0 (map-get? user-activity-start caller)))
      (blocks-passed (- burn-block-height start-block))
      (last-activity-block (default-to u0 (map-get? user-last-activity caller)))
      (consistency (default-to u0 (map-get? user-consistency caller)))
      (capped-consistency (if (<= consistency MAX_CONSISTENCY_LEVEL) consistency MAX_CONSISTENCY_LEVEL))
      (incentive-amount (+ CORE_INCENTIVE_AMOUNT (* capped-consistency CONSISTENCY_BONUS)))
    )
    (asserts! (and (> start-block u0) (>= blocks-passed timeframe)) (err ERR_INVALID_ACTIVITY))
    (map-set user-activities caller (+ (default-to u0 (map-get? user-activities caller)) u1))
    (map-set user-incentives caller (+ (default-to u0 (map-get? user-incentives caller)) incentive-amount))
    (if (< (- burn-block-height last-activity-block) BLOCKS_PER_DAY)
      (map-set user-consistency caller (+ consistency u1))
      (map-set user-consistency caller u1)
    )
    (map-set user-last-activity caller burn-block-height)
    (var-set total-activities (+ (var-get total-activities) u1))
    (var-set total-tokens-distributed (+ (var-get total-tokens-distributed) incentive-amount))
    (asserts! (<= (var-get total-tokens-distributed) MAX_TOKEN_POOL) (err ERR_POOL_DEPLETED))
    (ok incentive-amount)
  )
)

(define-public (redeem-incentives)
  (let
    (
      (caller tx-sender)
      (incentive-balance (default-to u0 (map-get? user-incentives caller)))
    )
    (asserts! (> incentive-balance u0) (err ERR_NO_INCENTIVES))
    (map-set user-incentives caller u0)
    (ok incentive-balance)
  )
)

;; Lockup Features

(define-public (lock-tokens (amount uint))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (> amount u0) (err ERR_INVALID_ACTIVITY))
    (asserts! (>= (var-get total-tokens-distributed) amount) (err ERR_POOL_DEPLETED))
    (map-set user-locked-tokens caller amount)
    (map-set user-lockup-start-block caller burn-block-height)
    (var-set total-tokens-distributed (- (var-get total-tokens-distributed) amount))
    (ok amount)
  )
)

(define-public (unlock-tokens)
  (let
    (
      (caller tx-sender)
      (lockup-data (default-to u0 (map-get? user-locked-tokens caller)))
      (lockup-start-block (default-to u0 (map-get? user-lockup-start-block caller)))
      (blocks-locked (- burn-block-height lockup-start-block))
      (fee (if (< blocks-locked MIN_LOCKUP_PERIOD) (/ (* lockup-data EARLY_WITHDRAWAL_FEE) u100) u0))
      (final-amount (- lockup-data fee))
    )
    (asserts! (> lockup-data u0) (err ERR_NO_INCENTIVES))
    (map-set user-locked-tokens caller u0)
    (map-set user-lockup-start-block caller u0)
    (var-set total-tokens-distributed (+ (var-get total-tokens-distributed) final-amount))
    (ok final-amount)
  )
)

;; Read-Only Functions

(define-read-only (get-activity-count (user principal))
  (default-to u0 (map-get? user-activities user))
)

(define-read-only (get-incentive-balance (user principal))
  (default-to u0 (map-get? user-incentives user))
)

(define-read-only (get-user-consistency (user principal))
  (default-to u0 (map-get? user-consistency user))
)

(define-read-only (get-platform-stats)
  {
    total-activities: (var-get total-activities),
    total-tokens-distributed: (var-get total-tokens-distributed)
  }
)

;; Private Functions

(define-private (is-protocol-admin)
  (is-eq tx-sender (var-get protocol-admin))
)


