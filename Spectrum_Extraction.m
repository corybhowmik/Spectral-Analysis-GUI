%% SPECTRUM_EXTRACTION
%
% varargout = Spectrum_Extration() 
%
% GUI for a more interactive spectral analysis of EEG data
%
%   TO USE: To help with code readability press ctrl and + simultaneously to
%           minimize all functions
%
% Written by Taylor Baum for NSRL at MIT (tbaum@mit.edu) - Last Updated 7/27/2017

function varargout = Spectrum_Extraction(varargin)
% Last Modified by GUIDE v2.5 18-Jul-2017 22:11:42

% Begin initialization code - DO NOT EDIT --------------------------------------------------------------------------------------------------------------------------------
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Spectrum_Extraction_OpeningFcn, ...
                   'gui_OutputFcn',  @Spectrum_Extraction_OutputFcn, ...
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

function Spectrum_Extraction_OpeningFcn(hObject, eventdata, handles, varargin) 
% Choose default command line output for Spectrum_Extraction
handles.output = hObject;

% initialize the check boxes to 0
handles.multi = 0;
handles.findPeaks = 0;
handles.typeRange = 0;

guidata(hObject, handles);

function varargout = Spectrum_Extraction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% TYPE-EDIT FIELD FUNCTIONS BY BAUM 2017 **********************************************************************************************************************

function timeSeriesLength_Callback(hObject, eventdata, handles)

handles.length = str2double(get(handles.timeSeriesLength, 'String'));
guidata(hObject, handles);

function timeSeriesLength_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.length = 30;
guidata(hObject, handles);

% BUTTON FUNCTIONS BY BAUM 2017 **********************************************************************************************************************

function anotherSpectrum_Callback(hObject, eventdata, handles)
% hObject    handle to anotherSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t1 nextIndex prevIndex

index = findClickPoint();

currentTime = t1(index);
nextIndex = index + 1;
prevIndex = index - 1;

plotSpectrum(handles, index);

plotTimeSeries(handles, currentTime, 0);

function Play_Callback(hObject, eventdata, handles)
% hObject    handle to Play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t1 nextIndex prevIndex

i = findClickPoint();

nextIndex = i + 1;
prevIndex = i - 1;

set(handles.stopButton, 'UserData', 1)

while (get(handles.stopButton, 'UserData') ~= 0)
    
    % total iteration complete
    if i == length(t1)
        set(handles.Play, 'UserData', 0);
    end
    
    currentTime = t1(i); % current time value in seconds
    nextIndex = i + 1; % increment next index
    prevIndex = i + 1; % increment prev index
    
    plotSpectrum(handles, i);
    
    plotTimeSeries(handles, currentTime, 3);
    
    i = i + 1; % increment
    
    get(handles.stopButton, 'UserData')
end

nextIndex = i + 1;

function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.stopButton, 'UserData', 0)
guidata(hObject, handles);

function fileUpload_Callback(hObject, eventdata, handles)
% hObject    handle to fileUpload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select the MATLAB code file');
addpath(PathName)
handles.fileStr = FileName;
set(handles.currentFile, 'String', FileName);
guidata(hObject, handles);
parameterPalette;
color_Callback(hObject, eventdata, handles)
replot(handles)

function next_Callback(hObject, eventdata, handles)

global nextIndex prevIndex t1

currentTime = t1(nextIndex);

plotSpectrum(handles, nextIndex);

plotTimeSeries(handles, currentTime, 1);

nextIndex = nextIndex + 1;
prevIndex = prevIndex + 1;

function previous_Callback(hObject, eventdata, handles)

global prevIndex nextIndex t1

currentTime = t1(prevIndex);

plotSpectrum(handles, prevIndex);

plotTimeSeries(handles, currentTime, 2);

nextIndex = nextIndex - 1;
prevIndex = prevIndex - 1;

function scoringSession_Callback(hObject, eventdata, handles)

global t1

set(handles.sessionState, 'String', 'open');

name = input('Your name: ','s');
fileName = input('Desired file name for .txt file: ', 's');
purpose = input('Summary of purpose for session: ', 's');
date = input('Date (mm/dd/yyyy): ', 's');

f = fopen(fileName,'w');
fprintf(f, 'FILE: %s\nCREATED BY: %s on %s\nPURPOSE: %s\n\n', fileName, name, date, purpose);

stop = 0;

