function [x, y, fig] = verifyConvex(x0, v, t1, t2, fFun, varargin) 
% ----------------------------------------------------------------------
% 
% Summary of this function goes here
% Detailed explanation goes here


% Author: Tri Nguyen (nguyetr9@oregonstate.edu)

% ----------------------------------------------------------------------
    
    % Check the options structure.
    p = inputParser;
    p.addOptional('verbose', 0);
    p.addOptional('debug', 0);
    p.addOptional('grain', 100);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    options = p.Results;

    t = linspace(t1, t2, options.grain);
    x = arrayfun(@(tt) x0 + tt*v, t, 'UniformOutput', false);
    y = cellfun(@(x) fFun(x), x);
    fig = figure();
    plot(t, y);
end
