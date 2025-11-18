%%clingo 0 asp/instances/ex01.lp -

%# This one is where ChatGPT gave me some tips (it wrote some nonsense, but I massaged it so it worked).
%# Basically: use cardinality constraints. I'm not finding that this makes any difference in terms of efficiency, but
%# it does look a bit more compact.

subgrid_size(3).

sudoku_size(S * S) :- subgrid_size(S).

%# coordinates and values
x(1..S) :- sudoku_size(S).
y(1..S) :- sudoku_size(S).
n(1..S) :- sudoku_size(S).

%# For subgrid_size(s), subgrids can be identified by labels 0..s*s-1
%# s(0..S * S - 1) :- subgrid_size(S).

%# initial position is also a sudoku position
sudoku(X,Y,N) :- initial(X,Y,N).

%# for each X, Y combination in the range (1..N) - excluding initial positions.
1 { sudoku(X,Y,N) : n(N) } 1 :- x(X), y(Y), not initial(X,Y,_).

%# no repeats in the row
:- n(N), x(X), not 1 { sudoku(X,Y,N) : y(Y) } 1.

%# no repeats in the column
:- n(N), y(Y), not 1 { sudoku(X,Y,N) : x(X) } 1.

%# no repeats in the subgrid

submap(X,Y,G) :-
    subgrid_size(S),
    x(X), y(Y),
    G = ((X - 1) / S) * S + (Y - 1) / S.

subgrid(0..(S * S - 1)) :- subgrid_size(S).

:- subgrid_size(S), n(N), subgrid(Sub),
   2 { sudoku(X,Y,N) : submap(X,Y,Sub) }.

#show sudoku/3.