while ~stop
    want = input('----------------------\nTo comment, type C\nTo exit, type E\n----------------------\nINPUT: ', 's');
    if want == 'C'
        timeIndex = findClickPoint;
        time = t1(timeIndex);
        comment = input('Comment: ', 's');
        fprintf(f, 'At %3.3f (min): %s\n', time/60, comment);
    elseif want == 'E'
        stop = 1;
    else
        Message = 'Invalid input!';
        msgbox(Message);
    end
end

fclose(f);
set(handles.sessionState, 'String', 'closed');
Message = 'Scoring session is complete and file is now closed.';
msgbox(Message);

function color_Callback(hObject, eventdata, handles)

colorPalette; % outputs global lowColorBound and global highColorBound

replot(handles)

function parameter_Callback(hObject, eventdata, handles)

parameterPalette; % outputs global paramWinSize paramTW paramWinStep and paramTapers

replot(handles)

function power_Callback(hObject, eventdata, handles)

powerPalette

% PLOTTING FUNCTIONS BY BAUM 2017 **********************************************************************************************************************

function replot(handles)
% plots a spectrogram of the given data with the specified parameters in
% the edit windows of the GUI

global data filteredData channel multi dataName paramWinSize paramWinStep paramTW paramTapers S1 f1 t1 Fs lowColorBound highColorBound

handles.dataName = dataName;

[D] = importdata(handles.fileStr);

if ~multi
    data = D.(handles.dataName);
    data = data.';
else
    data = D.(handles.dataName)(channel,1:length(D.(handles.dataName)));
end

bandpassFrequencies = [0, 40];
filteredData = quickbandpass(data, Fs, bandpassFrequencies);

% set initial parameters
movingwin = [paramWinSize paramWinStep];
params.tapers = [paramTW paramTapers];
params.Fs = Fs;
[S1, t1, f1] = mtspecgramc(filteredData, movingwin, params);

% plot spectrogram
axes(handles.spectrogram);
plot_matrix(S1, t1, f1);
xlabel([]);
caxis([lowColorBound highColorBound]);
% sec2hms
ylim([0,40])
xlabel('Time (sec)');
map = jet;
colormap(map)
ylabel('Frequency (dB Hz)')
scrollzoompan;

function plotSpectrum(handles, i)

global S1 f1 t1

currentTime = t1(i);

axes(handles.axes2);
powerArray = S1(i, 1:end); % obtain spectrogram
plot(f1, 10*log10(powerArray)); % plot spectrum
xlim([0,40])
ylim([-20, 60])
spectrumTitle = sprintf('Spectrum at %.3f minute(s)|%.3f second(s)', currentTime/60, currentTime);
title(spectrumTitle)
xlabel('Frequency (Hz)')
ylabel('Power in dB Scale')

if handles.findPeaks
    [peakLoc, peakMag] = peakfinder(10*log10(powerArray), 5, 0);

    hold on
    plot(f1(peakLoc), peakMag, 'ro')
    hold off
end

function plotTimeSeries(handles, currentTime, oneSpectrum)

global Fs filteredData t1 paramWinStep

axes(handles.axes5);
switch oneSpectrum
    case 0
        dataSnip = extractdatac(filteredData, Fs, [currentTime (currentTime + handles.length)]);
        tSnip = 1:1:length(dataSnip);
        plot(tSnip, dataSnip,'b-')
        xlabel('Time (min)')
        ylabel('Voltage (mV)')
        set(gca, 'XTick', 0:5*(250):length(tSnip));          
        set(gca, 'XTickLabel', 0:5:t1(end)); 
        timeSeriesTitle = sprintf('%d Second Time Series Starting at %.3f minute(s)|%.3f second(s)', handles.length, currentTime/60, currentTime);
        title(timeSeriesTitle)
    case 1
        for i = currentTime - paramWinStep:currentTime
            dataSnip = extractdatac(filteredData, Fs, [i (i + handles.length)]);
            tSnip = 1:1:length(dataSnip);

            plot(tSnip, dataSnip,'b-')
            xlabel('Time (min)')
            ylabel('Voltage (mV)')
            set(gca, 'XTick', 0:5*(250):length(tSnip));          
            set(gca, 'XTickLabel', 0:5:t1(end)); 
            timeSeriesTitle = sprintf('%d Second Time Series Starting at %.3f minute(s)|%.3f second(s)', handles.length, i/60, i);
            title(timeSeriesTitle)

            if i ~= currentTime + 4
                pause(.05)
            end
        end
    case 2
        for i = currentTime:-1:currentTime - paramWinStep
            dataSnip = extractdatac(filteredData, Fs, [i (i + handles.length)]);
            tSnip = 1:1:length(dataSnip);

            plot(tSnip, dataSnip,'b-')
            xlabel('Time (min)')
            ylabel('Voltage (mV)')
            set(gca, 'XTick', 0:5*(250):length(tSnip));          
            set(gca, 'XTickLabel', 0:5:t1(end)); 
            timeSeriesTitle = sprintf('%d Second Time Series Starting at %.3f minute(s)|%.3f second(s)', handles.length, i/60, i);
            title(timeSeriesTitle)

            if i ~= currentTime + 4
                pause(.05)
            end
        end
    case 3
        for i = currentTime:currentTime + paramWinStep
            dataSnip = extractdatac(filteredData, Fs, [i (i + handles.length)]);
            tSnip = 1:1:length(dataSnip);

            plot(tSnip, dataSnip,'b-')
            xlabel('Time (min)')
            ylabel('Voltage (mV)')
            set(gca, 'XTick', 0:5*(250):length(tSnip));          
            set(gca, 'XTickLabel', 0:5:t1(end)); 
            timeSeriesTitle = sprintf('%d Second Time Series Starting at %.3f minute(s)|%.3f second(s)', handles.length, i/60, i);
            title(timeSeriesTitle)

            if i ~= currentTime + 4
                pause(.05)
            end
        end
