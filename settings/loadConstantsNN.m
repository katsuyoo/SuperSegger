function CONST = loadConstantsNN( res, PARALLEL_FLAG )
% loadConstants loads the parameters for the superSegger/trackOpti package.
% If you want to customize the constants DO NOT CHANGE
% THIS FILE! Rename this file loadConstantsMine.m and
% put in somehwere in the path.
% That file will load automatically rather than this one.
% When you make loadConstantsMine.m, change
% disp( 'loadConstants: Initializing.')
% to loadConstantsMine to avoid confusion.
%
% INPUT :
%   res : number for resolution of microscope used (60 or 100) for E. coli
%         or use a string as shown below
%   PARALLEL_FLAG : 1 if you want to use parallel computation
%                   0 for single core computation
%
%
% Copyright (C) 2016 Wiggins Lab 
% Written by Stella Stylianidou
% University of Washington, 2016
% This file is part of SuperSegger.
% 
% SuperSegger is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% SuperSegger is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with SuperSegger.  If not, see <http://www.gnu.org/licenses/>.

if nargin < 1 || isempty( res )
    res = 60;
end

if ~exist('PARALLEL_FLAG','var') || isempty( PARALLEL_FLAG )
    PARALLEL_FLAG = false;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Specify scope resolution                                                %                                                                       %                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Values for setting res
% '60XEc' : loadConstants 60X Ecoli
% '100XEc': loadConstants 100X Ecoli
% '60XEcLB': loadConstants 60X Ec LB Ecoli
% '60XBay'
% '60XPa'
% '100XPa' 
% resflags : {'60XEc','100XEc','60XEcLB','60XBay','60XPa','100XPa'}

resFlag = [];
if isa(res,'double' )  && res == 60
    disp('loadConstants: 60X');
    resFlag = '60XEc';
elseif isa(res,'double' )    && res == 100
    disp('loadConstants:  100X');
    resFlag = '100XEc';
elseif isa(res, 'char' );
    if strcmpi(res,'60XEc')
        resFlag = '60XEc';
    elseif strcmpi(res,'100XEc')
        disp('loadConstants:  100X Ecoli');
        resFlag = '100XEc';
    elseif strcmpi(res,'60XEcLB')
        disp('loadConstants:  60X LB Ecoli');
        resFlag = '60XEcLB';
    elseif strcmpi(res,'60XBay')
        disp('loadConstants:  60X Baylyi');
        resFlag = '60XBay';
     elseif strcmpi(res,'60XPa')
        disp('loadConstants:  60X Pseudemonas');
        resFlag = '60XPa';
    elseif strcmpi(res,'100XPa')
        disp('loadConstants:  100X Pseudemonas');
        resFlag = '100XPa';
    end
end



% Settings for alignment in differnt channels - modify for your microscope
CONST.imAlign.DAPI    = [-0.0354   -0.0000    1.5500   -0.3900];
CONST.imAlign.mCherry = [-0.0512   -0.0000   -1.1500    1.0000];
CONST.imAlign.GFP     = [ 0.0000    0.0000    0.0000    0.0000];

CONST.imAlign.out = {CONST.imAlign.GFP, ...   % c1 channel name
    CONST.imAlign.GFP,...  % c2 channel name
    CONST.imAlign.GFP};        % c3 channel name

                                      

% Parallel processing on multiple cores settings :
if PARALLEL_FLAG
    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(poolobj)
        poolobj = parpool('local');
    end
    poolobj.IdleTimeout = 360; % close after idle for 3 hours
    CONST.parallel.parallel_pool_num = poolobj.NumWorkers;
else
    CONST.parallel.parallel_pool_num = 0;
end

CONST.parallel.xy_parallel = 0;
CONST.parallel.PARALLEL_FLAG = PARALLEL_FLAG;
CONST.parallel.show_status = ~(CONST.parallel.parallel_pool_num);



CONST.align.ALIGN_FLAG = 1;

% segmentation parameters
CONST.seg.segmentScoreFun = @scoreNeuralNet
CONST.seg.segFun= @ssoSegFunPerReg
CONST.seg.OPTI_FLAG = 1
CONST.seg.names = getSegInfoNames;

% CONST.superSeggerOpti : need to be set separately for each constant


% region optimization parameters
CONST.regionOpti.MAX_NUM_RESOLVE =  5000;
CONST.regionOpti.MAX_NUM_SYSTEMATIC =  8;
CONST.regionOpti.CutOffScoreHi = 10;
CONST.regionOpti.CutOffScoreLo = -10;
CONST.regionOpti.fignum =  1;
CONST.regionOpti.Nt = 500;
CONST.regionOpti.minGoodRegScore = 10;
CONST.regionOpti.neighMaxScore = 10;
CONST.regionOpti.ADJUST_FLAG = 1;
CONST.regionOpti.MAX_WIDTH = 20; % CHANGE : should be different for each cell type
CONST.regionOpti.MAX_LENGTH = 25; % CHANGE : should be different for each cell type - this should be called min_length
CONST.regionOpti.DE_norm = 0.5000;


