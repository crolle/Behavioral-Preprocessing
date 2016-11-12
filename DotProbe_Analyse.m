%%DotProbe Cammie
clear all;clc;close all
%PathToData='/Users/Cammie/Box Sync/Files/Box Desktop/Etkin Lab Materials/Behavioral_Data_Preprocessed_CR/Cohen_DotProbe/cohen_dot_probe_data/'
%SaveFolder='/Users/Cammie/Box Sync/Files/Box Desktop/Etkin Lab Materials/Behavioral_Data_Preprocessed_CR/Cohen_DotProbe/AnalyzedData/'
PathToData='/Users/Cammie/Box Sync/Files/Box Desktop/Etkin Lab Materials/Behavioral_Data_Preprocessed_CR/CC_Dotprobe/'
SaveFolder='/Users/Cammie/Box Sync/Files/Box Desktop/Etkin Lab Materials/Behavioral_Data_Preprocessed_CR/CC_Dotprobe/AnalyzedData/'
mkdir(SaveFolder);
StudyName='CausCon';
ext='*.txt';
Subjects=dir([PathToData ext]);
SubjectName={Subjects.name}';
cd(PathToData);
SubjectAverageAll=zeros(length(Subjects),14);
addpath(genpath('/Users/Cammie/Box Sync/Files/Box Desktop/Etkin Lab Materials/ABV/'));
ImportDataAllT=[];ImportDataAllH=[];
ind=0;
for ss=1:length(Subjects)
%%DOTPROBE_EXAMPLE
fid = fopen(SubjectName{ss},'r');
C = textscan(fid, '%s','Delimiter','');
fclose(fid);
C = C{:};

%Format C
C=strtrim(C);
C=regexprep(C,'[^\w'']','');
 
%Parameters
ImageExt={'snn','tr','tl','hl','hr'};
ImageKey={'Neutral','Threat-Right','Threat-Left','Happy-Left','Happy-Right'};
TargetExt={'UAR','UAL','DAL','DAR'};
TargetKey={'Right','Left','Left','Right'};

%String Parameters
searchstrProcedure='Procedure';
searchstrImage='Image';
searchstrTarget='Targetbmp';
searchstrAcc='PrbACC';
searchstrRT='PrbRT';

%Find Columns
ProcIndx= find(~cellfun(@isempty, strfind(C,searchstrProcedure)));
ImageIndx = find(~cellfun(@isempty, strfind(C,searchstrImage)));
TargetIndx= find(~cellfun(@isempty, strfind(C,searchstrTarget)));
AccIndx= find(~cellfun(@isempty, strfind(C,searchstrAcc)));
RTIndx= find(~cellfun(@isempty, strfind(C,searchstrRT)));

%Set Variables
Procedure={C{ProcIndx}}'; Procedure=Procedure(1:length(TargetIndx));
Image={C{ImageIndx}}';
Target={C{TargetIndx}}';
Acc={C{AccIndx}}';
RT={C{RTIndx}}';
tmpindx=find(~cellfun(@isempty, strfind(RT,'Time')));
RT(tmpindx)=[];

%Extract Data
clear Data
for ii=1:length(Image)
Data{ii,1}=Procedure{ii}(10:end);
Data{ii,2}=Image{ii}(6:end);
Data{ii,3}=Target{ii}(7:end);
Data{ii,4}=RT{ii}(6:end);
Data{ii,5}=Acc{ii}(7);
for ee=1:length(ImageExt)
tmp=strfind(Data{ii,2},ImageExt{ee});
if tmp>0;ImageSide=ImageKey{ee};break;end;
end
for tt=1:length(TargetExt)
tmp=strfind(Data{ii,3},TargetExt{tt});
if tmp>0;TargetSide=TargetKey{tt};break;end;
end
Data{ii,6}=ImageSide;
Data{ii,7}=TargetSide;
if strfind(ImageSide,'Threat')
    if strfind(ImageSide,TargetSide) 
        TrialType='T';
    else
        TrialType='NT';
    end
elseif strfind(ImageSide,'Happy')
    if strfind(ImageSide,TargetSide) 
        TrialType='H';
    else
        TrialType='NH';
    end
