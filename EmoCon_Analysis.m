%%EmoConflict and GenderConflict Analyses
%%Cammie Rolle - cammie.rolle@gmail.com
clear all;clc;close all
% % To run the following analyses:
% % 1. Enter your Study Name Below
% % 2. Enter the Path to your data, which should all be stored in a single folder
% % 3. Enter the percent accuracy you want the answers reversed for
% % 4. Press Run!
% % 5. A .csv will be outputted for each subject, and one compiled spreadsheet with all subjects, 
% % TO: /Path/To/Data/AnalyzedData/

% % Contact me with any questions! cammie.rolle@gmail.com

%% Enter the below Variables then press RUN!
StudyName='StudyName';
PathToData='/Path/To/Data/'
PercentToRev=10; %In Percent

%% Run Analyses

SaveFolder=[PathToData 'AnalyzedData/'];
mkdir(SaveFolder);
ext='*.txt';
Subjects=dir([PathToData ext]);
SubjectName={Subjects.name}';
cd(PathToData);
SubjectAverageAll=zeros(length(Subjects),14);
ImportDataAllT=[];ImportDataAllH=[];
ind=0;
subIndx=0;
for ss=1:length(Subjects)
subIndx=subIndx+1;
%%Condition
if strfind(Subjects(ss).name,'gender')
    TaskType='GenderStroop';
else
    TaskType='EmoStroop';
end
%%DOTPROBE_EXAMPLE
fid = fopen(SubjectName{ss},'r');
C = textscan(fid, '%s','Delimiter','');
fclose(fid);
C = C{:};

%Format C
C=strtrim(C);
C=regexprep(C,'[^\w'']','');

%String Parameters
searchstrCondition='Condition';
searchstrCongruency='congruency';
searchstrAcc='stimACC';
searchstrRT='stimRT';
searchTrials='Procedure';
searchRESP='stimRESP';
searchCRESP='stimCRESP';

%Find Columns
TrialInd=find(~cellfun(@isempty, strfind(C,searchTrials)));
CondIndx= find(~cellfun(@isempty, strfind(C,searchstrCondition)));
CongIndx = find(~cellfun(@isempty, strfind(C,searchstrCongruency)));
AccIndx= find(~cellfun(@isempty, strfind(C,searchstrAcc)));
RTIndx= find(~cellfun(@isempty, strfind(C,searchstrRT)));
RESPIndx= find(~cellfun(@isempty, strfind(C,searchRESP)));
CRESPIndx= find(~cellfun(@isempty, strfind(C,searchCRESP)));

%Set Variables
Trials={C{TrialInd}}';
tmpindx=find(cellfun(@isempty, strfind(Trials,'paradigm')));
Trials(tmpindx)=[];
Conditions={C{CondIndx}}';
Conditions(tmpindx)=[];
Congruency={C{CongIndx}}';
Congruency(tmpindx)=[];
Acc={C{AccIndx}}';
RT={C{RTIndx}}';
tmpindx=find(~cellfun(@isempty, strfind(RT,'Time')));
RT(tmpindx)=[];
RESP={C{RESPIndx}}';
CRESP={C{CRESPIndx}}';

%Extract Data
VarNames={'Condition','Congruency','RT','Accuracy','Error','RESP','CRESP'};
clear Data ii
for ii=1:length(RT)
Data{ii,1}=Conditions{ii}(10:end);
Data{ii,2}=Congruency{ii}(11:end);
Data{ii,3}=RT{ii}(7:end);
Data{ii,4}=Acc{ii}(8);
if strcmp(Data{ii,4},'0')||strcmp(Data{ii-1,4},'0')
    Data{ii,5}='1';
else
    Data{ii,5}='0';
end
if length(RESP{ii})>8
Data{ii,6}=RESP{ii}(9);
else
Data{ii,6}='';
end
Data{ii,7}=CRESP{ii}(10);
if strcmp(Data{ii,6},Data{ii,7})
    AccTmp{ii,1}='1';
