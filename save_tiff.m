function save_tiff(img, file, fmt, tag)
%SAVETIFF Write tiff3d once using TiffSim.
%   Args: 
%     fmt: see TiffSim's func write
%     tag: same as fmt
%
%   Example:
%   >>> save_tiff(imread('rice.png'), '1.tif');
%   >>> save_tiff(imread('rice.png'), '1.tif', 'float');
if nargin==0, debug=1;
  img = double(repmat(imread('rice.png'), [1,1,10]));
  file = '1.tif';
  fmt = 'uint8';
end
if ~exist('debug', 'var'), debug=[]; end
if ~exist('fmt', 'var'), fmt=[]; end
if ~exist('tag', 'var'), tag=[]; end

%% Write
if debug
  if strcmp(fmt(1:4), 'uint') || strcmp(fmt(1:3), 'int')
    % matlab write
    tic;
    if ~exist(file,'file'), delete(file); end
    for i = 1 : size(img, 3)
      imwrite(img(:,:,i), file, 'WriteMode', 'append');
    end
    disp(['matlab 写入时间: ', num2str(toc), 's']);  % 多次打开文件，很慢
  end
  tic;
end

% ============================ start ======================================
tf = TiffSim(file, 'w');
for i = 1 : size(img, 3)
  tf.write(img(:,:,i), fmt, tag);
end
tf.close();
% =========================================================================

if debug
  disp(['写入时间: ', num2str(toc), 's']);
  tic;
  tf = TiffSim(file, 'w');
  while tf.tell() ~= tf.len()
    imread(file, i);
  end
  disp(['读取时间: ', num2str(toc), 's']);
end
end