end

% CHECK BOX FUNCTIONS BY BAUM 2017 **********************************************************************************************************************

function findPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to findPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of findPeaks

handles.findPeaks = get(hObject,'Value');
guidata(hObject, handles);

% FIND CLICK POINT FUNCTIONS BY BAUM 2017 **********************************************************************************************************************

function timeIndex = findClickPoint()

global t1

% Plot a spectrum at desired time from click input
[desiredTime, desiredFrequency] = ginput(1);
actualTime = floor(desiredTime);
timeError = (t1(2) - t1(1))/2;
gotIt = false;

% transfer click point to actual S1 matrix
for i = 1:length(t1)
    currentTime = floor(t1(i));
    if currentTime == actualTime
        index = i;
        gotIt = true;
    end    
end

% approximated click point if the value doesn't exactly match the stored S1
if ~gotIt
    for i = 1:length(t1)
        currentTime = floor(t1(i));
        if ((floor((currentTime) + timeError)) >= actualTime) && ((floor((currentTime) - timeError)) <= actualTime)
            index = i;
        end    
   end
end

timeIndex = index;

function freqIndex = findClickPointFreq()

global t1 f1

% Plot a spectrum at desired time from click input
[desiredTime, desiredFrequency] = ginput(1);
actualFreq = floor(desiredFrequency);
freqError = (f1(2) - f1(1))/2;
gotIt = false;

% transfer click point to actual S1 matrix
for i = 1:length(f1)
    currentFreq = floor(f1(i));
    if currentFreq == actualFreq
        index = i;
        gotIt = true;
    end    
end

% approximated click point if the value doesn't exactly match the stored S1
if ~gotIt
    for i = 1:length(f1)
        currentFreq = floor(f1(i));
        if ((floor((currentFreq) + freqError)) >= actualFreq) && ((floor((currentFreq) - freqError)) <= actualFreq)
            index = i;
        end    
   end
end

freqIndex = index;

% SPECTROGRAM SLIDER FUNCTIONS BY PRERAU 2017 **********************************************************************************************************************

function [zslider, pslider, zl, pl] = scrollzoompan(ax,dir,zoom_fcn,pan_fcn, bounds)
%SCROLLZOOMPAN  Adds pan and zoom scroll bars to an axis
%               mouse wheel = pan, shift + mouse wheel = zoom
%
%   Usage:
%   [zslider, pslider]=scrollzoompan
%   [zslider, pslider]=scrollzoompan(ax)
%   [zslider, pslider]=scrollzoompan(ax, dir)
%   [zslider, pslider]=scrollzoompan(ax, dir, zoom_fcn, pan_fcn)
%
%   Input:
%   ax: Axis to zoom and pan (default: gca)
%   dir: Zoom/pan direction {'x','y'} (default: 'x')
%   zslider/pslider: Handles to slider object handles (default: creates at figure bottom)
%   zoom_fcn/pan_fcn: Handles to functions to be called on zoom or pan
%
%   Output:
%   zslider: Zoom slider handle
%   pslider: Pan slider handle
%
%   Example:
%
%     figure
%     axes('position',[.05 .15 .9 .8]);
%     plot(randn(1,1000));
%     scrollzoompan;
%
%     figure
%     axes('position',[.05 .15 .9 .8]);
%     imagesc(peaks(1000));
%     scrollzoompan(gca,'y');
%
%   Copyright 2015 Michael J. Prerau, Ph.D.
%
%   Last modified 03/17/2015
%********************************************************************

