m = [0 0 2 3; 0 0 2 3; 0 0 2 3; 0 0 2 3];
w = [0 0 1 1; 0 0 1 1; 0 0 1 1; 0 0 1 1];
edgeFill(m', w', 3)

m = [0 0 0 0;
     0 0 0 0;
     0 0 3 4;
     0 0 4 5];
w = [0 0 0 0;
     0 0 0 0;
     0 0 1 1;
     0 0 1 1];
edgeFill(m, w, 3)


A = zeros(4);
w = ones(4);
B = [1 2 3 4;
     2 3 4 5;
     3 4 5 6;
     4 5 6 7];

m = [A A A;
     A B A
     A A A]
w = [A A A;
     A w A
     A A A]
edgeFill(m, w, 5)
