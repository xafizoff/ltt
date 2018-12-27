{-# OPTIONS --cubical --safe #-}

module ch01 where

  open import Agda.Builtin.Equality

  module defs where

    data _×_ (A B : Set) : Set where
      _,_ : A → B → A × B

    pr₁ : {A B : Set} → A × B → A
    pr₁ (a , b) = a

    pr₂ : {A B : Set} → A × B → B
    pr₂ (a , b) = b

    data Σ (A : Set) (B : A → Set) : Set where
      _,_ : (a : A) → B a → Σ A B

    π₁ : {A : Set}{B : A → Set} → Σ A B → A
    π₁ (a , b) = a

    π₂ : {A : Set}{B : A → Set} → (p : Σ A B) → B (π₁ p)
    π₂ (a , b) = b

    data ℕ : Set where
      zero : ℕ
      succ : ℕ → ℕ

  module ex01 where

    open defs

    _∘_ : {A B C : Set} → (B → C) → (A → B) → A → C
    g ∘ f = \ x → g (f x)

  module ex02 where

    open defs

    rec-× : {A B C : Set} -> (A → B → C) → A × B → C
    rec-× g (a , b) = g a b

    rec-×-β : {A B C : Set} -> (a : A)(b : B)(g : A → B → C) → rec-× g (a , b) ≡ g a b
    rec-×-β a b g = refl

    rec-Σ : {A C : Set}{B : A → Set} → ((a : A) → B a → C) → Σ A B → C
    rec-Σ g (a , b) = g a b

    rec-Σ-β : {A C : Set}{B : A → Set} → (a : A)(b : B a)(g : (a : A) → B a → C) → rec-Σ g (a , b) ≡ g a b
    rec-Σ-β a b g = refl

  module ex03 where

    open defs

    uniq-× : {A B : Set} → (p : A × B) → (pr₁ p , pr₂ p) ≡ p
    uniq-× (a , b) = refl

    subst : {A : Set} (C : A → Set) {x y : A} → x ≡ y → C x → C y
    subst C refl cₓ = cₓ

    ind-× : {A B : Set} → (C : A × B → Set) → ((a : A)(b : B) → C (a , b)) → (p : A × B) → C p
    ind-× C g p = subst C (uniq-× p) (g (pr₁ p) (pr₂ p))

    uniq-Σ : {A : Set}{B : A → Set} → (p : Σ A B) → (π₁ p , π₂ p) ≡ p
    uniq-Σ (a , b) = refl

    ind-Σ : {A : Set}{B : A → Set} → (C : Σ A B → Set) → ((a : A) → (b : B a) → C (a , b)) → (p : Σ A B) → C p
    ind-Σ C g p = subst C (uniq-Σ p) (g (π₁ p) (π₂ p))

  module ex04 where

    open defs

    rec : {C : Set} → C → (ℕ → C → C) → ℕ → C
    rec c₀ cₛ zero = c₀
    rec c₀ cₛ (succ n) = cₛ n (rec c₀ cₛ n)

    ind : {C : ℕ → Set} → C zero → ((n : ℕ) → C n → C (succ n)) → ((n : ℕ) → C n)
    ind c₀ cₛ zero = c₀
    ind c₀ cₛ (succ n) = cₛ n (ind c₀ cₛ n)

    iter : {C : Set} → C → (C → C) → ℕ → C
    iter c₀ cₛ zero = c₀
    iter c₀ cₛ (succ n) = cₛ (iter c₀ cₛ n)

    rec-iter : {C : Set} → C → (ℕ → C → C) → ℕ → C
    rec-iter {C} c₀ cₛ n = pr₂ (iter c₀' cₛ' n)
      where
        c₀' : ℕ × C
        c₀' = zero , c₀

        cₛ' : ℕ × C → ℕ × C
        cₛ' (n , c) = (succ n , cₛ n c)

    ff : (C' : Set)(c₀ : C')(cₛ : ℕ → C' → C') → ℕ → ℕ × C'
    ff C' c₀ cₛ n = ind {C} (zero , c₀) (λ n → λ q → (succ (pr₁ q) , cₛ (succ (pr₁ q)) (pr₂ q))) n
      where
        C : ℕ → Set
        C _ = ℕ × C'

    -- rec-holds : (C : Set) → (c₀ : C) → (cₛ : ℕ → C → C) → (n : ℕ) → rec {C} c₀ cₛ n ≡ rec-iter {C} c₀ cₛ n
    -- rec-holds C c0 cs zero = refl
    -- rec-holds C c0 cs (succ n) = refl rec-iter {C} c0 cs n