% annotation(gcf,'textbox',...
%     [0.0286396181384249 0.054140127388535 0.019689737470167 0.023416135881104],...
%     'String',{'Pan'},...
%     'FitBoxToText','off',...
%     'LineStyle','none');

% % Create textbox
% annotation(gcf,'textbox',...
%     [0.0238663484486874 0.0265392781316348 0.0238663484486873 0.023416135881104],...
%     'String',{'Zoom'},...
%     'FitBoxToText','off',...
%     'LineStyle','none');

%Set default axes to current
if nargin==0
    ax=gca;
end

%Set default direction to x
if nargin<2
    dir=lower('x');
end

if nargin<3
    zoom_fcn=[];
end

if nargin<4
    pan_fcn=[];
end



%Get full data limits depending on direction
if strcmpi(dir,'x')
    xl=xlim(ax(1));   

    amin=xl(1);
    amax=xl(2);
else
    yl=xlim(ax(1));
    
    amin=yl(1);
    amax=yl(2);
end

%Impose bounds if defined
if nargin<5
    bounds=[nan nan];
end

if ~isnan(bounds(1))
    amin=bounds(1);
end

if ~isnan(bounds(2))
    amax=bounds(2);
end

handle=guidata(gcf);
handle.shift_down=false;
guidata(gcf,handle);

%Create zoom slider
zslider = uicontrol('style','slider','units','normalized','position',[.05 .025 .9 .025],'slider',[1 5]/amax,'min',amin,'max',amax,'value',amax);
pslider = uicontrol('style','slider','units','normalized','position',[.05 .055 .9 .025],'slider',[1 5]/amax,'min',amin,'max',amax,'value',amax/2,'sliderstep',(amax-amin)/amax*[.5 1]);

%Add listeners for continuous value changes
zl=addlistener(zslider,'ContinuousValueChange',@(src,evnt)zoom_slider(ax, zslider, pslider, dir,zoom_fcn));
pl=addlistener(pslider,'ContinuousValueChange',@(src,evnt)pan_slider(ax, pslider, dir,pan_fcn));
set(gcf,'WindowKeyPressFcn',{@handle_keys,ax, zslider, pslider, dir, zoom_fcn, pan_fcn},'WindowKeyReleaseFcn',@key_off);

set(gcf,'WindowScrollWheelFcn',{@figScroll,ax, zslider, pslider, dir, zoom_fcn, pan_fcn});

function zoom_slider(ax, zslider, pslider, dir, zoom_fcn)
%Keep the window center with window width determined by slider value
newlims=get(pslider,'value')+get(zslider,'value')/2*[-1 1];

amin=get(zslider,'min');
amax=get(zslider,'max');

%Sets a minimum window width
if newlims(2)<=newlims(1)
    newlims(2)=newlims(1)+1e-10;
end

%Set sliderbounds so that you can't go past limits
if get(pslider,'value')-abs(diff(xlim(ax(1))))/2<amin
    newpos=amin+abs(diff(xlim(ax(1))))/2;
    set(pslider,'value', newpos);
    newlims(1)=amin;
elseif get(pslider,'value')+abs(diff(xlim(ax(1))))/2>amax
    newpos=amax-abs(diff(xlim(ax(1))))/2;
    set(pslider,'value', newpos);
    newlims(2)=amax;
end

%Compute the new limits
if strcmpi(dir,'x')
    set(ax,'xlim',newlims);
    set(pslider,'sliderstep',diff(xlim(ax(1)))/amax*[.5 1]);
else
    set(ax,'ylim',newlims);
    set(pslider,'sliderstep',diff(xlim(ax(1)))/amax*[.5 1]);
end

if ~isempty(zoom_fcn)
    feval(zoom_fcn);
end

function pan_slider(ax, pslider, dir, pan_fcn)
amin=get(pslider,'min');
amax=get(pslider,'max');

%Set the limits to the slider value center
if strcmpi(dir,'x')
    %Set sliderbounds so that you can't go past limits
    if get(pslider,'value')-abs(diff(xlim(ax(1))))/2<amin
        set(pslider,'value',amin+abs(diff(xlim(ax(1))))/2);
    elseif get(pslider,'value')+abs(diff(xlim(ax(1))))/2>amax
        set(pslider,'value',amax-abs(diff(xlim(ax(1))))/2);
    end
    
    set(ax, 'xlim', get(pslider,'value')+[-1 1]*abs(diff(xlim(ax(1))))/2);
