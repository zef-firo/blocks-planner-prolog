/**
* condizioni di esistenza sul piano di lavoro
* on_table(X) se il blocco è sul tavolo
* on(X, Y) se il blocco si trova su Y
* clear(X) se il blocco X non ha nulla sopra di sé
**/

/**
* registra gli stati iniziale e obiettivo.
* gestiamo gli stati come una lista di fatti e ricostruiamo i passi eseguiti con il backtracking
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
* posso spostare dal tavolo X su Y? write("mft"), nl, write(X), nl, write(Y), nl,
*/
can_do(move_from_table(X, Y), S) :- member(on_table(X), S),
    member(clear(X), S),
    member(clear(Y), S).

/**
* posso spostare X su Y? write("move"), nl, write(X), nl, write(Y), nl,
*/
can_do(move(X,Y), S) :- member(clear(X), S),
    member(on(X,Z), S),
    member(clear(Y), S).

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
* controllo di uguaglianza tra gli stati per evitare l'anomalia di sussman
*/
equal([], []).

equal([X | R], S2) :- member(X, S2),
    delete(S2, X, R2),
    equal(R, R2).

/**
* scorrimento di tutti gli stati visitati per verificare l'uguaglianza
*/
visited(S, [S1 | _]) :- equal(S, S1), !.
visited(S, [_ | R]) :- visited(S, R).

/**
* eseuzione
*/
find_solution(SO) :- initial(S),
    write("Stato iniziale è:"),
    nl,
    write(S),
    nl,
    solve(S, [], SO).

solve(S, _, []) :- goal(S),
    write("Stato finale è:"),
    nl,
    write(S),
    !.

solve(S, BCK, [O | R]) :- can_do(O, S),
    movement(O, S, NS),
    \+visited(NS, BCK),
    solve(NS, [S | BCK], R).
