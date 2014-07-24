clc
clear all
close all

%% Data
% Setting
data_directory = 'data/';
original_data_directory = 'original/';
transformed_data_directory = 'transformed/';
object_name = 'bunny/';
conf_name = 'bun.conf';
mkdir([data_directory, transformed_data_directory, object_name]);

% Parse the configuration file
conf_file_name = [data_directory, original_data_directory, object_name, conf_name];
fid = fopen(conf_file_name);
tline = fgetl(fid); % comment out the first line
% bmesh filename.ply tx ty tz w x y z
Data = textscan(fid, '%s %s %f %f %f %f %f %f %f');
fclose(fid);


%% Transform
for index = 1:length(Data{1})
    % file name
    file_name = Data{2}{index};    
    disp(file_name);
    
    % read
    file_path = [data_directory, original_data_directory, object_name, file_name];
    [Tri, Pts] = ply_read(file_path, 'tri');
    
    % translate
    translate = [Data{3}(index), Data{4}(index), Data{5}(index)];
    Pts = bsxfun(@plus, Pts, translate');
    
    % rotate
    quaternion = [Data{6}(index), Data{7}(index), Data{8}(index), Data{9}(index)];
    Pts = quatrotate(quaternion, Pts');
    
    % write
    file_path = [data_directory, transformed_data_directory, object_name, file_name];
    Ply.vertex.x = Pts(:, 1);
    Ply.vertex.y = Pts(:, 2);
    Ply.vertex.z = Pts(:, 3);
    ply_write(Ply, file_path, 'ascii');
end