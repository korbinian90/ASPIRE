function image = nan_dilate(image, radius, varargin)
%NAN_DILATE Summary of this function goes here
%   Detailed explanation goes here

dimensions = 1:max(ndims(image), 3);
if nargin == 3
    dimensions = varargin;
end

for iDim = dimensions
    image = dilate_dim(image, radius, iDim);
end

end


function out = dilate_dim(image, radius, dim)
    image = permute(image, [dim 1:dim-1 dim+1:ndims(image)]);
    
    out = image;
    for i = 1+radius:size(image, 1) - radius
        inds = isnan(out(i,:));
%         out(i,inds) = nanmean(image(i-radius:i+radius,inds), 1);
        out(i,inds) = nanmax(image(i-radius:i+radius,inds),[], 1);
    end
    
    out = permute(out, [2:dim 1 dim+1:ndims(out)]);
end