// load "Congruence Subgroups of genus 0.m";
import "Required functions.m" : Act, SiegelExpansion, FindRelation, H90, CuspData;
import "Congruence Subgroups of genus 0.m" : CPlist;

function m2(A,K) 

 

// Input : A matrix A in GL_{3}(K) such that A preserves the equation for y^2=xz 

// Output : A matrix C in GL_{2}(K) corresponding to A  

 

a := A[1,1];  

b := A[1,2];  

c := A[1,3];  

d := A[2,1];  

e := A[2,2];  

f := A[2,3]; 

g := A[3,1]; 

h := A[3,2]; 

i := A[3,3]; 

if a eq 0 then 

    C := Matrix(K,2,2,[0,c,e,f]); 

else 

    if g eq 0 then 

        C := Matrix(K,2,2,[a,b/2,0,e]); 

    else 

        if c eq 0 then 

            C := Matrix(K,2,2,[a,0,d,e]); 

        else 

            if f eq 0 then 

                C := Matrix(K,2,2,[a,b/2,d,0]); 

            else 

                C := Matrix(K,2,2,[a,b/2,d,e-(b*d/(2*a))]); 

            end if; 

        end if; 

    end if; 

end if; 

 

return C; 

end function;  



function ComputeModel(M,Ggens,prec)
/* Input : Takes a genus 0 group G of level M and generators Ggens in GL_2(Z/MZ), if G does not contain -I, then we take the group generated by Ggens and -I;
prec is the precision with which q-expansions are computed, with subgroups upto LMFDB label "21.6.0.1" prec=10 works.
Output : The code computes model of X_G as a conic and if it has a rational point also computes the map J1: X_G \to P^1. */

G0group := recformat<N:RngIntElt, sl2label:MonStgElt, gens>;
/*  N : GL_2 level of G
sl2label : Cummins-Pauli label of G \intersect SL_2(Z/NZ)
gens : A set of Generators for G in GL_2(Z/NZ)*/

Gamma:=rec<G0group | N := M, gens := Ggens join {-Identity(GL(2,Integers(M)))}>;
G:=sub<GL(2,Integers(M))|[g: g in Gamma`gens]>;

/* Trying to find genus 0 congruence subgroup H such that G \intersect SL_2(Z) is conjugate to H. Once we find H, we conjugate generators of G so that
G \intersect \SL_2(Z)=H. */
for k in Keys(CPlist) do
    if k eq "1A" then 
               continue k;
         end if;
    Csub:=CPlist[k];        
    N:=Csub`N;
    H:=Csub`H;
         if IsDivisibleBy(M,N) eq false then continue k;end if;
         red:=hom<SL(2,Integers(M))->SL(2,Integers(N))|[SL(2,Integers(N))!SL(2,Integers(M)).i: i in [1..#Generators(SL(2,Integers(M)))]]>;
         Hred:=H@@red;
         b,Aconj:=IsConjugate(GL(2,Integers(M)),G meet SL(2,Integers(M)),Hred);
         if b eq false then 
               continue k;
         else 
               Gconj:=Conjugate(G,Aconj);Gamma`sl2label:=k;break;end if;
 end for;
 
 // We now construct cocycle that gives X_G as a twist of X_H; here H = G \intersect \SL_2(Z).
 
 L<z> := CyclotomicField(M); 
 P<t> := FunctionField(L); 
 R<q>:=PuiseuxSeriesRing(L);
 h := CPlist[Gamma`sl2label]`hauptmodul; 
 hq:=CPlist[Gamma`sl2label]`h;
 H_:= Gconj meet SL(2,Integers(M));
  _,width:=CuspData(H_);
 w:=width[1];
 H1,q1:=quo<Gconj|H_>;
 Gal,iota,sigma:=AutomorphismGroup(L);
 Cocycle:=AssociativeArray();


for g in Gal do;
  for s1 in Set(H1) do;  
   d:=Determinant(s1@@q1);d:=Integers()!d;
   if sigma(g)(z) eq (z)^d then s:=s1; end if;
  end for;                    
  B1,B2:=Act(P!t,s@@q1,P!t,h);
  J:=FindRelation(R!SiegelExpansion(B2,prec),R!SiegelExpansion(h,prec),1);
  Cocycle[g]:=J;
end for;
 
m1 := map< MatrixRing(L,2) -> MatrixRing(L,3) | n :-> (1/Determinant(n))*Matrix(3,3,[n[1,1]^2,2*n[1,1]*n[1,2],n[1,2]^2,n[1,1]*n[2,1],n[1,1]*n[2,2]+n[1,2]*n[2,1],n[1,2]*n[2,2],n[2,1]^2,2*n[2,1]*n[2,2],n[2,2]^2])>;
phi := map<Gal -> MatrixRing(L,3) | [g -> m1([Evaluate(Numerator(Cocycle[g])-Evaluate(Numerator(Cocycle[g]),0),1),Evaluate(Numerator(Cocycle[g]),0),Evaluate(Denominator(Cocycle[g])-Evaluate(Denominator(Cocycle[g]),0),1),Evaluate(Denominator(Cocycle[g]),0)] ) : g in Gal]>; 
Amatrix := H90(3,L,Rationals(),Gal,sigma,phi);  
D := Matrix(3,3,[0,0,-1/2,0,1,0,-1/2,0,0]);  
Q0 := Conic(D); 
Q,_ := Conic(Transpose(Amatrix^(-1))*D*Amatrix^(-1));  // Transpose because MAGMA uses right action.
Q := ChangeRing(Q,Rationals());  // Q is our conic.

boolean,Qpt:=HasRationalPoint(Q); 
            if boolean eq false then 
            B:=Amatrix;
	          	B:=Matrix(R,3,3,[[R!B[i,j]:j in [1..3]]:i in [1..3]]);
		          funcx:=(B[1,1]*hq^2+B[1,2]*hq+B[1,3])/(B[3,1]*hq^2+B[3,2]*hq+B[3,3]);
		           funcy:=(B[2,1]*hq^2+B[2,2]*hq+B[2,3])/(B[3,1]*hq^2+B[3,2]*hq+B[3,3]); 
                
                W:=Matrix(L,[[Coefficient(funcx,i/w):i in [-1..prec]],[Coefficient(funcy,i/w):i in [-1..prec]],
                          [Coefficient(R!1,i/w):i in [-1..prec]],[Coefficient(-hq*funcx,i/w):i in [-1..prec]],
                          [Coefficient(-hq*funcy,i/w):i in [-1..prec]],[Coefficient(-hq,i/w):i in [-1..prec]]]);
		          null:=Nullspace(W);assert Dimension(null) eq 2;
		          A:=null.1;
		          Qx<x> := FunctionField(L);
		          Pol<yy> := PolynomialRing(Qx);
		           pol := Evaluate(DefiningPolynomial(Q),[x,yy,1]);
		           FFQ<y> := FunctionField(pol);
		           F:=(A[1]*x+A[2]*y+A[3])/(A[4]*x+A[5]*y+A[6]);
		           J1:=Evaluate(CPlist[Gamma`sl2label]`J,F);
			   return Q,J1,boolean, _;
            end if;
            if boolean eq true then
                B := (Transpose(ParametrizationMatrix(Q)))^(-1); //Transpose to make it left action 
                
                C := (m2(B*Amatrix,L))^(-1); 
                
                g1 := (C[1,1]*t+C[1,2])/(C[2,1]*t+C[2,2]); 
                
                J1:=  Evaluate(CPlist[Gamma`sl2label]`J,g1); assert J1 in FunctionField(Rationals()); 
                return Q, J1, boolean, Qpt;

end if;



end function;
