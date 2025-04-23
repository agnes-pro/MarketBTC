;; Title: MarketBTC - Bitcoin-Native Decentralized Marketplace
;;
;; Summary:
;; A fully decentralized marketplace built on Stacks with seamless Bitcoin settlement,
;; supporting direct sales, auctions, brand verification, and customer reviews.
;;
;; Description:
;; This contract enables a trustless commerce ecosystem where merchants can register brands,
;; list products for direct sale or auction, and build reputation through customer reviews.
;; All transactions settle with Bitcoin's security through the Stacks protocol, with
;; transparent platform fees and automated escrow functionality for auctions.

;; Constants 
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-brand-owner (err u101))
(define-constant err-invalid-price (err u102))
(define-constant err-listing-not-found (err u103))
(define-constant err-insufficient-funds (err u104))
(define-constant err-auction-ended (err u105))
(define-constant err-bid-too-low (err u106))
(define-constant err-no-active-auction (err u107))
(define-constant err-invalid-duration (err u108))
(define-constant err-invalid-rating (err u109))

;; Data Variables
(define-data-var platform-fee uint u25) ;; 2.5% fee

;; Data Maps
(define-map Brands principal 
  {
    name: (string-ascii 50),
    verified: bool,
    created-at: uint
  }
)

(define-map Products uint 
  {
    brand: principal,
    name: (string-ascii 100),
    description: (string-ascii 500),
    price: uint,
    available: bool,
    created-at: uint,
    is-auction: bool
  }
)

(define-map Auctions uint
  {
    end-block: uint,
    min-price: uint,
    highest-bid: uint,
    highest-bidder: (optional principal),
    is-active: bool
  }
)

(define-map Reviews {product-id: uint, reviewer: principal}
  {
    rating: uint,
    comment: (string-ascii 200),
    timestamp: uint
  }
)

;; Product ID counter
(define-data-var product-counter uint u0)

;; Brand Management Functions

;; Register a new brand
(define-public (register-brand (name (string-ascii 50)))
  (let
    ((brand-data {
      name: name,
      verified: false,
      created-at: block-height
    }))
    (ok (map-set Brands tx-sender brand-data))
  )
)

;; Verify a brand (owner only)
(define-public (verify-brand (brand principal))
  (if (is-eq tx-sender contract-owner)
    (let
      ((brand-data (unwrap! (map-get? Brands brand) 
                   (err err-not-brand-owner))))
      (ok (map-set Brands brand 
        (merge brand-data {verified: true}))))
    (err err-owner-only))
)

;; Direct Sale Functions

;; List a new product
(define-public (list-product 
    (name (string-ascii 100))
    (description (string-ascii 500))
    (price uint)
  )
  (let
    ((brand (unwrap! (map-get? Brands tx-sender) (err err-not-brand-owner)))
     (product-id (+ (var-get product-counter) u1)))
    
    (if (> price u0)
      (begin
        (var-set product-counter product-id)
        (ok (map-set Products product-id {
          brand: tx-sender,
          name: name,
          description: description,
          price: price,
          available: true,
          created-at: block-height,
          is-auction: false
        })))
      (err err-invalid-price)
    )
  )
)