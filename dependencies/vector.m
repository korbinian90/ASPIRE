%   VECTOR - converts a matrix into a vector
%   Simon Robinson. 16.3.2009
% 
% Syntax
%   b = vector(a); - yields a vector of the matrix a
%                  - this is also easily achieved with b=a(:)', of course, but the examples below show why the function form is compact and useful
%
% if we have a 2D matrix a 
%
%   a=rand(20,30);
%
% and want to find the largest value in a submatrix covering the range (13:17,19:25) I can think of the following ways to do it
%
%   1) 
%   b=a(13:17,19:25),max_value=max(b(:))
%   2)
%   max_value=max(squeeze(reshape(a(13:17,19:25),1,[])))
%   3)
%   max_value=max(vector(a(13:17,19:25)))
%
%   this third, using the 'vector' function, seems the simplest syntax and most readable code
%
%   Let me know if you know a 4th which makes this function redundant
%
function vector1d = vector(matrix)

vector1d = squeeze(reshape(matrix, 1, []));

end