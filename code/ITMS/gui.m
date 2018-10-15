function varargout = gui(varargin)
%
% ITMS (Information Theoretic Mean Shift) demo
%
%   Use the sliders to change the kernel size and the lambda value. You can
%   open a different dataset or restart the simulation.
%
% If you have any question, please send me an email (allan@dee.ufrn.br)



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)



% 
% mex('itms_c.c');
% mex('itms_forces_c.c');

set(hObject,'toolBar','none','doublebuffer','on');


T = load('data8.mat');
Xo=T.Xo;
Xinit=[randn(200,2)/160; [randn(200,1)/160-0.5 randn(200,1)/160-2.5]];
Xinit = Xo;
handles.Xo = Xo;
handles.Xinit = Xinit;



initial_plots(handles, Xinit, Xo, zeros(size(Xo)));


%% guide stuff

handles.continue_running=1;
handles.restart = 1;
handles.newDataSet = '';

% store initial handles with variable s(X, Xo, etc...)
handles.output = hObject;
guidata(hObject, handles);

while (handles.continue_running==1)
    handles = guidata(hObject);

    if (handles.restart==1)
        Xinit = Xo;
        handles.restart = 0;

        % store initial handles with variable s(X, Xo, etc...)
        handles.output = hObject;
        guidata(hObject, handles);    
    end
    
    if (length(handles.newDataSet)>1)
        
        T = load(handles.newDataSet);
        
        Xo = T.Xo;
        Xinit = Xo;

        handles.newDataSet = '';
        
        initial_plots(handles, Xo, Xinit, zeros(size(Xo)));
        
        % save handles
        handles.output = hObject;
        guidata(hObject, handles);        
    end
    
    
    % inputs (from sliders)   
    s2 = get(handles.slider1,'Value');
    lambda = get(handles.slider2,'Value');

    Forces = 5*itms_forces_c(Xinit, Xo, s2, lambda);

    Xinit = itms_c(Xinit, Xo, s2, lambda, 1);
    %Xinit = Xinit + 20*Forces;


    % data plots
    Ps = get(handles.axes1,'children');
    set(Ps(2),'XData',Xinit(:,1),'YData',Xinit(:,2));
    set(Ps(1),'XData',Xinit(:,1),'YData',Xinit(:,2),'UData',Forces(:,1),'VData',Forces(:,2));

    drawnow();

    
    % controls

    set(handles.text3,'string',['s2 = ' sprintf('%.4f',s2)]);
    set(handles.text4,'string',['lambda = ' sprintf('%.4f',lambda)]);

end

delete(hObject);



function initial_plots(handles, Xo, Xinit, Forces)
    %% initial plots

    % data plot
    axes(handles.axes1);
    cla();
    hold('on');
    plot(Xo(:,1),Xo(:,2),'linestyle','none','markersize',10,'marker','x','color',[1 0 0]);
    plot(Xinit(:,1),Xinit(:,2),'linestyle','none','markersize',10,'marker','.');
    quiver(Xinit(:,1),Xinit(:,2),Forces(:,1),Forces(:,2));
    grid('on');
    legend({'data','info force'});
    axis('manual');
    axis([-0.1 1.1 -0.1 1.1]);




% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 0;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName,FilterIndex] = uigetfile('*.mat');

if (length(FileName)>1)
    handles.newDataSet = [PathName FileName];
end

% save handles
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.restart = 1;

% save handles
handles.output = hObject;
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

handles.continue_running = 0;

% save handles
handles.output = hObject;
guidata(hObject, handles);
