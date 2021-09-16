# 存储浮点格式的 Tiff 堆栈 

搞图像使用，存储三维图像为 float32 的 tiff 文件，之后可以配合 Fiji 查看。

![image-20210916231054197](.img/image-20210916231054197.png)

## 使用

* 调用 save_tiff 存储三维矩阵为 tiff (float)
* 调用 read_tiff 可读取 tiff 文件 （非上述生成的应该也可以）
