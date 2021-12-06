/**
* condizioni di esistenza sul piano di lavoro
* on_table(X) se il blocco è sul tavolo
* on(X, Y) se il blocco si trova su Y
* clear(X) se il blocco X non ha nulla sopra di sé
**/

/**
* registra gli stati iniziale e obiettivo.
* gestiamo gli stati come una tripla [State, Path, Operations] dove:
* - State: è lo stato del nodo corrente
* - Path: è la lista di stati dall'iniziale al corrente
* - Operations: è la lista di operazioni applicate per arrivare allo stato corrente
*/

initial([on_table(a), clear(a), on_table(b), on(c,b), clear(c)]).

goal(S) :- member(on_table(a), S),
    member(on(b,a), S),
    member(on(c,b), S),
    member(clear(c), S).

/**
* operatori di movimento.
* sono le operazioni che definiscono gli spostamenti dei blocchi sul tavolo
*/

/**
* posso spostare su tavolo il blocco X?
*/
can_do(move_to_table(X), S) :- member(clear(X), S),
    member(on(X, Y), S).

/**
* posso spostare dal tavolo X su Y?
*/
can_do(move_from_table(X, Y), S) :- member(on_table(X), S),
    member(clear(X), S),
    member(clear(Y), S),
    \+X=Y.

/**
* posso spostare X su Y?
*/
can_do(move_on(X,Y), S) :- member(clear(X), S),
    member(on(X,Z), S),
    member(clear(Y), S),
    \+X=Y.

/**
* applica lo spostamento del blocco X sul tavolo allo stato S
*/
movement(move_to_table(X),S,S2) :- member(on(X,Y), S),
    append([on_table(X), clear(Y)], S, S1),
    delete(S1,on(X,Y),S2).

/**
* applica lo spostamento del blocco X dal tavolo su Y
*/
movement(move_from_table(X, Y), S, [on(X, Y) | S2]) :- delete(S, on_table(X), S1),
    delete(S1, clear(Y), S2).

/**
* applica lo spostamento di X su Y
*/
movement(move_on(X,Y), S, [on(X, Y), clear(Z) | S2]) :- delete(S, clear(Y), S1),
    delete(S1, on(X,Z), S2).

/**
* produzione della lista di operatori applicabili allo stato S
*/
list_cando(S, OPL) :- setof(O, can_do(O, S), OPL), !.

list_cando(S, []).

/**
* produzione della lista di triple trasformate dalle operazioni sullo stato S
*/
list_moved(_, _, _, [], []).

list_moved(S, P, OPL, [OP|R], NSL) :- movement(OP, S, NS),
    member(NS, P),
    !,
    list_moved(S, P, OPL, R, NSL).

list_moved(S, P, OPL, [OP|R], [[NS, [S|P], [OP|OPL]]|OTH]) :- movement(OP,S,NS),
    list_moved(S, P, OPL, R, OTH).

/**
* reverse lista
*/
reverse([X], [X]).
reverse([X|R], REV) :- reverse(R, T),
    append(T, [X], REV).

/**
* eseuzione
*/
find_solution(SO) :- initial(S),
    write("Lo stato iniziale è: "),nl,
    write(S),
    nl,
    solve([[S, [], []]], SO).

solve([[S, P, OP]|_], REV_OP) :- goal(S),
    write("Lo stato finale è: "),
    nl,
    write(S),
    nl,
    reverse(OP, REV_OP),
    nl.

solve([[S, PATH, OP]|R], OP1) :- goal(S),
    !,
    solve(R, OP1).

solve([[S, P, OP]|R], SO) :- list_cando(S, OPL),
    list_moved(S, P, OP, OPL, NSL),
    append(R,NSL,LIST),
    solve(LIST, SO).