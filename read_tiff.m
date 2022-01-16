function varargout = read_tiff(file, mode)
%READTIFF Read tiff3d once to img using TiffSim.
%   Args:
%     file:   '<file>'
%     mode:   None | 'size'
%   
%   Returns:
%     when only_size==None:    img
%     when only_size=='size':  [high, wide, deep]
% 
%   Example:
%   >>> img = read_tiff('1.tif');
%   >>> [high, wide, deep] = read_tiff('1.tif', 'size');

%% 
if nargin == 0, debug = 1;
  file = '1.tif';
%   mode = 'size';
end
if ~exist('debug', 'var'), debug = []; end
if ~exist('mode', 'var'), mode = []; end

%%
info = imfinfo(file);
[high, wide, deep] = deal(info(1).Height, info(1).Width, length(info));
if strcmp(mode, 'size')
  varargout = {high, wide, deep};
  return
end

tf = TiffSim(file);
tmp = tf.read();
img = zeros(high, wide, deep, class(tmp));
img(:,:,1) = tmp;

if debug, tic; end
for i = 2:deep
  img(:,:,i) = tf.read();
end
tf.close();
varargout = {img};
if debug
  disp(['读取时间: ', num2str(toc), 's']);
  figure, imshow(img(:,:,1), []); 
end
end