else
    AccTmp{ii,1}='0';
end
end
clear ii
%%Reverse Score if accuracy<10%
if mean(cell2mat(AccTmp))<PercentToRev
    AccTmpFix(strcmp(AccTmp,'1'))=0;
    AccTmpFix(strcmp(AccTmp,'0'))=1;
for ii=1:length(RT)
DataFix{ii,1}=Conditions{ii}(10:end);
DataFix{ii,2}=Congruency{ii}(11:end);
DataFix{ii,3}=RT{ii}(7:end);
DataFix{ii,4}=AccTmpFix(ii);
DataFix{ii,7}={Data{ii,7}}';
if ii>1
if DataFix{ii,4}==0||DataFix{ii-1,4}==0
    DataFix{ii,5}=1;
else
    DataFix{ii,5}=0;
end
else
DataFix{ii,5}=0;
end
if strcmp(Data{ii,6},'1')
DataFix{ii,6}='2';
elseif strcmp(Data{ii,6},'2')
DataFix{ii,6}='1';
else
DataFix{ii,6}='';
end
end
end

%Write Subject Data
DataTable=cell2table(Data,...
    'VariableNames',VarNames);
writetable(DataTable,[SaveFolder  Subjects(ss).name(1:end-4) '_Analyzed.csv'], 'WriteVariableNames',true);

if exist('DataFix','var')
DataFixTable=cell2table(DataFix,...
    'VariableNames',VarNames);
writetable(DataFixTable,[SaveFolder  Subjects(ss).name(1:end-4) '_Analyzed_RevScored.csv'], 'WriteVariableNames',true);
RevScore=1;
else
RevScore=0;
end

if RevScore==1
    Data=DataFix;
end
%Average Conditions
ConIndx=find(strcmp({Data{:,5}},'0')&strcmp({Data{:,1}},'con'))';
InConIndx=find(strcmp({Data{:,5}},'0')&strcmp({Data{:,1}},'incon'))';
ccIndx=find(strcmp({Data{:,5}},'0')&strcmp({Data{:,2}},'cc'))';
ciIndx=find(strcmp({Data{:,5}},'0')&strcmp({Data{:,2}},'ci'))';
icIndx=find(strcmp({Data{:,5}},'0')&strcmp({Data{:,2}},'ic'))';
iiIndx=find(strcmp({Data{:,5}},'0')&strcmp({Data{:,2}},'ii'))';
SubjectAllVar={'FileName' 'Accuracy','CongruentRT','IncongruentRT','ccRT','ciRT','icRT','iiRT',...
    'CondContrastRT','CongContrastRT'};

%Write SubjectAll Data
if RevScore==1;AllData{ss,1}=[Subjects(ss).name(1:end-4) '_RevScored.txt'];
else
AllData{ss,1}=Subjects(ss).name;
end
AllData{ss,2}=mean(cell2mat({Data{:,4}}'));
AllData{ss,3}=mean(cell2mat({Data{ConIndx,3}}'));
AllData{ss,4}=mean(cell2mat({Data{InConIndx,3}}'));
AllData{ss,5}=mean(cell2mat({Data{ccIndx,3}}'));
AllData{ss,6}=mean(cell2mat({Data{ciIndx,3}}'));
AllData{ss,7}=mean(cell2mat({Data{icIndx,3}}'));
AllData{ss,8}=mean(cell2mat({Data{iiIndx,3}}'));
AllData{ss,9}=mean(cell2mat({Data{InConIndx,3}}'))-mean(cell2mat({Data{ConIndx,3}}'));
AllData{ss,10}=mean(cell2mat({Data{ciIndx,3}}'))-mean(cell2mat({Data{iiIndx,3}}'));
disp([Subjects(ss).name ' Analyzed!']);
end

%Write DataAll
AllSubjTable=cell2table(AllData, 'VariableNames',SubjectAllVar);
writetable(AllSubjTable,[SaveFolder StudyName '_EmoConAnalyses.csv'],'WriteVariableNames', true);