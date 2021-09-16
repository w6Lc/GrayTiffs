function img = read_tiff(img_file)
%	Read tiff of 2d or 3d
%
%   Args:
%       img_file (str): tiff of 2d or 3d
%
%   Returns:
%       img (num): 2d or 3d mat
%
%   不要直接运行本文件，否则返回值 img 直接输出在控制台
%   
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

if nargin == 0, figure, imshow(img(:,:,1), []); end

end