else
    %Set sliderbounds so that you can't go past limits
    if get(pslider,'value')-abs(diff(xlim(ax(1))))/2<amin
        set(pslider,'value',amin+abs(diff(xlim(ax(1))))/2);
    elseif get(pslider,'value')+abs(diff(xlim(ax(1))))/2>amax
        set(pslider,'value',amax-abs(diff(xlim(ax(1))))/2);
    end
    set(ax, 'ylim', get(pslider,'value')+[-1 1]*abs(diff(xlim(ax(1))))/2);
end

if ~isempty(pan_fcn)
    feval(pan_fcn);
end

function figScroll(~,callbackdata,ax, zslider, pslider, dir, zoom_fcn, pan_fcn)
handle=guidata(gcf);

%Scroll if shift not pressed
if ~(handle.shift_down)
    amin=get(pslider,'min');
    amax=get(pslider,'max');
    if callbackdata.VerticalScrollCount > 0
        set(pslider,'value',min(get(pslider,'value')*(1+.025*callbackdata.VerticalScrollAmount),amax));
        pan_slider(ax, pslider, dir, pan_fcn);
    elseif callbackdata.VerticalScrollCount < 0
        set(pslider,'value',max(get(pslider,'value')*(1-.025*callbackdata.VerticalScrollAmount),amin));
        pan_slider(ax, pslider, dir, pan_fcn)
    end
%Zoom if shift is pressed
else
    amin=get(zslider,'min');
    amax=get(zslider,'max');
    if callbackdata.VerticalScrollCount > 0
        set(zslider,'value',max(get(zslider,'value')*(1-.025*callbackdata.VerticalScrollAmount),amin));
        zoom_slider(ax, zslider, pslider, dir, zoom_fcn);
    elseif callbackdata.VerticalScrollCount < 0
        set(zslider,'value',min(get(zslider,'value')*(1+.025*callbackdata.VerticalScrollAmount),amax));
        zoom_slider(ax, zslider, pslider, dir, zoom_fcn);
    end
end

function handle_keys(~,event,ax, zslider, pslider, dir, zoom_fcn, pan_fcn)
handle=guidata(gcf);

%Check if shift is bing pressed
handle.shift_down=(strcmpi(event.Key,'shift'));

switch event.Key
    %Scroll left
    case 'rightarrow'
        amax=get(pslider,'max');
        set(pslider,'value',min(get(pslider,'value')*(1+.025),amax));
        pan_slider(ax, pslider, dir, pan_fcn);
    %Scroll right    
    case 'leftarrow'
        amin=get(pslider,'min');
        set(pslider,'value',max(get(pslider,'value')*(1-.025),amin));
        pan_slider(ax, pslider, dir, pan_fcn)
    %Zoom in  
    case 'downarrow'
        amin=get(zslider,'min');
        set(zslider,'value',max(get(zslider,'value')*(1-.025),amin));
        zoom_slider(ax, zslider, pslider, dir, zoom_fcn);
    %Zoom out
    case 'uparrow'
        amax=get(zslider,'max');
        set(zslider,'value',min(get(zslider,'value')*(1+.025),amax));
        zoom_slider(ax, zslider, pslider, dir, zoom_fcn);
end

guidata(gcf,handle);

function key_off(~,~)
handle=guidata(gcf);
handle.shift_down=false;
guidata(gcf,handle);

% PEAKFINDER BY YODER 2015 **********************************************************************************************************************

