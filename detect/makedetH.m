function [detHgrid] = makedetH(J, filtersize)
% MAKEDETH takes an integral image and returns and array of the
%   absolute values of the determinants of the Hessian at each calculatable
%   point for the filtersize.
%
% INPUTS
% J: the integral image of some volume.
% filtersize: the size of the filter used to approximate H.
%
% OUTPUTS
% detHgrid: the array of |det(H)|.
%
% NOTES
% We take the absolute value of the det(H) because in three dimensions
% saddle points can also be detected. [Knopp et al. "Hough Transforms and 3D
% SURF for robust trhee dimenstional classification" pg. 4] We normalize
% the determinant of the approximate Hessian by using a weight factor
% calculated from ratios of Frobenius (Euclidian) norms.
%% -----------------------------------------------------------------------

% First, approximate the Hessian matricies for all calculatable points in
% the volume.
gridofhessians = surfhessian3D(J, filtersize);

% Setup output cell. J is 1 larger than its volume.
[x,y,z] = size(J);
x0 = x-1; y0 = y-1; z0 = z-1;
detHgrid = zeros(x0,y0,z0,'double');

numhessians = numel(gridofhessians);
parfor i = 1:numhessians;
    % Points where the filter overlaped the edges were not calculated.
    % Default value of detHgrid is already zero.
    if(~isempty(gridofhessians{i}))
        % Form the full Hessian matrix and calculate |weighted det(H)|.
        D = gridofhessians{i}
        %H = [D(1),D(4),D(6);...
        %     D(4),D(2),D(5);...
        %     D(6),D(5),D(3)];
        detHgrid(i) = abs(weighteddet(D, filtersize, 0.7202));
    end
end
end

%% Helper Functions

function [det] = weighteddet(H, filtersize, w)
% WEIGHTEDDET weights the determinant of the Hessian according to
%   filtersize and to the weight factor which corrects for the box
%   approximation of the gaussian.
% 
% INPUTS
% H: the abbreviated hessian matrix in vector form whose elements are in
% this order: D11, D22, D33, D12, D23, D13.
% w: the weight factor was derived by comparing the cropped 3D gaussian with
% the box filters by taking a ratio of the Euclidian norms.
% filtersize: a scalar dimension denoting the side length of the box filter
% used to derive this Hessian Matrix
%
% OUTPUTS
% det: the weighted determinant of H.
%
% NOTES
% See [Bay et al. "Speeded Up Robust Features" pg. 4] for details about
% weighting the Hessian response.
%% -----------------------------------------------------------------------

% Calculate the determinant using a weight factor.
det = H(1)*H(2)*H(3)... % D11(D22)D33
    - H(1)*(w*H(5))^2 - H(2)*(w*H(6))^2 - H(3)*(w*H(4))^2 ... D11(wD23)^2
    + 2*w^3*H(4)*H(5)*H(6); % 2(wD12)wD23(wD13)

% Normalize the response by the size of the filter.
det = det/filtersize^3;

end
