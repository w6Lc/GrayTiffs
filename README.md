# GrayTiffs

读取或存储 tiff 堆栈（uint8,uint16,float32），之后可以配合相关软件查看。

![image-20210916231054197](.img/image-20210916231054197.png)

## 使用

* 调用 save_tiff 存储三维矩阵为 tiff 堆栈（uint8,uint16,float32）
* 调用 read_tiff 可读取 tiff 堆栈 （任意格式）
* 调用 GrayTiffs 创建读取或者写入tiff流
