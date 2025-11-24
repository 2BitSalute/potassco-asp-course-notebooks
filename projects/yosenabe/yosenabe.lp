%%clingo 3 instances/instance01.lp -

%# Legend
%# cell(X,Y).         % the cell (X,Y) belongs to the grid
%# area(X,Y,A).       % the cell (X,Y) belongs to area A
%# number(X,Y,N).     % the cell (X,Y) initially contains number N
%# goal(A,G).         % the goal number of area A is G

dir(0,1). dir(0,-1). dir(1,0). dir(-1,0).

%# Hints:
%# - You may use the gaps of adjacent cell coordinates to denote directions.
%# - You can use the "--text" option of clingo to inspect the ground program.

%# pick a direction for each number at the beginning.
%# once a direction is chosen, the number has to move in that direction for the duration of the solution.
%# track original coordinates with N - we need them for target and also as ID, in case there are duplicate numbers
1 { number_dir(X,Y,N,LR,UD) : dir(LR,UD) } 1 :- number(X,Y,N).

%# make a move(X,Y,XX,YY,N) for each number(X,Y,N)
move(X,Y,X,Y,N) :- number(X,Y,N).

%# maybe? move each number to a new location
0 { move(X, Y, XX + LR, YY + UD, N) } 1 :-  %# choose to move or not
    number_dir(X, Y, N, LR, UD),            %# for a given number direction
    move(X,Y,XX,YY,N),                      %# if there's a move to (XX,YY)
    %# not move(X,Y,XX + LR, YY + UD, N),   %# AND there isn't a move to the potential destination already
    cell(XX + LR,YY + UD).                  %# AND the destination exists

%# Find the current sum_area(A,S)
sum_area(A,S) :-
    area(_,_,A),
    S = #sum { N,AA :
        A == AA,
        area(XX,YY,AA),
        move(X,Y,XX,YY,N),
        number_dir(X, Y, N, LR, UD),
        not move(X, Y, XX + LR, YY + UD, N) }.

n_goals(NG) :- NG = #count { A,G : goal(A,G) }. %# number of goals
n_areas(NA) :- NA = #count { A : area(_,_,A) }.

%# TODO: I think I could formulate latest_move as a rule

area_populated(A) :-
    area(XX,YY,A),
    move(X,Y,XX,YY,N),
    number_dir(X, Y, N, LR, UD),
    not move(X, Y, XX + LR, YY + UD, N).

areas_populated("true") :-
    n_areas(NA),
    NA #count { A : area_populated(A) }.

%# goal_achieved(A) :-
%#     goal(A,G),
%#    SumArea

goals_achieved("true") :-
    n_goals(NG),
    NG #count { G : goal(A,G), sum_area(A,S), S == G } NG. %# count of solved goals

%# Encode winning!
%# Every area has one or more numbers
%# Every goal is achieved.
solved("true") :- areas_populated("true"), goals_achieved("true").

solved("false") :- not solved("true").

%# if solved, then set targets
target(X, Y, XX, YY) :-
    solved("true"),
    number_dir(X, Y, N, LR, UD),
    move(X, Y, XX, YY, N),
    not move(X, Y, XX + LR, YY + UD, N). %# and we don't need to check if the destination exists

%# This should prune solutions where different numbers share cells
:- #count { XX,YY : move(_,_,XX,YY,_) } 1.

%# This prunes non-solutions
:- solved("false").

%# --- Terminating conditions---
%# Note: it's not necessary to have the number land in an area.
%# (1) The straight lines of any two moved numbers must not cross or meet at any grid cell.
%# --- OK, this is the simplest one. It cannot be the case that two numbers went through the same cell at any time.
%# (2) Each gray area must be populated with at least one moved number.
%# (3) An area may be associated with a positive goal number, shown within it.

#show area_populated/1.
%#show ok/1.
%#show solved/1.
#show target/4.
%#show number/3.
%#show number_dir/5.
%#show area/3.
%#show move/5.
% Answer: target(3,1,2,1) target(3,4,3,3) target(5,3,5,1) target(4,2,4,5) target(1,5,1,1)