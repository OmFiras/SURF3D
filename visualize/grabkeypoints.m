function [] = grabkeypoints( V0, points, outdir )
%GRABKEYPOINTS cuts subvolumes out of V0 around the POINTS and saves them
%   to a directory OUTDIR/p000001/00001.png. #parallel
%
% INPUTS
% V0: an uint8 greyscale 3 dimensional array.
% points: an Nx4 array of key points [x,y,z,diameter].
% 
% NOTES
%
%% -----------------------------------------------------------------------
if(size(points,1) > 99999)
    warning('The number of image exceeds the number of leading zeros.');
end

% Pad the array for the largest radius.
if size(points,2) > 3
    r = (points(:,4)-1)/2; 
    pad = ceil(max(r));
else
    pad = 12;
    r(size(points,1),1) = 12;
end
padded_V = padarray(V0,[pad,pad,pad],'both');
% Shift the points because we padded the array.
padded_points = uint32(points(:,1:3) + pad);

parfor i = 1:size(points,1)
    
    % Cut out the volume around each point.
    xrange = padded_points(i,1)-r(i):padded_points(i,1)+r(i);
    yrange = padded_points(i,2)-r(i):padded_points(i,2)+r(i);
    zrange = padded_points(i,3)-r(i):padded_points(i,3)+r(i);
    subvol = padded_V(xrange,yrange,zrange);
    
    % Save the volume to a named directory.
    folder = sprintf('/p%05i',i);    
    imstacksave(subvol,[outdir folder],'');

end
end