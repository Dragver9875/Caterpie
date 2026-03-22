function setup_paths()
% Add project folders to path

thisFile = mfilename('fullpath');
matlabRoot = fileparts(thisFile);
projectRoot = fileparts(matlabRoot);

addpath(genpath(matlabRoot));

assignin('base','PROJECT_ROOT',projectRoot);
assignin('base','MATLAB_ROOT',matlabRoot);

fprintf('[setup_paths] Project root: %s\n', projectRoot);
fprintf('[setup_paths] MATLAB path configured.\n');
end