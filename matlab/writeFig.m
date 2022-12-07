function CO = writeFig(filename, varargin)
%writeFig Saves a figure in eps and Matlab formats. The figure is formatted to best use with Latex.
%
%   writeFig('Filename') Saves with default width and height of 15cm x 8cm, which gives excellent results with Latex resizing (figure fonts stay at a good size compared to text fonts).
%
%   writeFig('Filename', height) Saves with default width = 15 cm and height specified.

%  writeFig('Filename', width, height) Saves with default width and height specified.

if nargin == 1
	width = 15;
	height = 8;
end

if nargin == 2
	width = 15;
	height = varargin{1};
end

if nargin == 3
	width = varargin{1};
	height = varargin{2};
end

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 width height]);

%Set line width to thicker
hlines = findobj(gcf,'type','line');
%set(hlines,'LineWidth',1);

%Save as matlab fig (for future refinement) and as eps (to use in latex).
[path,name,ext] = fileparts(filename);
name=strrep(name, '.', '_');
ext=strrep(ext, '.', '_');
filename=fullfile(path,[name ext]);
print('-deps2c', strcat(filename, '.eps'));
saveas(gcf, strcat(filename, '.fig'), 'fig');
