Require Import String. 
Add Rec LoadPath "../src/" as Output.  
Add ML Path "../src/". 

Require  Dump. 


Section t. 
  Require Import ZArith. 
  Open Scope Z_scope.
  Definition seed := 50.
  Definition a := 31415821.
  Definition c := 1.
  Definition max := 100000000.

  Definition next z := (c+a*z) mod max.

  Fixpoint mk_list z (acc : list Z) (n : nat) :=
    match n with
      | O => (z, acc)
      | S n0 => mk_list (next z) (z::acc) n0
    end.
  Definition mk_randoms n := snd (mk_list seed nil n).
  Time Eval vm_compute in mk_randoms 1000.
End t. 

Definition out := mk_randoms 10000. 

Output out as "foo.dump". 
