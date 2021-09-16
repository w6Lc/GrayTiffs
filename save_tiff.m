function save_tiff(img, img_file)   
% 此tiff文件，不支持imwrite的append模式
%% INPUT
if nargin == 0
    img = imread('rice.png');
    img = repmat(img, [1,1,100]);
    img_file = 'Test/test.tif';
    debug = 1;
else
    debug = 0;
end
%%
tf_tag.Photometric = Tiff.Photometric.MinIsBlack;
% 测试写入时间，None 0.22, PackBits 0.38, LZW 0.56, Deflate 3.97, png 0.99
% 测试读取时间，None 0.22, PackBits 0.22, LZW 0.38, Deflate 0.30, png 0.23
% 测试写入大小，None 25  , PackBits 25  , LZW 7   , Deflate 6   , png    4
% 时间考虑 None最好， 大小速度综合考虑 pb,lzw都行，大小考虑 png
tf_tag.Compression = Tiff.Compression.None;   % packBits 基本等同不压缩
tf_tag.BitsPerSample = 32;    % 数据类型大小
tf_tag.SamplesPerPixel = 1;   % 几个通道
tf_tag.SampleFormat = Tiff.SampleFormat.IEEEFP;   % 数据类型为浮点数
tf_tag.ImageLength = size(img, 1);
tf_tag.ImageWidth = size(img, 2);
tf_tag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

if debug, tic; end
tf = Tiff(img_file,'w');
for i = 1 : size(img, 3)
    if i > 1, tf.writeDirectory; end  % 换页后，需重新定义每一页的tag
    tf.setTag(tf_tag);  % 先定义结构体0.22s，在循环中定义0.28s
    tf.write(single(img(:,:,i)));
end
tf.close();
if debug, disp(['写入时间: ', num2str(toc), 's']); end

% 测试时间
if debug
    tic
    for i = 1:100
        imread(img_file, i);
    end
    disp(['读取时间: ', num2str(toc), 's']);
end
end