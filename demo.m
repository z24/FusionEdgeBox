function demo
% Demo code for FusionEdgeBox.
%
% Copyright Youjie Zhou
% All rights reserved.

load('demo.mat');

[bbs, objV, floV] = fusionEdgeBoxesMex(...
    data.objE, data.objO,...
    data.floE, data.floO,...
    o.alpha, o.beta, o.minScore, o.maxBoxes,...
    o.edgeMinMag_obj, o.edgeMinMag_flo,...
    o.edgeMergeThr, o.clusterMinMag,...
    o.maxAspectRatio, o.minBoxArea, o.gamma, o.kappa,...
    o.objW, o.floW);

imwrite(objV, 'cluster-obj.jpg');
imwrite(floV, 'cluster-flo.jpg');

im = im2double( imread('00019.png') );
map = BoxMap(bbs, size(im,2), size(im,1));
BoxMapViz(map, im, 'map.jpg');
end

function map = BoxMap(bbs, w, h)
% Produce a weighted sailency map by stacking all the boxes together.
%   bbs: a matrix where each row contains a box.
%   w: image width.
%   h: image height.
map = zeros(h, w);
for i = 1 : size(bbs, 1)
    x1 = bbs(i,1); y1 = bbs(i,2);
    x2 = x1 + bbs(i,3) - 1; y2 = y1 + bbs(i,4) - 1;
    if(x2 > w) x2 = w; end
    if(y2 > h) y2 = h; end
    map(y1:y2, x1:x2) = map(y1:y2, x1:x2) + 1;
end
map = NORM_ZEROONE(map);
end

function BoxMapViz(map, im, outName)
% Overlay the weighted map on the image.
%   im = im2double(...);
fig = figure('visible', 'off');
SetFigSize(fig, im);
ShowImage(fig, im);
hold on;

h = imagesc(map);
set(h, 'AlphaData', 0.6);

SaveFig(fig, outName);
close(fig);
end

function SetFigSize(fig, im, r)
if(nargin ~= 3)
    r = 200;
end
set(fig, 'PaperPosition', [0,0,size(im,2), size(im,1)]/r);
end

function SaveFig(fig, fileName, r)
if(nargin ~= 3)
    r = 200;
end
print(fig, fileName, '-dtiff', sprintf('-r%d',r));
end

function ShowImage(fig, im)
set(0, 'currentfigure', fig);
imshow(im, 'InitialMagnification', 'fit', 'Border', 'tight');
end

function [out, minV, maxV] = NORM_ZEROONE(data)
minV = min(min(data(:)));
maxV = max(max(data(:)));
out = (data - minV) / (maxV - minV + 1e-10);
end