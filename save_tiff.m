% TODO 不占内存的写入输出流
function save_tiff(img, img_file)   
%   Save img stacks to tiff of float32
%   Args:
%       img(num):  2d/3d mat or 2d cells
%       img_file(str): file to save
%   可以直接运行本文件进行写入读取时间测试
%   生成的tiff文件，不支持使用imwrite的append模式继续写入
if nargin==0, debug=1; else, debug=0; end
%% INPUT
if debug
    img = repmat(imread('rice.png'), [1,1,100]);
    img_file = 'Test/test.tif';
end
%% define tiff tag
% ==============================测试压缩方式================================
% 测试写入时间，None 0.22, PackBits 0.38, LZW 0.56, Deflate 3.97, png 0.99
% 测试读取时间，None 0.22, PackBits 0.22, LZW 0.38, Deflate 0.30, png 0.23
% 测试写入大小，None 25  , PackBits 25  , LZW 7   , Deflate 6   , png    4
% 时间考虑 None最好， 大小速度综合考虑 pb,lzw都行，大小考虑 png
tf_tag.Compression = Tiff.Compression.None;   % packBits 基本等同不压缩
% =========================================================================
tf_tag.Photometric = Tiff.Photometric.MinIsBlack;
tf_tag.BitsPerSample = 32;    % 数据类型大小
tf_tag.SamplesPerPixel = 1;   % 几个通道
tf_tag.SampleFormat = Tiff.SampleFormat.IEEEFP;   % 数据类型为浮点数
tf_tag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
if iscell(img)
    tf_tag.ImageLength = size(img{1},1);
    tf_tag.ImageWidth = size(img{1},2);
    frames = length(img);
else
    tf_tag.ImageLength = size(img, 1);
    tf_tag.ImageWidth = size(img, 2);
    frames = size(img, 3);
end
%% write tiff
if debug, tic; end
tf = Tiff(img_file,'w');
for i = 1 : frames
    if i > 1, tf.writeDirectory(); end  % 换页后，需重新定义每一页的tag
    tf.setTag(tf_tag);  % 先定义结构体0.22s，在循环中定义0.28s
    if iscell(img)
        c_img = single(img{i});
    else
        c_img = single(img(:,:,i));
    end
    tf.write(c_img);
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