% Please insert the names and email addresses of the group members:
%
%

%%clingo 0 asp/instances/ex01.lp -

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
:-
    sudoku(X,Y1,N),
    sudoku(X,Y2,N),
    not Y1 == Y2.

%# no repeats in the column
:-
    sudoku(X1,Y,N),
    sudoku(X2,Y,N),
    not X1 == X2.

%# no repeats in the subgrid

%# Hints:
%# - For subgrid_size(s), subgrids can be identified by labels 0..s*s-1
%# - A cell (x,y) can be mapped to the subgrid labeled (((x-1)/s)*s + (y-1)/s)

:-
    subgrid_size(S),
    sudoku(X1,Y1,N),
    sudoku(X2,Y2,N),
    not X1 == X2, not Y1 == Y2,
    Sub1 = (((X1 - 1) / S) * S + (Y1 - 1) / S),
    Sub2 = (((X2 - 1) / S) * S + (Y2 - 1) / S),
    Sub1 == Sub2.

#show sudoku/3.
