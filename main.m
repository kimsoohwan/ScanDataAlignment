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
Data = textscan(fid, '%s %s %f %f %f %f %f %f %f'); % bmesh filename.ply tx ty tz w x y z
fclose(fid);

% custom rotation matrix
% x <----    =>   ^ z
%      / |        |
%     /  |       / ----> y
%    z   y     x/
R = [ 0,  0,  1
     -1,  0,  0
      0, -1,  0];

% camera
translate = [-0.0172, -0.0936, -0.734 ];
quaternion = [-0.0461723, 0.970603, -0.235889, 0.0124573];
camera_center = translate;
camera_center = quatrotate(quaternion, camera_center);

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
    Pts = Pts * R';
    
    % write
    file_path = [data_directory, transformed_data_directory, object_name, file_name];
    Ply.vertex.x = Pts(:, 1);
    Ply.vertex.y = Pts(:, 2);
    Ply.vertex.z = Pts(:, 3);
    ply_write(Ply, file_path, 'ascii');
    
    % camera
    new_camera_center = camera_center + translate;
    new_camera_center = quatrotate(quaternion, new_camera_center);
    new_camera_center = new_camera_center * R';
    file_path = [data_directory, transformed_data_directory, object_name, file_name(1:end-4), '_camera_position.txt'];
    %save(file_path, 'new_camera_center', '-ASCII');
    fileID = fopen(file_path,'w');
    fprintf(fileID, '%.7e\t%.7e\t%.7e\n', new_camera_center);
    fclose(fileID);
end