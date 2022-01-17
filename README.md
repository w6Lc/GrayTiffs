# TiffSim

`TiffSim` 基于 matlab 的 `Tiff` 库进行封装简化，避免读写 Tiff 堆栈的复杂调用，也支持写入自定义的 Tiff-Tag.

可替代方案： `imread` ，但是不支持负数、浮点数，定制化功能较弱。

## 功能

* `TiffSim`：创建读写 Tiff 堆栈数据流，可寻址、读写
* `read_tiff`：一次性读取 Tiff 堆栈数据，或者读取 size
* `save_tiff`：一次性写入 Tiff 堆栈数据，支持自定义 `Tiff` 库的相关 tag

## 使用

```matlab
% TiffSim 创建写入流(可读取)
tf = TiffSim('1.tif', 'w');             % use TiffSim('1.tif') not to empty org file
tf.write(imread('rice.png'));           % write
tf.write(imread('rice.png'), 'float');  % write float
tf.write(imread('rice.png'), [], struct('Compression', Tiff.Compression.LZW)); % with tag
tf.seek(1); tf.write(imgaussfilt(imread('rice.png')));    % overwrite a slice
tf.seek(1); tf.read(); tf.read();  tf.read();             % read tiff
tf.eof()            % file end, read over
tf.close();
imfinfo('1.tif')    % can be opened by ImageJ using vitual stack

% save_tiff 一次写入 Tiff 堆栈数据
save_tiff(imread('rice.png'), '1.tif');
save_tiff(imread('rice.png'), '1.tif', 'float');

% read_tiff 一次读取 Tiff 堆栈数据
img = read_tiff('1.tif');
[high, wide, deep] = read_tiff('1.tif', 'size');
```

