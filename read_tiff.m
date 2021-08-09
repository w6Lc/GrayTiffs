function img = read_tiff(img_file)

info = imfinfo(img_file);
t = Tiff('out.tif','w');

imwrite(double(data), '2.tiff');


tagstruct.Photometric	= Tiff.Photometric.MinIsBlack;
tagstruct.Compression 	= Tiff.Compression.None;
tagstruct.BitsPerSample	= 32; 
tagstruct.SampleFormat	= Tiff.SampleFormat.IEEEFP;   % 数据类型为浮点数IEEEFP
tagstruct.ImageLength	= size(data,1);
tagstruct.ImageWidth	= size(data,2);
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
t.setTag(tagstruct)

t.write(single(data));
t.close();
end