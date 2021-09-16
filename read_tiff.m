function img = read_tiff(img_file)
%% INPUT
if nargin == 0
    img_file = 'Test/test.tif';
end
%%
tiff_info = imfinfo(img_file);
deep = length(tiff_info);
high = tiff_info(1).Height;
wide = tiff_info(1).Width;
img = zeros(high, wide, deep);

for i = 1:deep
    img(:,:,i) = imread(img_file, i);
end
end