%% do everything here
addpath('/vol/vssp/ddawrk/Tu/Toolkits/matlab');
scale = 5;
PATH = pwd;

SKETCH_IMG = '/vol/vssp/ddawrk/Tu/code/colour/CIELAB/sketch/sketchcolour';
SKETCH_GF = '/vol/vssp/ddawrk/Tu/code/colour/CIELAB/sketch/GFsketch';
SKETCH_DES = sprintf('/vol/vssp/ddawrk/Tu/code/colour/CIELAB/sketch/matcolour_s%d',scale);
eval(['mkdir ' SKETCH_DES]);

DATA_IMG = '/vol/vssp/datasets/still01/SBIRflickr/Flickr15k/images/source';
DATA_GF = '/vol/vssp/ddawrk/Tu/GFHOG/GFdatabase';
DATA_DES = sprintf('/vol/vssp/ddawrk/Tu/code/colour/CIELAB/img/matcolour_s%d',scale);
eval(['mkdir ' DATA_DES]);

LST_IMG = '/vol/vssp/ddawrk/Tu/code/reWork/lst_img';
GNDTRUTH = '/vol/vssp/ddawrk/Tu/code/reWork/groundtruth';

%these files will be created in run time
CLUSTERS = fullfile(PATH, sprintf('clusters_CIELAB_s%d.mat',scale));
INVTABLE = fullfile(PATH, sprintf('img_table_CIELAB_s%d.mat',scale));
SKETCHTABLE = fullfile(PATH, sprintf('sketch_table_CIELAB_s%d.mat',scale));
OPTIMISE = fullfile(PATH, sprintf('invW_CIELAB_s%d.mat',scale));
RESULTS = fullfile(PATH, sprintf('IRID_CIELAB_s%d.mat',scale));
%% compute GF
ComputeGF_colour(SKETCH_IMG,SKETCH_GF, 0, '-e 0 -g 0');
ComputeGF_colour(DATA_IMG, DATA_GF, 1, '-e 0 -g 1');

%% extract HOG
HOGExtract(fullfile(SKETCH_GF,'mat_colour'), SKETCH_DES, scale);
HOGExtract(fullfile(DATA_GF,'mat_colour'), DATA_DES, scale);


%% generate codebook
cd '/vol/vssp/ddawrk/Tu/code/colour/'
GenCodeBook(DATA_DES, LST_IMG, CLUSTERS);

%% buid invert table
InvTable(DATA_DES, GNDTRUTH, CLUSTERS, INVTABLE);
% 
% %% build histogram of sketch
eval(['cd ' PATH]);
QueryExtract(SKETCH_DES, CLUSTERS, SKETCHTABLE);
% 
% %% offline optimisation
extra(INVTABLE, SKETCHTABLE, OPTIMISE);
% 
% %% Retrieving
IRID_test(INVTABLE, SKETCHTABLE, OPTIMISE, RESULTS);
fprintf('main done.\n');
