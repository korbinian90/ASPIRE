function mat=rescale(mat, new_min, new_max)

% convert ints to singles, leaves everything else as it is
if isinteger(mat) == 1
    mat = single(mat);
end
old_min = min(vector(mat));
old_max = max(vector(mat));
old_range = old_max - old_min;
new_range = new_max - new_min;
mat = (new_range*(mat-old_min)/old_range)+new_min;

