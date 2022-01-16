classdef TiffSim < handle
  %TIFFSIM Read & Write tiff3d by stream without config.
  %   Example:
  %   >>> tf = TiffSim('1.tif', 'w');
  %   >>> tf.write(imread('rice.png')); tf.write(imread('rice.png'));  % write
  %   >>> tf.seek(1); tf.write(imgaussfilt(imread('rice.png')));  % overwrite
  %   >>> tf.seek(1); tf.read(); tf.read();   % read tiff
  %   >>> tf.eof()    % file end, read over
  %   >>> tf.close();
  %   >>> imfinfo('1.tif')  % can be opened by ImageJ
  %
  %   when img is double, save as float unless using `write(img, 'double')`
  %   In other conditions, save format is same as img.
  %   
  %   图像堆栈如果是统一格式的，默认便可以用 ImageJ 打开，double型除外
  %   如果每张图像格式不一致，那么可以使用 ImageJ 的虚拟堆栈打开
  %
  %   See other details in functions. Copyright 2022, https://github.com/w6Lc
  properties (Access = protected)
    tf    % inner tiff handle
    file  % file
    nums  % nums of pics 
  end

  methods
    function obj = TiffSim(file, mode)
      % mode:  None('r+') | 'w' 
      if ~exist('mode', 'var'), mode = []; end
      
      if strcmp(mode, 'w') || ~exist(file, 'file')
        obj.tf = Tiff(file, 'w');
        obj.nums = 0;
      else
        obj.tf = Tiff(file, 'r+');
        obj.nums = length(imfinfo(file));
      end
      obj.file = file;
    end

    function close(obj)
      obj.tf.close();
    end

    function pos = tell(obj)
      % pos: <1-n>
      pos = obj.tf.currentDirectory();
    end

    function seek(obj, num)
      % num: <1-n>
      obj.tf.setDirectory(num);
    end

    function nums = len(obj)
      % nums: <1-n>
      nums = obj.nums;
    end

    function is_eof = eof(obj)
      is_eof = obj.tell() > obj.len();
    end

    function info = get_info(obj)
      info = imfinfo(obj.file);
    end

    function img = read(obj)
      img = obj.tf.read();
      if obj.tell() == obj.nums
        obj.tf.writeDirectory();
      else
        obj.tf.nextDirectory();
      end
    end

    function write(obj, img, fmt, tag)
      % Args:
      %   img: <mat>(size: 2d | rgb,
      %              fmt:  <matlab_fmt>('int<n>', 'uint<n>','float', 'double', ...))
      %   fmt: None(judge from img) | <num_fmt>('uint8', 'float', 'double', ...)
      %        PS: when img is double, fmt is float.
      %   tag: None(judge from img) | <tag_struct>
      %
      % Examples:
      % >>> tf = TiffSim('1.tif', 'w');
      % >>> tf.write(imread('rice.png'), 'float');
      % >>> tf.write(imread('rice.png'), [], struct('Compression', Tiff.Compression.LZW));
      % >>> tf.write(imread('rice.png'));
      % >>> imfinfo('1.tif') % can also open use vitual stack with imageJ (256,256,3)
      if ~exist('fmt', 'var'), fmt = []; end
      if ~exist('tag', 'var'), tag = []; end
      if isempty(fmt)
        fmt = class(img);
        if isa(img, 'double'), fmt = 'float'; end  % img为double时默认保存为float
      end

      % ===============================  tag ============================
      % 测试写入时间，None 0.22, PackBits 0.38, LZW 0.56, Deflate 3.97, png 0.99, JPEG 
      % 测试读取时间，None 0.22, PackBits 0.22, LZW 0.38, Deflate 0.30, png 0.23
      % 测试写入大小，None 25  , PackBits 25  , LZW 7   , Deflate 6   , png    4
      % None最快， 大小速度综合考虑 pb,lzw，大小考虑 png
      tag_.Compression = Tiff.Compression.None;  % default None
      tag_.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

      % precision
      if strcmp(fmt(1:4), 'uint')
        tag_.SampleFormat = Tiff.SampleFormat.UInt;   % can not set twice in 1 IFD
        tag_.BitsPerSample = str2double(fmt(5:end));
        img = eval([fmt, '(img)']);
      elseif strcmp(fmt(1:3), 'int')
        tag_.SampleFormat = Tiff.SampleFormat.Int;
        tag_.BitsPerSample = str2double(fmt(4:end));
        img = eval([fmt, '(img)']);
      elseif strcmp(fmt, 'float') || strcmp(fmt, 'single')
        tag_.SampleFormat = Tiff.SampleFormat.IEEEFP;
        tag_.BitsPerSample = 32;
        img = single(img);
      elseif strcmp(fmt, 'double')
        tag_.SampleFormat = Tiff.SampleFormat.IEEEFP;
        tag_.BitsPerSample = 64;
        img = double(img);
      end

      % size
      tag_.ImageLength = size(img, 1);
      tag_.ImageWidth = size(img, 2);
      tag_.SamplesPerPixel = size(img, 3);
      if tag_.SamplesPerPixel == 1
        tag_.Photometric = Tiff.Photometric.MinIsBlack;
      else
        tag_.Photometric = Tiff.Photometric.RGB;
      end

      % rewrite
      if ~isempty(tag)
        keys = fieldnames(tag);
        for i = 1:length(keys), tag_.(keys{i}) = tag.(keys{i}); end
      end

      % ============================ write ================================
      obj.tf.setTag(tag_);
      obj.tf.write(img);  % write 后无法再setTag
      
      if obj.tell() == 0 || obj.eof()
        obj.tf.writeDirectory();
        obj.nums = obj.nums + 1;
        % matlab 初始 tell为0，修正为1; 运行正常时，obj.tell() <= obj.len() 
        if obj.tell()==1, obj.seek(1); obj.tf.writeDirectory(); end
      else
        tmp = obj.tf.currentDirectory();
        obj.tf.rewriteDirectory();
        if obj.tell() - 1 ~= obj.len()
          obj.seek(tmp+1);
        else
          obj.seek(tmp);
          obj.tf.writeDirectory();
        end
      end
    end
  end
end

