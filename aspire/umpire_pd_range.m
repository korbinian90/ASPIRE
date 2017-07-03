function pd = umpire_pd_range(p2, p1, lower_bound)

 pd = mod( p2 - p1 - lower_bound, 2*pi ) + lower_bound;
% pd_simple = p2 - p1;
% pd = pd_simple;
% pd(pd_simple > (lower_bound + 2*pi) ) = pd_simple(pd_simple > pi) -2*pi;
% pd(pd_simple < lower_bound) = 2*pi + pd_simple(pd_simple < -pi);
% pd = squeeze(pd);

