function CMERG_TST_Data_PreProcessing_Tool
clc;
clear;
close all;

set(0,'DefaultFigureWindowStyle','normal');

f = figure('visible','off','unit','pixels','position',[0 0 1100 550]);

%%%%%%%%%%%%%%%%%% Initialise controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hMotorPath = uicontrol('Style','edit','String','Input Motor data FilePath.','Position',[30,500,550,25],'Callback',{@MotorPath_Callback});
hRotorPath = uicontrol('Style','edit','String','Input Rotor data FilePath.','Position',[30,470,550,25],'Callback',{@RotorPath_Callback});  
hbrowseMotorPath = uicontrol('Style','pushbutton','String','browse','Position',[600,500,100,25],'Callback',{@browseMotorPath_Callback});
hbrowseRotorPath = uicontrol('Style','pushbutton','String','browse','Position',[600,470,100,25],'Callback',{@browseRotorPath_Callback});
hLoadMotorData = uicontrol('Style','togglebutton','String','Load','Position',[720,500,70,25],'Callback',{@LoadMotorData_Callback});
hLoadRotorData = uicontrol('Style','togglebutton','String','Load','Position',[720,470,70,25],'Callback',{@LoadRotorData_Callback});

hPicRot = uicontrol('Style','edit','String','1','Position',[1040,500,30,25],'Callback',{@PicRot_Callback});
hLoadRot = uicontrol('Style','togglebutton','String','Load','Position',[1020,470,70,25],'Callback',{@LoadRot_Callback});
hRotLabel = uicontrol('Style','text','String','Which Rotation would you like to plot?','position',[800,495,190,25]);

hNextRot = uicontrol('Style','pushbutton','String','>> Next Roation','Position',[900,470,100,25],'Callback',{@NextRot_Callback});
hPrevRot = uicontrol('Style','pushbutton','String','Prev. Roation <<','Position',[800,470,100,25],'Callback',{@PrevRot_Callback});
hSave = uicontrol('Style','pushbutton','String','Save Results','Position',[980,430,100,25],'Callback',{@Save_Callback});

%%%%%%%%%%%%%%% Initialise Plot Objects %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ha_angle = axes('Units','pixels','position',[70,280,500,160]);
ha_angle.YLim=[0 360];
ha_angle.YTick=[0 30 60 90 120 150 180 210 240 270 300 330 360];
ha_angle.XLabel.String='time(s)';ha_angle.YLabel.String='Angle (Deg)';ha_angle.Title.String='Angle vs Time';%lables axes

ha_torque = axes('Units','pixels','position',[70,50,500,160]);
ha_torque.XLabel.String='time(s)';ha_torque.YLabel.String='Torque (Nm)';ha_torque.Title.String='Torque vs Time';%lables axes

ha_angle_torque = axes('Units','pixels','position',[660,50,360,360]);
ha_angle_torque.XLim=[0 360];
ha_angle_torque.XTick=[0 30 60 90 120 150 180 210 240 270 300 330 360];
ha_angle_torque.XLabel.String='Angle (Deg)';ha_angle_torque.YLabel.String='Torque (Nm)';ha_angle_torque.Title.String='Torque vs Angle';%lables axes


%%%%%%%%%%%%%%%%%%%%%%%%% Normalise objects %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hMotorPath.Units = 'normalized';
hRotorPath.Units = 'normalized';
hbrowseMotorPath.Units = 'normalized';
hbrowseRotorPath.Units = 'normalized';
hLoadMotorData.Units = 'normalized';
hLoadRotorData.Units = 'normalized';
hPicRot.Units = 'normalized';
hLoadRot.Units = 'normalized';
ha_angle.Units = 'normalized';
ha_torque.Units = 'normalized';
ha_angle_torque.Units = 'normalized';
hRotLabel.Units = 'normalized';
hNextRot.Units= 'normalized';
hPrevRot.Units= 'normalized';
hSave.Units= 'normalized';

f.Name = 'CMERG TST Data Pre-Processing Tool';% Assigns a name to appear in the window title.
f.NumberTitle = 'off'; %takes the figure number out of the figure title
movegui(f,'center'); % Moves the window to the center of the screen.
f.Visible = 'on'; % Make the UI visible

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialise valiables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
motorFilename = "";
rotorFilename = "";
motorFilePath = "";
rotorFilePath = "";
angleTime =zeros(1,10000);
theta=zeros(1,10000);
Torque=zeros(1,1000000);
Tfilter=zeros(1,1000000);
torqueTime=zeros(1,1000000);
rotNum=[1];
spl=zeros(1,1000);
sph=zeros(1,1000);
%%%%%%%%%%%%%%%%%%%%%%%%%%% Callback functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function MotorPath_Callback(~,~)
motorFilePath = hMotorPath.String;
end

function RotorPath_Callback(~,~)
motorFilePath = hRotorPath.String;
end
    
function browseMotorPath_Callback(~,~)
 [file,path] = uigetfile({'*.txt'},'Select Motor Data File');
motorFilePath = [path,file];
hMotorPath.String = [path,file];
motorFilename = file;
end

function browseRotorPath_Callback(~,~)
 [file,path] = uigetfile({'*.txt'},'Select Rotor Data File');
rotorFilePath = [path,file];
hRotorPath.String = [path,file];
rotorFilename = file;
end

function LoadMotorData_Callback(~,~)
        
      [angleTime, theta] = importAngleData(motorFilePath);
        localMins = islocalmin(theta,'SamplePoints',angleTime);
        localMax = islocalmax(theta,'SamplePoints',angleTime);
        plot(ha_angle,angleTime,theta,'-x',angleTime(localMins),theta(localMins),'r*',angleTime(localMax),theta(localMax),'r*');%plots angle vs time, labels local minimums
        ha_angle.XGrid,'on';
        ha_angle.YGrid,'on';
        ha_angle.YLim=[0 360];
        ha_angle.YTick=[0 30 60 90 120 150 180 210 240 270 300 330 360];
        ha_angle.XLabel.String='time(s)';ha_angle.YLabel.String='Angle';ha_angle.Title.String='Angle vs Time';%lables axes
        
        spl=find(localMins==1);
        sph=find(localMax==1);