else
    TrialType='N';
end
Data{ii,8}=TrialType;
clear ImageSide TargetSide TrialType 
end
clear ee tt ii

%% Create Averages
ThreatAve=[];NonThreatAve=[];NeutralAve=[];HappyAve=[];NonHappyAve=[];
for aa=1:length(Data)
    if strcmp(Data(aa,5),'1')
        if strcmp(Data(aa,8),'T')
        ThreatAve=[ThreatAve,Data(aa,4)];
        elseif strcmp(Data(aa,8),'NT')
        NonThreatAve=[NonThreatAve,Data(aa,4)];
        elseif strcmp(Data(aa,8),'N')
        NeutralAve=[NeutralAve,Data(aa,4)];
        elseif strcmp(Data(aa,8),'H')
        HappyAve=[HappyAve,Data(aa,4)];
        elseif strcmp(Data(aa,8),'NH')
        NonHappyAve=[NonHappyAve,Data(aa,4)];
        end
    end
end
ThreatAve=mean(str2num(cell2mat(ThreatAve')));
NonThreatAve=mean(str2num(cell2mat(NonThreatAve')));
NeutralAve=mean(str2num(cell2mat(NeutralAve')));
if ~isempty(HappyAve)
HappyAve=mean(str2num(cell2mat(HappyAve')));
NonHappyAve=mean(str2num(cell2mat(NonHappyAve')));
end
%% Create Contrasts
if ~isempty(HappyAve)
BiasH=HappyAve-NeutralAve;
DisengageH=NonHappyAve-NeutralAve;
BiasT=ThreatAve-NeutralAve;
DisengageT=NonThreatAve-NeutralAve;
Fear_Neutral=mean([BiasT DisengageT]);
Happy_Neutral=mean([BiasH DisengageH]);
Emotion_Neutral=mean([Fear_Neutral Happy_Neutral]);
Fear_Congruency=DisengageT-BiasT;
Happy_Congruency=DisengageH-BiasH;
SubjectAverage=[ThreatAve NonThreatAve NeutralAve NonHappyAve HappyAve BiasH DisengageH BiasT DisengageT Fear_Neutral Happy_Neutral Emotion_Neutral Fear_Congruency Happy_Congruency];
SubjectAverageAll(ss,:)=SubjectAverage;
else
BiasT=ThreatAve-NeutralAve;
DisengageT=NonThreatAve-NeutralAve;
Fear_Neutral=mean([BiasT DisengageT]);
Fear_Congruency=DisengageT-BiasT;
SubjectAverage=[ThreatAve NonThreatAve NeutralAve BiasT DisengageT Fear_Neutral Fear_Congruency];
SubjectAverageAll(ss,1:length(SubjectAverage))=SubjectAverage;
end

%% ABV

%Import the data
ind=ind+1;
clear ABV* abv* ThreatTrials HappyTrials
ABVFileT = readtable('/Users/Cammie/Box Sync/Files/Box Desktop/Etkin Lab Materials/Behavioral_Data_Preprocessed_CR/ABV_Template.xlsx');
ABVFileH = readtable('/Users/Cammie/Box Sync/Files/Box Desktop/Etkin Lab Materials/Behavioral_Data_Preprocessed_CR/ABV_Template.xlsx');
ThreatTrials=find(strcmp(Data(:,8),'NT')|strcmp(Data(:,8),'T')|strcmp(Data(:,8),'N'));
HappyTrials=find(strcmp(Data(:,8),'NH')|strcmp(Data(:,8),'H')|strcmp(Data(:,8),'N'));
abvExperimentNameH=cellstr(repmat([StudyName 'H'],length(HappyTrials),1));
abvExperimentNameT=cellstr(repmat([StudyName 'T'],length(ThreatTrials),1));
abvSubjectH=cellstr(repmat(num2str(ind),length(HappyTrials),1));
abvSubjectT=cellstr(repmat(num2str(ind),length(ThreatTrials),1));
ABVDataH=Data(HappyTrials,:);
ABVDataT=Data(ThreatTrials,:);
abvAccH=ABVDataH(:,5);
abvRTH=ABVDataH(:,4);
ABVDataH(find(strcmp(ABVDataH(:,6),'Happy-Right') & strcmp(ABVDataH(:,7),'Right')),6)={'threat'};
ABVDataH(find(strcmp(ABVDataH(:,6),'Happy-Left') & strcmp(ABVDataH(:,7),'Left')),6)={'threat'};
ABVDataH(find(strcmp(ABVDataH(:,6),'Neutral') | (strcmp(ABVDataH(:,6),'Happy-Right') & strcmp(ABVDataH(:,7),'Left')) | (strcmp(ABVDataH(:,6),'Happy-Left') & strcmp(ABVDataH(:,7),'Right'))) ,6)={'neutral'};

ABVDataT(find(strcmp(ABVDataT(:,6),'Threat-Right') & strcmp(ABVDataT(:,7),'Right')),6)={'threat'};
ABVDataT(find(strcmp(ABVDataT(:,6),'Threat-Left') & strcmp(ABVDataT(:,7),'Left')),6)={'threat'};
ABVDataT(find(strcmp(ABVDataT(:,6),'Neutral') | (strcmp(ABVDataT(:,6),'Threat-Right') & strcmp(ABVDataT(:,7),'Left')) | (strcmp(ABVDataT(:,6),'Threat-Left') & strcmp(ABVDataT(:,7),'Right'))) ,6)={'neutral'};

ABVDataH(find(strcmp(ABVDataH(:,8),'H')),8)={'NT'};
ABVDataH(find(strcmp(ABVDataH(:,8),'N')),8)={'NN'};
ABVDataH(find(strcmp(ABVDataH(:,8),'NH')),8)={'NT'};
ABVDataT(find(strcmp(ABVDataT(:,8),'NT')),8)={'NT'};
ABVDataT(find(strcmp(ABVDataT(:,8),'T')),8)={'NT'};
ABVDataT(find(strcmp(ABVDataT(:,8),'N')),8)={'NN'};
%THREAT
ABVFileT(1:length(ThreatTrials),'ExperimentName')=abvExperimentNameT;
ABVFileT(1:length(ThreatTrials),'Subject')=abvSubjectT;
ABVFileT(1:length(ThreatTrials),'Probe_ACC')=ABVDataT(:,5);
ABVFileT(1:length(ThreatTrials),'Probe_RT')=ABVDataT(:,	4);
ABVFileT(1:length(ThreatTrials),'ProbeBehind')=ABVDataT(:,6);
ABVFileT(1:length(ThreatTrials),'TrialType')=ABVDataT(:,8);
%HAPPY
ABVFileH(1:length(HappyTrials),'ExperimentName')=abvExperimentNameH;
ABVFileH(1:length(HappyTrials),'Subject')=abvSubjectH;
ABVFileH(1:length(HappyTrials),'Probe_ACC')=ABVDataH(:,5);
ABVFileH(1:length(HappyTrials),'Probe_RT')=ABVDataH(:,	4);
ABVFileH(1:length(HappyTrials),'ProbeBehind')=ABVDataH(:,6);
ABVFileH(1:length(HappyTrials),'TrialType')=ABVDataH(:,8);

% ABVNames={'ExperimentName','Subject','Session','Group','RandomSeed','SessionDate','SessionTime','Set','FaceSet','Procedure[Block]','Running[Block]','SessionType','Probe.ACC','Probe.DurationError','Probe.RT','ProbeBehind','Procedure[Trial]','Running[Trial]','TrialType'}
% ImportDataH=[ABVNames ;table2cell(ABVFileH)];
% ImportDataH(length(HappyTrials)+1:length(ImportDataH),:)=[];
% ImportDataT=[ABVNames ;table2cell(ABVFileT)];
% ImportDataT(length(ThreatTrials)+1:length(ImportDataT),:)=[];
ImportDataAllH=[ImportDataAllH; ABVFileH(1:length(HappyTrials),:)];
ImportDataAllT=[ImportDataAllT; ABVFileT(1:length(ThreatTrials),:)];
%mineCode_embedded(ImportDataH,SaveFolder);
%% Save Files
if ~isempty(HappyAve)
ContrastNames={'Threat' 'NonThreat' 'Neutral' 'NonHappy' 'Happy' 'HappyBias' 'HappyDisengage' 'ThreatBias' 'ThreatDisengage' 'Fear-Neutral' 'Happy-Neutral' 'Emotion-Neutral' 'Fear_Congruency' 'Happy_Congruency'};
SubjectAverageConv=mat2dataset(SubjectAverage,'VarNames',ContrastNames);
export(SubjectAverageConv,'file',[SaveFolder SubjectName{ss}(1:end-4) '_Analyzed.txt'],'WriteVarNames',true);
else
ContrastNames={'Threat' 'NonThreat' 'Neutral' 'ThreatBias' 'ThreatDisengage' 'Fear-Neutral' 'Fear_Congruency'};
SubjectAverageConv=mat2dataset(SubjectAverage,'VarNames',ContrastNames);
export(SubjectAverageConv,'file',[SaveFolder SubjectName{ss}(1:end-4) '_Analyzed.txt'],'WriteVarNames',true);
end
end
%% Save All File
SubjectAverageAllConv=mat2dataset(SubjectAverageAll,'VarNames',ContrastNames,'ObsNames',SubjectName);
export(SubjectAverageAllConv,'file',[SaveFolder StudyName '_DotProbe_Compiled.csv'],'WriteVarNames',true,'WriteObsNames',true);
writetable(ImportDataAllH,[SaveFolder  StudyName '_ABVH_Compiled.csv'],'WriteVariableNames',true);
writetable(ImportDataAllT,[SaveFolder  StudyName '_ABVT_Compiled.csv'],'WriteVariableNames',true);
%% Plots Contrasts
if ~isempty(HappyAve)
ContrastNames={'HappyBias' 'HappyDisengage' 'ThreatBias' 'ThreatDisengage' 'Fear-Neutral' 'Happy-Neutral' 'Emotion-Neutral' 'Fear_Congruency' 'Happy_Congruency'};
error=(std(SubjectAverageAll(:,6:14)))/(sqrt(size(SubjectAverageAll(:,6:14),1)));
y=mean(SubjectAverageAll(:,6:14),1);
barwitherr(error,y);
title([StudyName ' DotProbe Data']);
set(gca,'XTickLabel', ContrastNames);
saveas(gcf,[SaveFolder 'BarPlot: Contrasts ' StudyName '.png']);
close all;

AverageNames={'Threat' 'NonThreat' 'Neutral' 'NonHappy' 'Happy'};
error=(std(SubjectAverageAll(:,1:5)))/(sqrt(size(SubjectAverageAll(:,1:5),1)));
y=median(SubjectAverageAll(:,1:5),1);
barwitherr(error,y);
title([StudyName ' DotProbe Data']);
ylim([400 800])
set(gca,'XTickLabel', AverageNames);
saveas(gcf,[SaveFolder 'BarPlot: Averages ' StudyName '.png']);
close all;
else
ContrastNames={'ThreatBias' 'ThreatDisengage' 'Fear-Neutral' 'Fear_Congruency'};
error=(std(SubjectAverageAll(:,4:7)))/(sqrt(size(SubjectAverageAll(:,4:7)),1));
y=median(SubjectAverageAll(:,4:7),1);
barwitherr(error,y);
title([StudyName ' DotProbe Data']);
set(gca,'XTickLabel', ContrastNames);
saveas(gcf,[SaveFolder 'BarPlot: Contrasts ' StudyName '.png']);
close all;

AverageNames={'Threat' 'NonThreat' 'Neutral'};
error=(std(SubjectAverageAll(:,1:3)))/(sqrt(size(SubjectAverageAll(:,1:3),1)));
y=mean(SubjectAverageAll(:,1:3),1);
barwitherr(error,y);
title([StudyName ' DotProbe Data']);
set(gca,'XTickLabel', AverageNames);
saveas(gcf,[SaveFolder 'BarPlot: Averages ' StudyName '.png']);
close all;      
end

disp ('Done!')