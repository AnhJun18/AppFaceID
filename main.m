function varargout = main(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, ~, handles, varargin)
global loopFlag;
loopFlag = true;

%set solo
axes(handles.logo);
logo = imread('.\assets\Images\logo.png');
imshow(logo)

%set webcam
handles.output = hObject;
handles.cam = webcam;
[imWidth, imHeight] = convertWebcamResolution(handles.cam);
axes(handles.camera)
handles.hImage=image(zeros(imHeight,imWidth,1),'Parent',handles.camera);
preview(handles.cam, handles.hImage)
set(handles.enableWebcam, 'Enable', 'off');
guidata(hObject, handles);

function varargout = main_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


% --- Executes on button press in collect.
function collect_Callback(~, eventdata, handles)
%name for object before collect
data = inputdlg('Name Object', 'Input name of object ', [1 50]);
nameObject = data{1};
isTraining = 'No';
 cd('DataCollect')
if(isempty(nameObject))
    warndlg('Please enter name of object')
    cd('..');
elseif exist(string(nameObject), 'dir')
     warndlg('Name object already exist')
     cd('..');
else 
    set(handles.result, 'String','Complete:0%');
    cam = handles.cam;
    %if cam off open cam
    if(strcmp(cam, 'null'))
        h = findobj('Tag','enableWebcam');
       cam = enableWebcam_Callback(h, eventdata, handles);
    end
    %disable buttons
    handlesArray = [handles.stop, handles.recognition, handles.collect,handles.training, handles.disableWebcam];
    set(handlesArray, 'Enable', 'off');
    faceDetector = vision.CascadeObjectDetector;
    c=50;
    status = mkdir(string(nameObject));
    if (status ==1)  
        cd(nameObject);
    else 
        warndlg('Cannot create fodler!')
    end
    
    temp=0;
    while true 
        e = cam.snapshot;
        bboxes = step(faceDetector,e);
        if(sum(sum(bboxes)) ~= 0)
            if(temp >=c)
                isTraining = questdlg('Are you want to training data right now?', 'Question', 'No', 'Yes', 'No');
                break;
            else
                es=imcrop(e, bboxes(1,:));
                es= imresize(es,[227 227]);
                filename= strcat(num2str(temp),'.bmp');
                imwrite(es,filename);
                temp=temp+1;
                percent = floor(100 / c * 1.0 * temp);
                message = strcat('Complete: ', num2str(percent), '%');
                set(handles.result, 'string',message);
                drawnow;
            end
        else 
           drawnow;
        end
    end
    cd('..\..');
    if(strcmp(isTraining, 'Yes'))
        strcmp(isTraining, 'Yes')
        h = findobj('Tag','training');
        training_Callback(h,eventdata,handles);
    end
    set(handlesArray, 'Enable', 'on');
    set(handles.result, 'String','');
end


% --- Executes on button press in recognition.
function recognition_Callback(~, eventdata, handles)
global loopFlag;
loopFlag = true;
if (isfile('myNet1.mat'))
    %disable buttons
    handlesArray = [handles.stop, handles.recognition, handles.collect,handles.training, handles.enableWebcam, handles.disableWebcam];
    set(handlesArray, 'Enable', 'off');
    load myNet1;
    faceDetector = vision.CascadeObjectDetector;
    cam = handles.cam;
    %if cam off, open cam
    if(strcmp(cam, 'null'))
        h = findobj('Tag','enableWebcam');
       cam = enableWebcam_Callback(h, eventdata, handles);
    end
    while true 
        if(loopFlag == false)
            set(handles.result, 'string', '');
            set(handlesArray, 'Enable', 'on');
            break;
        else
            e = cam.snapshot;
            bboxes = step(faceDetector,e);
            if(sum(sum(bboxes)) ~= 0)
                es=imcrop(e, bboxes(1,:));
                es= imresize(es,[227 227]);
                label = classify(myNet1,es);
                set(handles.result, 'string', char(label), 'foregroundcolor', 'g');
            else 
                set(handles.result, 'string', 'No Found Face', 'foregroundcolor', 'r');
            end
        end
    end
else
    warndlg('No training data available');
end


% --- Executes on button press in exit.
function exit_Callback(~, ~, ~)
closereq();


% --- Executes on button press in stop.
function stop_Callback(~, ~, ~)
global loopFlag;
loopFlag = false;


% --- Executes on button press in training.
function training_Callback(~, ~, handles)
isTraining = questdlg('The training progress may have take some time, do you want to continue ?', 'Question', 'Cancel', 'Continue', 'Cancel');
if(strcmp(isTraining, 'Continue'))
    handlesArray = [handles.stop, handles.recognition, handles.collect,handles.training];
    set(handlesArray, 'Enable', 'off');
    set(handles.result, 'String', 'Training...', 'foregroundcolor', 'r');
    pause(1)
    Training();
    set(handles.result, 'String', 'Completed', 'foregroundcolor', 'g');
    set(handlesArray, 'Enable', 'on');
end



% --- Executes on button press in enableWebcam.
function [cam] = enableWebcam_Callback(hObject, ~, handles)
handles.cam = webcam;
cam = handles.cam;
[imWidth, imHeight] = convertWebcamResolution(handles.cam);
axes(handles.camera)
handles.hImage=image(zeros(imHeight,imWidth,1),'Parent',handles.camera);
preview(handles.cam, handles.hImage)
set(handles.enableWebcam, 'Enable', 'off');
set(handles.disableWebcam, 'Enable', 'on');
guidata(hObject, handles);

% --- Executes on button press in disableWebcam.
function disableWebcam_Callback(hObject, ~, handles)
closePreview(handles.cam);
delete(handles.cam);
handles.cam = 'null';
axes(handles.camera);
logo = imread('.\assets\Images\offcam.jpg');
imshow(logo)
set(handles.enableWebcam, 'Enable', 'on');
set(handles.disableWebcam, 'Enable', 'off');
guidata(hObject, handles);



