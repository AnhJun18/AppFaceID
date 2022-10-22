function [with, height]= convertWebcamResolution(cam)
resolution = cam.Resolution;
resolution = strrep(resolution,'x',' ');
result = split(resolution);
with = str2num(result{1});
height = str2num(result{2});
end