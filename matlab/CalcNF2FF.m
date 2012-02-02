function nf2ff = CalcNF2FF(nf2ff, Sim_Path, freq, theta, phi, varargin)
% function nf2ff = CalcNF2FF(nf2ff, Sim_Path, freq, theta, phi, varargin)
%
% Calculate the near-field to far-field transformation created by
% CreateNF2FFBox
%
% parameter:
% nf2ff:    data structure created by CreateNF2FFBox
% Sim_Path: path to simulation data
% freq:     array of frequencies to analyse
% theta,phi: spherical coordinates to evaluate the far-field on
%
% optional paramater:
% 'Mode':   'Mode', 0 -> read only, if data already exist (default)
%           'Mode', 1 -> calculate anyway, overwrite existing
%           'Mode', 2 -> read only, fail if not existing
% 'Outfile': alternative nf2ff result hdf5 file name
%            default is: <nf2ff.name>.h5
% 'Verbose': set verbose level for the nf2ff calculation 0-2 supported
%
% See also: CreateNF2FFBox, ReadNF2FF
%
% openEMS matlab interface
% -----------------------
% author: Thorsten Liebig, 2012

mode = 0;

filename = nf2ff.name;
nf2ff_xml.Planes = {};

for (n=1:numel(nf2ff.filenames_E))
    if (nf2ff.directions(n)~=0)
        nf2ff_xml.Planes{end+1}.ATTRIBUTE.E_Field = [nf2ff.filenames_E{n} '.h5'];
        nf2ff_xml.Planes{end}.ATTRIBUTE.H_Field = [nf2ff.filenames_H{n} '.h5'];
    end
end
nf2ff_xml.ATTRIBUTE.freq = freq;
nf2ff_xml.theta = theta;
nf2ff_xml.phi = phi;
nf2ff_xml.ATTRIBUTE.Outfile = [filename '.h5'];

for n=1:2:numel(varargin)-1
    if (strcmp(varargin{n},'Mode'))
        mode = varargin{n+1};
    else
        nf2ff_xml.ATTRIBUTE.(varargin{n})=varargin{n+1};
    end
end

nf2ff.xml = [Sim_Path '/' filename '.xml'];
nf2ff.hdf5 = [Sim_Path '/' nf2ff_xml.ATTRIBUTE.Outfile];

% create nf2ff structure
struct_2_xml(nf2ff.xml,nf2ff_xml,'nf2ff');

m_filename = mfilename('fullpath');
dir = fileparts( m_filename );
openEMS_Path = [dir filesep '..' filesep];

if ((exist(nf2ff.hdf5,'file') && (mode==0)) || (mode==2))
    disp('CalcNF2FF: Reading nf2ff data only...')
    nf2ff = ReadNF2FF(nf2ff);
    return;
end

savePath = pwd;
cd(Sim_Path);

try
    if isunix
        % remove LD_LIBRARY_PATH set by matlab
        system(['export LD_LIBRARY_PATH=; ' openEMS_Path 'nf2ff/nf2ff ' filename '.xml']);
    else
        system([openEMS_Path 'nf2ff/nf2ff ' filename '.xml']);
    end

    nf2ff.hdf5;
    cd(savePath);
catch
    cd(savePath);
    error 'CalcNF2FF: failed'
end

nf2ff = ReadNF2FF(nf2ff);
