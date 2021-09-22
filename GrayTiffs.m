classdef GrayTiffs < handle
    %GrayTiffs 精度为float的灰度图像堆栈
    %   打开输入输出流进行连续单张读写
    %   Examples:
    %       % 读写
    %       clear; clc;
    %       tf = GrayTiffs('Test\1.tif', 'w');
    %       tf.write(imread('rice.png')); tf.write(imread('rice.png'));
    %       tf.close();
    %       tf = GrayTiffs('Test\1.tif', 'r');
    %       figure, imshow(tf.read(),[]); imshow(tf.read(),[]);
    %       tf.read();
    
    properties
        img_file = ''
        high=0  % 高
        wide=0  % 宽
        deep=0  % 帧数
        fp_deep=1 % 当前指向帧数（在前）
        tiff_tag
        tiff_handle % matlab 的 class Tiff
    end
    
    methods
        function obj = GrayTiffs(img_file, mode)    % 输入输出流不能混用
            % 打开文件创建输入输出流
            obj.img_file = img_file;
            
            if strcmp(mode, 'w')
                obj.tiff_handle = Tiff(img_file,'w');
            elseif strcmp(mode, 'r')
                tiff_info = imfinfo(img_file);
                obj.deep = length(tiff_info);
            else
                error('读写模式错误');
            end
        end
        
        function close(obj)
            obj.tiff_handle.close();
        end
        
        function img = read(obj)
            if obj.fp_deep > obj.deep
                error('读取溢出');
            end
            img = imread(obj.img_file, obj.fp_deep);
            obj.fp_deep = obj.fp_deep + 1;
        end
        
        function write(obj, img2d)
            tf = obj.tiff_handle;       % 指针即handle可以复制
            if obj.fp_deep == 1
                [obj.high,obj.wide] = size(img2d);
                obj.initTag(obj.high,obj.wide);
            else
                tf.writeDirectory();
            end
            tf.setTag(obj.tiff_tag);
            tf.write(single(img2d));
            obj.fp_deep = obj.fp_deep +1;
        end
        
        function initTag(obj, high, wide)  % 初始化 tiff_tag
            % 注意这里不能复制，tiff_tag是值不是指针
            obj.tiff_tag.Compression = Tiff.Compression.None;
            obj.tiff_tag.Photometric = Tiff.Photometric.MinIsBlack;
            obj.tiff_tag.BitsPerSample = 32;    % 数据类型大小
            obj.tiff_tag.SamplesPerPixel = 1;   % 几个通道
            obj.tiff_tag.SampleFormat = Tiff.SampleFormat.IEEEFP;   % 数据类型为浮点数
            obj.tiff_tag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            obj.tiff_tag.ImageLength = high;
            obj.tiff_tag.ImageWidth = wide;
        end
    end
end

