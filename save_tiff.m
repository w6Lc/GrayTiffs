function save_tiff(img, img_file, precision)
%   Save img stacks to tiff of float32
%   Args:
%       img(num):  2d/3d mat or 2d cells
%       img_file(str): file to save
%   可以直接运行本文件进行写入读取时间测试
%   生成的tiff文件，不支持使用imwrite的append模式继续写入
if nargin==0, clc; clear; debug=1; else, debug=0;  end
if debug
  img = repmat(imread('rice.png'), [1,1,100]);
  img_file = 'Test/test.tif';
  precision = 'uint8';
end
%% define tiff tag
if ~exist('precision', 'var'), precision = 'float'; end
if iscell(img)
  img = cell2mat(img);
end

% ==============================测试压缩方式================================
% 测试写入时间，None 0.22, PackBits 0.38, LZW 0.56, Deflate 3.97, png 0.99, JPEG 
% 测试读取时间，None 0.22, PackBits 0.22, LZW 0.38, Deflate 0.30, png 0.23
% 测试写入大小，None 25  , PackBits 25  , LZW 7   , Deflate 6   , png    4
% 时间考虑 None最好， 大小速度综合考虑 pb,lzw都行，大小考虑 png
tf_tag.Compression = Tiff.Compression.None;   % packBits 基本等同不压缩
% =========================================================================
tf_tag.Photometric = Tiff.Photometric.MinIsBlack;
tf_tag.SamplesPerPixel = 1;   % 几个通道

if strcmp(precision, 'float')
  tf_tag.BitsPerSample = 32;    % 数据类型大小
  tf_tag.SampleFormat = Tiff.SampleFormat.IEEEFP;   % 数据类型为浮点数
elseif strcmp(precision, 'uint8')
  tf_tag.BitsPerSample = 8;
  tf_tag.SampleFormat = Tiff.SampleFormat.UInt;
elseif strcmp(precision, 'uint16')
  tf_tag.BitsPerSample = 16;
  tf_tag.SampleFormat = Tiff.SampleFormat.UInt;
else
  error("!!!");
end
tf_tag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tf_tag.ImageLength = size(img, 1);
tf_tag.ImageWidth = size(img, 2);
frames = size(img, 3);

%% write tiff
if debug, tic; end
tf = Tiff(img_file,'w');
for i = 1 : frames
  if i > 1, tf.writeDirectory(); end  % 换页后，需重新定义每一页的tag
  tf.setTag(tf_tag);  % 先定义结构体0.22s，在循环中定义0.28s
  if strcmp(precision, 'float')
    c_img = single(img(:,:,i));
  elseif strcmp(precision, 'uint8')
    c_img = uint8(img(:,:,i));
  elseif strcmp(precision, 'uint16')
    c_img = uint16(img(:,:,i));
  end
  tf.write(c_img);    % 必须先转换数据
end
tf.close();
if debug, disp(['写入时间: ', num2str(toc), 's']); end

% 测试时间
if debug
  tic
  for i = 1:size(img, 3)
    imread(img_file, i);
  end
  disp(['读取时间: ', num2str(toc), 's']);
end
end