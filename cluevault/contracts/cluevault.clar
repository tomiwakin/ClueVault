;; Crypto Quest
;; A blockchain-based quest with progressive puzzles and rewards

;; Constants
(define-constant UNAUTHORIZED-ERROR (err u1))
(define-constant INACTIVE-QUEST-ERROR (err u2))
(define-constant INVALID-STAGE-ERROR (err u3))
(define-constant ALREADY-COMPLETED-ERROR (err u4))
(define-constant INCORRECT-SOLUTION-ERROR (err u5))
(define-constant TIME-RESTRICTED-ERROR (err u6))
(define-constant INSUFFICIENT-FUNDS-ERROR (err u7))

;; Data Variables
(define-data-var admin-address principal tx-sender)
(define-data-var quest-active bool false)
(define-data-var current-phase uint u0)
(define-data-var entry-fee uint u1000000) ;; 1 STX
(define-data-var total-reward-pool uint u0)

;; Quest Phase Structure
(define-map quest-phases
   uint
   {
       hint: (string-utf8 256),
       solution-verification: (buff 32), ;; SHA256 hash of the solution
       unlock-block: uint,
       phase-reward: uint,
       phase-completed: bool
   }
)

;; Explorer Progress Tracking
(define-map explorer-progress
   principal
   {
       current-phase: uint,
       completed-phases: (list 20 uint),
       last-challenge-attempt: uint,
       total-phases-solved: uint
   }
)

;; Explorer Solutions History
(define-map phase-solution-attempts
   {phase: uint, explorer: principal}
   {
       attempt-count: uint,
       completion-block: (optional uint)
   }
)

;; Events
(define-map phase-champions
   uint
   (list 10 {explorer: principal, completion-block: uint})
)

;; Authorization
(define-private (is-manager)
   (is-eq tx-sender (var-get admin-address)))

;; Quest Management Functions
(define-public (initialize-quest)
   (begin
       (asserts! (is-manager) UNAUTHORIZED-ERROR)
       (var-set quest-active true)
       (var-set current-phase u0)
       (var-set total-reward-pool u0)
       (ok true)))

(define-public (add-quest-phase
   (phase-id uint)
   (phase-hint (string-utf8 256))
   (solution-hash (buff 32))
   (availability-block uint)
   (reward-amount uint))
   (begin
       (asserts! (is-manager) UNAUTHORIZED-ERROR)
       (map-set quest-phases phase-id
           {
               hint: phase-hint,
               solution-verification: solution-hash,
               unlock-block: availability-block,
               phase-reward: reward-amount,
               phase-completed: false
           })
       (var-set total-reward-pool (+ (var-get total-reward-pool) reward-amount))
       (ok true)))

;; Explorer Registration
(define-public (register-explorer)
   (begin
       (asserts! (var-get quest-active) INACTIVE-QUEST-ERROR)
       ;; Require entry fee
       (try! (stx-transfer? (var-get entry-fee) tx-sender (var-get admin-address)))
       
       (map-set explorer-progress tx-sender
           {
               current-phase: u0,
               completed-phases: (list),
               last-challenge-attempt: u0,
               total-phases-solved: u0
           })
       (ok true)))

;; Gameplay Functions
(define-public (submit-solution
   (phase-id uint)
   (answer-hash (buff 32)))
   (let (
       (phase-data (unwrap! (map-get? quest-phases phase-id) INVALID-STAGE-ERROR))
       (player-data (unwrap! (map-get? explorer-progress tx-sender) INVALID-STAGE-ERROR))
       )
       ;; Check phase availability
       (asserts! (var-get quest-active) INACTIVE-QUEST-ERROR)
       (asserts! (>= block-height (get unlock-block phase-data)) TIME-RESTRICTED-ERROR)
       (asserts! (not (get phase-completed phase-data)) ALREADY-COMPLETED-ERROR)
       
       ;; Verify solution - directly compare the hashes
       (if (is-eq answer-hash (get solution-verification phase-data))
           (begin
               ;; Update phase status
               (map-set quest-phases phase-id
                   (merge phase-data {phase-completed: true}))
               
               ;; Update explorer progress
               (map-set explorer-progress tx-sender
                   (merge player-data {
                       current-phase: (+ phase-id u1),
                       completed-phases: (unwrap! (as-max-len? 
                           (append (get completed-phases player-data) phase-id) u20)
                           INVALID-STAGE-ERROR),
                       total-phases-solved: (+ (get total-phases-solved player-data) u1)
                   }))
               
               ;; Record solution
               (map-set phase-solution-attempts
                   {phase: phase-id, explorer: tx-sender}
                   {
                       attempt-count: u1,
                       completion-block: (some block-height)
                   })
               
               ;; Award reward
               (try! (stx-transfer? (get phase-reward phase-data) (var-get admin-address) tx-sender))
               
               ;; Record champion
               (match (map-get? phase-champions phase-id)
                   champion-list (map-set phase-champions phase-id
                       (unwrap! (as-max-len?
                           (append champion-list {explorer: tx-sender, completion-block: block-height})
                           u10)
                           INVALID-STAGE-ERROR))
                   (map-set phase-champions phase-id
                       (list {explorer: tx-sender, completion-block: block-height})))
               
               (ok true))
           INCORRECT-SOLUTION-ERROR)))

;; Read-only functions
(define-read-only (get-current-hint (phase-id uint))
   (match (map-get? quest-phases phase-id)
       phase-data (if (>= block-height (get unlock-block phase-data))
           (ok (get hint phase-data))
           TIME-RESTRICTED-ERROR)
       INVALID-STAGE-ERROR))

(define-read-only (get-explorer-status (player-address principal))
   (map-get? explorer-progress player-address))

(define-read-only (get-phase-champions (phase-id uint))
   (map-get? phase-champions phase-id))

(define-read-only (get-quest-stats)
   {
       active: (var-get quest-active),
       current-phase: (var-get current-phase),
       total-reward-pool: (var-get total-reward-pool),
       entry-fee: (var-get entry-fee)
   })