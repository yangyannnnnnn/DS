function [n_rhp_poles, dom_poles] = rhp_pole_count(sys,tol)
%
% function [n_rhp_poles, dom_poles] = rhp_pole_count(sys)
%
% Returns the number of unstable (right half plane) poles and the dominant 
% (least stable) pole of an LTI system
%
% Inputs: 
%   sys = A single LTI system or an array or cell array of LTI
%        systems. 
%
%        Up to two dimensional arrays (or cell arrays) of LTI systems are
%        supported. 
%
%   tol = Tolerance. Only poles with real part > tol are considered
%         unstable. Default is 1e-4;
%
% Outputs:
%   n_rhp_poles = Number of unstable poles of sys. Same size array as sys 
%                 if sys is an LTI array or cell array.     
%
%   dom_poles = The least stable pole of sys (with the highest real part).
%               Same size array as sys if sys is an LTI array or cell array.
%               May be complex valued. 
% 
% First version - S. Varigonda - 3/23/2020
% Last Changed  - 

if nargin<2
    tol = 1e-4;
end

% Get LTI array size
[~,~,m,n] = size(sys);

% To convert from LTI array to cell array, can use num2cell or mat2cell.
% No function available yet to convert from cell array to regular array for
% LTI objects. Loop needed. 

if iscell(sys)
   % convert to LTI array 
   for i=1:m
    for j=1:n
        sys_array(:,:,i,j) = sys{i,j};
    end
   end
   sys = sys_array;
   clear sys_array
end

% Assume now sys is an LTI array

% Compute # of RHP poles and identify least stable pole (highest real part)
n_rhp_poles = zeros(m,n);
dom_poles = zeros(m,n);

for i=1:m
    for j=1:n
        if order(sys(:,:,i,j))>=1
            p = pole(sys(:,:,i,j));
            n_rhp_poles(i,j) = sum(real(p)>abs(tol));
%             [~,i_max] = max(real(p)); 
%             dom_poles(i,j) = p(i_max(1)); % return only one pole per system in the array
            dom_poles(i,j) = max(real(p));             
        else
            warning(['System has no poles for LTI array or cell indices (',num2str(i),',',num2str(j),')'])
            dom_poles(i,j) = nan;
        end      
    end
end