function varargout = peakfinder(x0, sel, thresh, extrema, includeEndpoints, interpolate)
%PEAKFINDER Noise tolerant fast peak finding algorithm
%   INPUTS:
%       x0 - A real vector from the maxima will be found (required)
%       sel - The amount above surrounding data for a peak to be,
%           identified (default = (max(x0)-min(x0))/4). Larger values mean
%           the algorithm is more selective in finding peaks.
%       thresh - A threshold value which peaks must be larger than to be
%           maxima or smaller than to be minima.
%       extrema - 1 if maxima are desired, -1 if minima are desired
%           (default = maxima, 1)
%       includeEndpoints - If true the endpoints will be included as
%           possible extrema otherwise they will not be included
%           (default = true)
%       interpolate - If true quadratic interpolation will be performed
%           around each extrema to estimate the magnitude and the
%           position of the peak in terms of fractional indicies. Note that
%           unlike the rest of this function interpolation assumes the
%           input is equally spaced. To recover the x_values of the input
%           rather than the fractional indicies you can do:
%           peakX = x0 + (peakLoc - 1) * dx
%           where x0 is the first x value and dx is the spacing of the
%           vector. Output peakMag to recover interpolated magnitudes.
%           See example 2 for more information.
%           (default = false)
%
%   OUTPUTS:
%       peakLoc - The indicies of the identified peaks in x0
%       peakMag - The magnitude of the identified peaks
%
%   [peakLoc] = peakfinder(x0) returns the indicies of local maxima that
%       are at least 1/4 the range of the data above surrounding data.
%
%   [peakLoc] = peakfinder(x0,sel) returns the indicies of local maxima
%       that are at least sel above surrounding data.
%
%   [peakLoc] = peakfinder(x0,sel,thresh) returns the indicies of local
%       maxima that are at least sel above surrounding data and larger
%       (smaller) than thresh if you are finding maxima (minima).
%
%   [peakLoc] = peakfinder(x0,sel,thresh,extrema) returns the maxima of the
%       data if extrema > 0 and the minima of the data if extrema < 0
%
%   [peakLoc] = peakfinder(x0,sel,thresh,extrema, includeEndpoints)
%       returns the endpoints as possible extrema if includeEndpoints is
%       considered true in a boolean sense
%
%   [peakLoc, peakMag] = peakfinder(x0,sel,thresh,extrema,interpolate)
%       returns the results of results of quadratic interpolate around each
%       extrema if interpolate is considered to be true in a boolean sense
%
%   [peakLoc, peakMag] = peakfinder(x0,...) returns the indicies of the
%       local maxima as well as the magnitudes of those maxima
%
%   If called with no output the identified maxima will be plotted along
%       with the input data.
%
%   Note: If repeated values are found the first is identified as the peak
%
% Example 1:
% t = 0:.0001:10;
% x = 12*sin(10*2*pi*t)-3*sin(.1*2*pi*t)+randn(1,numel(t));
% x(1250:1255) = max(x);
% peakfinder(x)
%
% Example 2:
% ds = 100;  % Downsample factor
% dt = .001; % Time step
% ds_dt = ds*dt; % Time delta after downsampling
% t0 = 1;
% t = t0:dt:5 + t0;
% x = 0.2-sin(0.01*2*pi*t)+3*cos(7/13*2*pi*t+.1)-2*cos((1+pi/10)*2*pi*t+0.2)-0.2*t;
% x(end) = min(x);
% x_ds = x(1:ds:end); % Downsample to test interpolation
% [minLoc, minMag] = peakfinder(x_ds, .8, 0, -1, false, true);
% minT = t0 + (minLoc - 1) * ds_dt; % Take into account 1 based indexing
% p = plot(t,x,'-',t(1:ds:end),x_ds,'o',minT,minMag,'rv');
% set(p(2:end), 'linewidth', 2); % Show the markers more clearly
% legend('Actual Data', 'Input Data', 'Estimated Peaks');
% Copyright Nathanael C. Yoder 2015 (nyoder@gmail.com)

% Perform error checking and set defaults if not passed in
narginchk(1, 6);
nargoutchk(0, 2);

s = size(x0);
flipData =  s(1) < s(2);
len0 = numel(x0);
if len0 ~= s(1) && len0 ~= s(2)
    error('PEAKFINDER:Input','The input data must be a vector')
elseif isempty(x0)
    varargout = {[],[]};
    return;
end
if ~isreal(x0)
    warning('PEAKFINDER:NotReal','Absolute value of data will be used')
    x0 = abs(x0);
end

if nargin < 2 || isempty(sel)
    sel = (max(x0)-min(x0))/4;
elseif ~isnumeric(sel) || ~isreal(sel)
    sel = (max(x0)-min(x0))/4;
    warning('PEAKFINDER:InvalidSel',...
        'The selectivity must be a real scalar.  A selectivity of %.4g will be used',sel)
elseif numel(sel) > 1
    warning('PEAKFINDER:InvalidSel',...
        'The selectivity must be a scalar.  The first selectivity value in the vector will be used.')
    sel = sel(1);
end

if nargin < 3 || isempty(thresh)
    thresh = [];
elseif ~isnumeric(thresh) || ~isreal(thresh)
    thresh = [];
    warning('PEAKFINDER:InvalidThreshold',...
        'The threshold must be a real scalar. No threshold will be used.')