end

function LoadRotorData_Callback(~,~)
      [torqueTime,Torque] = importTorqueData(rotorFilePath);
      
        windowSize = 100;
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        Tfilter= filter(b,a,Torque);
      
        plot(ha_torque,torqueTime,Torque,torqueTime,Tfilter);

        ha_torque.YLim=[(min(Torque)) (max(Torque))];
        ha_torque.XGrid,'on';
        ha_torque.YGrid,'on';
        ha_torque.XLabel.String='time(s)';%lables axes
        ha_torque.YLabel.String='Torque (Nm)';%lables axes
        ha_torque.Title.String='Torque vs Time';
end

function PicRot_Callback(~,~)
       rotNum=str2double(hPicRot.String);
end

function NextRot_Callback(~,~)
    plotRotation(rotNum+1);
    rotNum=(rotNum+1);
    hPicRot.String=rotNum;
end

function PrevRot_Callback(~,~)
    plotRotation(rotNum-1);
    rotNum=(rotNum-1);
    hPicRot.String=rotNum;
end

function LoadRot_Callback(~,~)
    plotRotation(rotNum);
end

function Save_Callback(~,~)
    Print_processed_results;
end

%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [angleTime, theta] = importAngleData(~)
            mdata =importdata(motorFilePath, ';');%Imports data into variable 'mdata'
            
        ncol = numel(mdata.colheaders);
                    
        if (ncol == 9)
            %Loading Angle encoder data     
            angleTime=(mdata.data(:,1))/1000;
            theta=(mdata.data(:,9));
            %Reads time and angle columns converts to seconds
        elseif(ncol == 8)
            %Loading Angle encoder data     
            angleTime=(mdata.data(:,1))/1000;
            theta=(mdata.data(:,7));
            %Reads time and angle columns converts to seconds
        end
            
            
    end

    function [torqueTime, Torque] = importTorqueData(~)
        rdata =importdata(rotorFilePath, '\t');%Imports data into variable 'rdata'
        Torque=rdata.data(:,1).';

        %creates time vector for values of torque in 5ms intervals
        startValue = 0;
        endValue = length(Torque)/2;
        nElements = length(Torque);
        stepSize = (endValue-startValue)/(nElements-1);
        torqueTime = (startValue:stepSize:endValue)/1000;
    end

    function plotRotation(i)
    
    t=angleTime(sph(i):spl(i+1));
    a=theta(sph(i):spl(i+1));   
        
    pu=[0,359];
    pu1=interp1(a,t,pu,'linear','extrap');%time values for start and end of rotation
    
        q=find(abs(torqueTime-pu1(2)) < 0.00025);
        p=find(abs(torqueTime-pu1(1)) < 0.00025);
    
        rT=Tfilter(q:p);
        length(rT);
        
    tq=(0:1/((length(rT)-1)/359):359);%Creates stretches angleTime over every torque value
    tq1=interp1(a,t,tq,'linear','extrap');%time values for every torque value
    
    tq2=interp1(torqueTime,Tfilter,tq1,'linear','extrap');
        
    plot(ha_angle_torque,tq,flip(tq2),'b:.');
            
    tu=(0:1:359);     
    tu1=interp1(a,t,tu,'linear','extrap');%time values for angles 0-359
    
    tu2=interp1(torqueTime,Tfilter,tu1,'linear','extrap');
        hold on
    plot(ha_angle_torque,tu,flip(tu2),'rx');
        hold off
    grid; xlim([0 360]);
    xticks([0 30 60 90 120 150 180 210 240 270 300 330 360]);
    xlabel('Angle (Deg)');ylabel('Torque (Nm)');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
        ha_angle_torque.XGrid,'on';
        ha_angle_torque.YGrid,'on';
        ha_angle_torque.XLim=[0 360];
        ha_angle_torque.XTick=[0 30 60 90 120 150 180 210 240 270 300 330 360];
        ha_angle_torque.XLabel.String='Angle (Deg)';%lables axes
        ha_angle_torque.YLabel.String='Torque (Nm)';%lables axes
        ha_angle_torque.Title.String='Torque vs Angle';
    end

    function Print_processed_results(~)
        
        oldFileName=motorFilename;
        newFileName=append('Processed Data ',oldFileName);
        fileID=fopen(newFileName,'w');
        fprintf(fileID,'%10s %10s %10s\n','Torque(Nm)','Angle(deg)','Time(s)');

        for i=1:length(spl)-1
    
    t=angleTime(sph(i):spl(i+1));
    a=theta(sph(i):spl(i+1));   
        
    pu=[0,359];
    pu1=interp1(a,t,pu,'linear','extrap');%time values for start and end of rotation
    
        q=find(abs(torqueTime-pu1(2)) < 0.00025);
        p=find(abs(torqueTime-pu1(1)) < 0.00025);
    
        rT=Tfilter(q:p);
        length(rT);
        
    tq=(0:1/((length(rT)-1)/359):359);%Creates stretches angleTime over every torque value
    tq1=interp1(a,t,tq,'linear','extrap');%time values for every torque value
    
    tq2=interp1(torqueTime,Tfilter,tq1,'linear','extrap');

    A = [flip(tq2); flip(tq); flip(tq1)];
    fprintf(fileID,'%10.6f %10.6f %10.6f\n',A);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
    fclose(fileID);
        
    end
end