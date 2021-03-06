% Matlab script to serve as a template for post-processing routines
% applied to modeled streamflow outputs from PRMS for SFPUC reservoirs
% r. walters, sfpuc, june 2020

% % % specify evaluation period (serial dates, daily timestep)
EP = datenum(1971,10,1) : datenum(2015,9,30);

% % % load model outputs % % %
% load model data
load('PRMS_LVTA_Outputs.mat');          % matlab structure containing PRMS model outputs
DT   = QDAT.T;                          % serial date array associated with each model time step
[~, idx] = intersect(DT, EP);           % indices corresponding to the evaluation period EP, length = N
QHH  = QDAT.QHH(idx);                   % Hetch Hetchy modeled inflow, subset to EP
QCH  = QDAT.QCH(idx);                   % Cherry modeled inflow, subset to EP
QDP  = QDAT.QDP(idx);                   % Don Pedro intervening modeled inflow, subset to EP
QLAG = QDAT.QLAG(idx);                  % Tuol at La Grange modeled inflow, subset to EP
QMOD_ALL = [QHH QCH QDP QLAG];          % container for all raw modeled streamflow outputs [N x 4]
                                        % note that QLAG is simply the sum QHH + QCH + QDP
                                        % however, the LAG post-processing
                                        % model is not equal to the sum of the three
                                        % post-processed models
                                        

QMOD_All_PP = QMOD_ALL;                 % container for the post-processed outputs

T = DT(idx);                            % subset data array to evaluation period, EP

% % % produce a date vector from T to store each year, month and day
% e.g., DV = [1971 10 1 0 0 0 
%             1971 10 2 0 0 0 
%               ...
%                   ...
%             2015 9 30 0 0 0]          % [N x 6], columns correspond to year, month, day, hour, minute, second, respectively
DV = datevec(T);                        % matlab date vector, as described above

% extract the month number from the array DV
allMonths = DV(:,2);                    % [N x 1], column vector containing numeric month for all timesteps in T


% % % load meteorology data (from prms input file)
load('HistoricInputFile_1969_2017.mat');% matlab structure containing the prms input file data (HistoricDataFile.Data)
dt   = dat.dt;                          % serial date array
prcp = dat.prcp;                        % daily precipitation
tmax = dat.tmax;                        % max daily air temp
tmin = dat.tmin;                        % min daily air temp
tavg = (tmax + tmin)./2;                % average daily air temp for each station
tIndex = nanmean(tavg,2);               % index air temperature, daily average of all stations [N x 1]
pcpIndex = nanmean(prcp,2);             % index precip, daily average of all stations [N x 1]
[~, cInds] = intersect(dt, T);          % indices corresponding to the evaluation period, EP

% * note that pcpIndex is not subset to the 'cInds' indices until cpi is
% calculated in the outer-most for loop below



% % % --------- BEGIN CALCULATION ROUTINES --------------------------------


% % % calculate a 15-day trailing sum of tIndex, TSS
% e.g., TSS_i = (TSS_i-14 + TSS_i-13 ... TSS_i-1 + TSS_i)
TSS = movsum(tIndex, [14 0]);           % 15-point trailing moving sum (movsum is a canned matlab function)

% % % load fitting parameters for polynomial adjustment function
%     each column represents parameters p1-p4 for each of 3 temporal bins
%     column one:   Nov-Feb
%     column two:   Mar-Jun
%     column three: Jul-Oct
P_HH = [   -0.0031    0.0023   -0.0127      % Hetch Hetchy
           -0.0122   -0.0025    0.0094      
            2.4722   -0.7188    8.9121
            3.7852    1.0779   -9.6569  ];  
        
P_CH = [   -0.0006   -0.0007   -0.0026      % Cherry
           -0.0099    0.0070    0.0263
            0.5472    0.5265    2.4669
            2.9746   -5.9535  -25.6689  ];
        
P_DP = [   -0.0022   -0.0006    0.0005      % Don Pedro
            0.0204    0.0217    0.0158
            1.3324    0.6075   -0.4515
           -16.3090 -18.6052  -12.5753  ];
       
P_LAG = [  -0.0010   -0.0004   -0.0031      % La Grange
            0.0008    0.0088    0.0332
            0.8516    0.4349    2.7864
           -7.0699   -9.0777  -31.4835  ];
       
% % % concatenate the fitting parameters into a single data cube of size [4 x 3 x 4]
P_ALL = cat(3, P_HH, P_CH, P_DP, P_LAG);    
       
PMonths = [ 11     3     7                  % monthly bins for paramter fits
            12     4     8
            1      5     9
            2      6    10  ];

% % % specify CPI Beta Values for each model (HH, CH, DP, LaG)
Beta_Array = [0.91  0.99  0.99  0.99];      % Beta values for CPI computation

% % % Specify coefficients for Box-Cox model data transformation
c       = [10.3219    6.7181    9.8626   26.0570];  
Lambda  = 0.20;

nM = 4;                                     % number of models

for j = 1 : nM                              % iteration for each model (nM=4)
    
    % % % specify containers for j'th model time series (raw and post-processed)
    QMOD    = QMOD_ALL(:,j);                % j'th modeled streamflow
    QMOD_PP = QMOD;                         % container for the post-processing output
    
    % % % compute B-C transformation of the model data
    Z_mod   = ((QMOD + c(j)).^Lambda - 1) ./ Lambda;
    
    % % % compute Current Precip Index (CPI) for model j
    Beta    = Beta_Array(j);                % j'th Beta parameter
    CPIndex = CPI(pcpIndex, Beta, dt);      % compute CPI (see CPI subroutine)
    cpi     = CPIndex(cInds);               % subset CPI for indices in EP
        
    % % % iterate over each column in PMonths [N = 3] and apply corrections
    for q = 1 : size(PMonths,2)                 
        
        % % % get indices in allMonths array corresponding to months in column q
        %     that is, retrieve all indices with months appearing in column q
        %     of the 'PMonths' matrix
        m_i = find(ismember(allMonths, PMonths(:,q)));
              
        % % % get the cpi and TSS values for the m_i indices
        mCPI = cpi(m_i);
        mTI  = TSS(m_i);
        
        % % % get the transformed model data for the m_i indices
        Z_i = Z_mod(m_i);
           
        % % % get the model fit parameters for model j and temporal bin q
        P = P_ALL(:, q, j);
        
        % % % apply post-processing function to all transformed model data in subset Z_i
        eta   = P(1).*mCPI.*mTI + P(2).*mTI + P(3).*mCPI + P(4);    % empirical multilinear error model
        Z_Ana = Z_i + eta;                                          % updated transformed model
        QMOD_PP(m_i) = (Lambda .* Z_Ana + 1).^(1/Lambda) - c(j);    % invert the transformation
        
    end
    
    % % % update the j'th column in the post-processed model output array
    QMOD_All_PP(:, j) = QMOD_PP;
    
end
     