elseif numel(thresh) > 1
    thresh = thresh(1);
    warning('PEAKFINDER:InvalidThreshold',...
        'The threshold must be a scalar.  The first threshold value in the vector will be used.')
end

if nargin < 4 || isempty(extrema)
    extrema = 1;
else
    extrema = sign(extrema(1)); % Should only be 1 or -1 but make sure
    if extrema == 0
        error('PEAKFINDER:ZeroMaxima','Either 1 (for maxima) or -1 (for minima) must be input for extrema');
    end
end

if nargin < 5 || isempty(includeEndpoints)
    includeEndpoints = true;
end

if nargin < 6 || isempty(interpolate)
    interpolate = false;
end

x0 = extrema*x0(:); % Make it so we are finding maxima regardless
thresh = thresh*extrema; % Adjust threshold according to extrema.
dx0 = diff(x0); % Find derivative
dx0(dx0 == 0) = -eps; % This is so we find the first of repeated values
ind = find(dx0(1:end-1).*dx0(2:end) < 0)+1; % Find where the derivative changes sign

% Include endpoints in potential peaks and valleys as desired
if includeEndpoints
    x = [x0(1);x0(ind);x0(end)];
    ind = [1;ind;len0];
    minMag = min(x);
    leftMin = minMag;
else
    x = x0(ind);
    minMag = min(x);
    leftMin = min(x(1), x0(1));
end

% x only has the peaks, valleys, and possibly endpoints
len = numel(x);

if len > 2 % Function with peaks and valleys
    % Set initial parameters for loop
    tempMag = minMag;
    foundPeak = false;

    if includeEndpoints
        % Deal with first point a little differently since tacked it on
        % Calculate the sign of the derivative since we tacked the first
        %  point on it does not neccessarily alternate like the rest.
        signDx = sign(diff(x(1:3)));
        if signDx(1) <= 0 % The first point is larger or equal to the second
            if signDx(1) == signDx(2) % Want alternating signs
                x(2) = [];
                ind(2) = [];
                len = len-1;
            end
        else % First point is smaller than the second
            if signDx(1) == signDx(2) % Want alternating signs
                x(1) = [];
                ind(1) = [];
                len = len-1;
            end
        end
    end

    % Skip the first point if it is smaller so we always start on a
    %   maxima
    if x(1) >= x(2)
        ii = 0;
    else
        ii = 1;
    end

    % Preallocate max number of maxima
    maxPeaks = ceil(len/2);
    peakLoc = zeros(maxPeaks,1);
    peakMag = zeros(maxPeaks,1);
    cInd = 1;
    % Loop through extrema which should be peaks and then valleys
    while ii < len
        ii = ii+1; % This is a peak
        % Reset peak finding if we had a peak and the next peak is bigger
        %   than the last or the left min was small enough to reset.
        if foundPeak
            tempMag = minMag;
            foundPeak = false;
        end

        % Found new peak that was lager than temp mag and selectivity larger
        %   than the minimum to its left.
        if x(ii) > tempMag && x(ii) > leftMin + sel
            tempLoc = ii;
            tempMag = x(ii);
        end

        % Make sure we don't iterate past the length of our vector
        if ii == len
            break; % We assign the last point differently out of the loop
        end

        ii = ii+1; % Move onto the valley
        % Come down at least sel from peak
        if ~foundPeak && tempMag > sel + x(ii)
            foundPeak = true; % We have found a peak
            leftMin = x(ii);
            peakLoc(cInd) = tempLoc; % Add peak to index
            peakMag(cInd) = tempMag;
            cInd = cInd+1;
        elseif x(ii) < leftMin % New left minima
            leftMin = x(ii);
        end
    end

    % Check end point
    if includeEndpoints
        if x(end) > tempMag && x(end) > leftMin + sel
            peakLoc(cInd) = len;
            peakMag(cInd) = x(end);
            cInd = cInd + 1;
        elseif ~foundPeak && tempMag > minMag % Check if we still need to add the last point
            peakLoc(cInd) = tempLoc;
            peakMag(cInd) = tempMag;
            cInd = cInd + 1;
        end
    elseif ~foundPeak
        if x(end) > tempMag && x(end) > leftMin + sel
            peakLoc(cInd) = len;
            peakMag(cInd) = x(end);
            cInd = cInd + 1;
        elseif tempMag > min(x0(end), x(end)) + sel
            peakLoc(cInd) = tempLoc;
            peakMag(cInd) = tempMag;
            cInd = cInd + 1;
        end
    end

    % Create output
    if cInd > 1
        peakInds = ind(peakLoc(1:cInd-1));
        peakMags = peakMag(1:cInd-1);
    else
        peakInds = [];
        peakMags = [];
    end
