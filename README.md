# 存储和读取 Tiff 堆栈 (float)

适合搞图像时使用，存储三维图像为 float32 的 tiff 文件，然后配合 Fiji 查看。

![image-20210916231054197](.img/image-20210916231054197.png)

## 使用

* 调用 save_tiff 存储三维矩阵为 tiff (float)
* 调用 read_tiff 可读取 tiff 文件 （非上述生成的应该也可以）
