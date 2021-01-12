function [c_i, dt] = CPI(Precip, beta, time)
% current precipitation index (CPI) calculation routine
% as desribed in:
% Smakhtin, V. Y., Masse, B. 2000. Continuous daily hydrograph simulation
% using duration curves of a precipitation index. Hydrological Processes
% 14: 1083-1100.
% r. walters, sfpuc, june 2020
%
% INPUT:
%       Precip: instantaneous precipitation time series vector
%       beta:   recession coefficient
%       time:   time array corresponding to precipitation input series
%

% initialize container (all zeroes) for function output variable, ci
c_i = 0 .* ones(length(Precip),1);          

for t = 2:length(c_i)
    c_i(t) = Precip(t) + beta * c_i(t-1);
end

dt = time;