else % This is a monotone function where an endpoint is the only peak
    [peakMags,xInd] = max(x);
    if includeEndpoints && peakMags > minMag + sel
        peakInds = ind(xInd);
    else
        peakMags = [];
        peakInds = [];
    end
end

% Apply threshold value.  Since always finding maxima it will always be
%   larger than the thresh.
if ~isempty(thresh)
    m = peakMags>thresh;
    peakInds = peakInds(m);
    peakMags = peakMags(m);
end

if interpolate && ~isempty(peakMags)
    middleMask = (peakInds > 1) & (peakInds < len0);
    noEnds = peakInds(middleMask);

    magDiff = x0(noEnds + 1) - x0(noEnds - 1);
    magSum = x0(noEnds - 1) + x0(noEnds + 1)  - 2 * x0(noEnds);
    magRatio = magDiff ./ magSum;

    peakInds(middleMask) = peakInds(middleMask) - magRatio/2;
    peakMags(middleMask) = peakMags(middleMask) - magRatio .* magDiff/8;
end

% Rotate data if needed
if flipData
    peakMags = peakMags.';
    peakInds = peakInds.';
end

% Change sign of data if was finding minima
if extrema < 0
    peakMags = -peakMags;
    x0 = -x0;
end

% Plot if no output desired
if nargout == 0
    if isempty(peakInds)
        disp('No significant peaks found')
    else
        figure;
        plot(1:len0,x0,'.-',peakInds,peakMags,'ro','linewidth',2);
    end
else
    varargout = {peakInds,peakMags};
end

% QUICKBANDPASS BY PRERAU 2011 **********************************************************************************************************************

function [filtdata tail] = quickbandpass(data, Fs, bandpass_frequencies, bandwidth)
%A quick bandpass returns a the data filtered at a given frequency center or
%band using an equiripple bandpass filter
%
% filtdata = quickbandpass(data, Fs, freq_band)
% filtdata = quickbandpass(data, Fs, freq_center)
% filtdata = quickbandpass(data, Fs, freq_center, bandwidth)

%If only a frequency center is selected
if length(bandpass_frequencies)==1
    %Default bandwidth is 1Hz
    if nargin<4
        bandwidth=1;
    end
    
    %Specify frequency parameters
    Fpass1 = max(bandpass_frequencies-(bandwidth/2),.01);    % First Passband Frequency
    Fstop1 = max(Fpass1-.01,.01);                             % First Stopband Frequency
    
    Fpass2 = bandpass_frequencies+(bandwidth/2);    % Second Passband Frequency
    Fstop2 = Fpass2+.01;                             % Second Stopband Frequency
%If a band is selected
else
    Fpass1 = max(bandpass_frequencies(1),.01);   % First Passband Frequency
    Fstop1 = max(Fpass1-.01,.01);                 % First Stopband Frequency
    
    Fpass2 = bandpass_frequencies(2);   % Second Passband Frequency
    Fstop2 = Fpass2+.01;                 % Second Stopband Frequency
end



% Dstop1 = 0.001;           % First Stopband Attenuation
% Dpass  = 0.057501127785;  % Passband Ripple
% Dstop2 = 0.001;           % Second Stopband Attenuation
% dens   = 20;              % Density Factor

% % Calculate the order from the parameters using FIRPMORD.
% [N, Fo, Ao, W] = firpmord(max([Fstop1 Fpass1 Fpass2 Fstop2],1e-4)/(Fs/2), [0 1 ...
%     0], [Dstop1 Dpass Dstop2]);
% 
% % Calculate the coefficients using the FIRPM function.
% b  = firpm(N, Fo, Ao, W, {dens});
% Hd = dfilt.dffir(b);

N      = 2000;   % Order

Wstop1 = 1;      % First Stopband Weight
Wpass  = 1;      % Passband Weight
Wstop2 = 1;      % Second Stopband Weight

% Calculate the coefficients using the FIRLS function.
b  = firls(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 Fs/2]/(Fs/2), [0 0 1 1 0 ...
           0], [Wstop1 Wpass Wstop2]);
Hd = dfilt.dffir(b);
delay=ceil(N/2);

%Filter the data and return result
filtfull=filter(Hd,[data(1)*ones(1,N) data]);
filtdata=[filtfull((delay+N+1):end) zeros(1,ceil(N/2))];
tail=ceil(N/2);