% region score functions
[~,CONST.regionScoreFun.NUM_INFO] = getRegNames3;
CONST.regionScoreFun.names = getRegNames3;
CONST.regionScoreFun.fun = @scoreNeuralNet;
CONST.regionScoreFun.props = @cellprops3;

% trackOpti constants
CONST.trackOpti.MIN_AREA = 20; % CHANGE : should be different for each cell type
CONST.trackOpti.NEIGHBOR_FLAG = 0; 
CONST.trackOpti.pole_flag = 1;


% linking constants
CONST.trackOpti.OVERLAP_LIMIT_MIN = 0.0800
CONST.trackOpti.DA_MAX = 0.3;     
CONST.trackOpti.DA_MIN = -0.1;
CONST.trackOpti.LYSE_FLAG = 0;
CONST.trackOpti.REMOVE_STRAY = 1;
CONST.trackOpti.SCORE_LIMIT_DAUGHTER = -30;
CONST.trackOpti.SCORE_LIMIT_MOTHER = -30;
CONST.trackOpti.MIN_CELL_AGE = 5;
CONST.trackOpti.linkFun = @multiAssignmentFastOnlyOverlap;


% pixelsize
if all(ismember('100X',resFlag))
    CONST.getLocusTracks.PixelSize        = 6/60;
elseif all(ismember('60X',resFlag))
    CONST.getLocusTracks.PixelSize        = 6/100;
else
    CONST.getLocusTracks.PixelSize        = [];
end

% getLocusTracks Constants
CONST.getLocusTracks.FLUOR1_MIN_SCORE = 3;
CONST.getLocusTracks.FLUOR2_MIN_SCORE = 3;
CONST.getLocusTracks.FLUOR1_REL       = 0.3;
CONST.getLocusTracks.FLUOR2_REL       = 0.3;
CONST.getLocusTracks.TimeStep         = 1;


% view constants
CONST.view.showFullCellCycleOnly = true;
CONST.view.orientFlag            = true;
CONST.view.falseColorFlag        = false;
CONST.view.maxNumCell            = [];
CONST.view.LogView         = false;


% super resolution constants
% Const for findFocusSR
CONST.findFocusSR.MAX_FOCUS_NUM = 8;
CONST.findFocusSR.crop          = 4;
CONST.findFocusSR.gaussR        = 1;
CONST.findFocusSR.MAX_TRACE_NUM = 1000;
CONST.findFocusSR.WS_CUT        = 50;
CONST.findFocusSR.MAX_OFF       = 3;
CONST.findFocusSR.I_MIN         = 150;
CONST.findFocusSR.mag           = 16;
CONST.findFocusSR.MIN_TRACE_LEN = 0;
CONST.findFocusSR.R_LINK        = 2;
CONST.findFocusSR.R_LINK        = 2;
CONST.findFocusSR.SED_WINDOW    = 10;
CONST.findFocusSR.SED_P         = 10;
CONST.findFocusSR.A_MIN         =  6;

% Const for SR
CONST.SR.opt =  optimset('MaxIter',1000,'Display','off', 'TolX', 1e-8);

% Setup CONST calues for image processing
CONST.SR.GausImgFilter_HighPass = fspecial('gaussian',141,10);
CONST.SR.GausImgFilter_LowPass3 = fspecial('gaussian',21,3);
CONST.SR.GausImgFilter_LowPass2 = fspecial('gaussian',21,2);
CONST.SR.GausImgFilter_LowPass1 = fspecial('gaussian',7,1.25);
CONST.SR.maxBlinkNum = 2;

% this is the pad size for cropping regions for fitting
CONST.SR.pad = 8;
CONST.SR.crop = 4;
CONST.SR.Icut = 1000;
CONST.SR.rcut = 10; % The maximum distance between frames for two PSFs 
% to be considered two seperate PSFs.

CONST.SR.Ithresh = 2; % threshold intensity in std for including loci in analysis 




if strcmp (resFlag,'60XEc')
    CONST = load('60XEcnn_FULLCONST.mat');
elseif strcmp (resFlag,'100XEc')
    CONST = load('100XEcnn_FULLCONST.mat');
elseif strcmp (resFlag,'60XEcLB')
    CONST = load('60XEcLBnn_FULLCONST.mat');
elseif strcmp (resFlag,'60XBay')
    CONST = load('60XBaynn_FULLCONST.mat');
    elseif strcmp (resFlag,'100XPa')
    CONST = load('100xPann_FULLCONST.mat');
    elseif strcmp (resFlag,'60XPa')
    CONST = load('60XPann_FULLCONST.mat');
else
    error('loadConstants: Constants not loaded : no match found. Aborting.');
end


end
