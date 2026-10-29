%[text] # Process Quantitative EPMA Maps
%[text] ## Import Data
  %[control:button:32f5]{"position":[1,2]}

clear all; close all; 

load batlowK.mat
FL     = {'FontSize',16};
FS     = {'FontSize',12};
Fs     = {'FontSize',10};
TX     = {'Interpreter','Latex'};
TL     = {'TicklabelInterpreter','Latex'};
LW     = {'LineWidth',2};
MS     = {'MarkerSize',10};
UN     = {'Units','inches'};

addpath ./data
filename = "LAU_7b_area2_Oxide_Image_Classify.DAT"; %[control:editfield:3ad4]{"position":[12,51]}

opts = delimitedTextImportOptions("NumVariables", 18);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["Var1", "X", "Y", "NX", "NY", "NXY", "SiWT", "AlWT", "CaWT", "KWT", "FeWT", "TiWT", "MgWT", "NaWT", "OWT", "Total", "CalcO", "VarName18"];
opts.SelectedVariableNames = ["X", "Y", "NX", "NY", "NXY", "SiWT", "AlWT", "CaWT", "KWT", "FeWT", "TiWT", "MgWT", "NaWT", "OWT", "Total", "CalcO"];
opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Var1", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var1", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "VarName18", "TrimNonNumeric", true);
opts = setvaropts(opts, "VarName18", "ThousandsSeparator", ",");

% Import the data
DATtab = readtable(filename, opts);

disp('Data loaded successfully')
%%
%[text] ## Convert data
  %[control:button:6481]{"position":[1,2]}

% convert table to array
DATvec = table2array(DATtab);

% extract map dimensions
nx = max(DATvec(:,3));
nz = max(DATvec(:,4));
DATmap = reshape(DATvec,nx,nz,[]);
DATmap = permute(DATmap,[2,1,3]);

X  = DATmap(1,:,1).';
Z  = DATmap(:,1,2);

% sort oxides into standard sequence
%           Si Ti Al Fe Mg Ca Na K  O  Total
OxdInd   = [1, 6, 2, 5, 7, 3, 8, 4, 9, 10];
OxdNames = {'SiO2';'TiO2';'Al2O3';'FeO';'MgO';'CaO';'Na2O';'K2O';'O';'Total'};
nc       = length(OxdInd);
Si = 1; Ti = 2; Al = 3; Fe = 4; Mg = 5; Ca = 6; Na = 7; K = 8; O = 9; Total = 10;
OxdVec = DATvec(:,5+OxdInd); OxdVec0 = OxdVec;
OxdMap = DATmap(:,:,5+OxdInd);
OxdLim = {[0 90];[0 5];[0 30];[0 30];[0 30];[0 20];[0 10];[0 5]}; 

disp('Data converted successfully')
%%
  %[control:button:47ac]{"position":[1,2]}

% extract valid totals
mintot =95; %[control:slider:4b2b]{"position":[9,11]}
maxtot =105; %[control:slider:8c5c]{"position":[9,12]}

valmap = OxdMap(:,:,Total)>mintot & OxdMap(:,:,Total)<maxtot;
valvec = OxdVec(:,Total)>mintot & OxdVec(:,Total)<maxtot;

fh1 = figure(1); clf;
set(fh1,UN{:},'Position',[1 1 8 6]);
imagesc(X,Z,OxdMap(:,:,Total).*valmap); axis equal tight; colormap(batlowK); colorbar(TL{:},FS{:}); 
clim([mintot,maxtot]);
set(gca,TL{:},Fs{:})
title('Total [wt\%]',TX{:},FL{:})

%[text] **Fig. 1:** Analytical totals of major oxide measurments of valid points between set min/max tolerance levels.
%%
%[text] ## Plot major element oxide maps
% plot oxide compositions

  %[control:button:619a]{"position":[1,2]}

fh2 = figure(2); clf;
set(fh2,UN{:},'Position',[1 1 24 15]);
k  = nc-2;
if     k<=4;  kk = 2; kkk = 2; 
elseif k<=6;  kk = 2; kkk = 3;
elseif k<=8;  kk = 2; kkk = 4;
elseif k<=9;  kk = 3; kkk = 3;
elseif k<=12; kk = 3; kkk = 4;
end

ik = 1;
for ikk=1:kk
    for ikkk = 1:kkk
        subplot(kk,kkk,ik);
        imagesc(X,Z,OxdMap(:,:,ik).*valmap); axis equal tight; 
        colormap(batlowK); colorbar(TL{:},FS{:});
        clim(OxdLim{ik});
        set(gca,TL{:},Fs{:})
        title([OxdNames{ik},' [wt\%]'],TX{:},FL{:})
        ik = ik+1;
    end
end
%[text] **Fig. 2:** Major oxide concentrations; colorbar range cropped to improve readability.
%%
%[text] ## Plot False Colour Images
  %[control:button:910e]{"position":[1,2]}

sat = 2; %[control:slider:1b7b]{"position":[7,8]}

fh3 = figure(3); clf;
set(fh3,UN{:},'Position',[1 1 12 8]);

subplot(1,3,1)
RGB = OxdVec(:,[Si,Al,Ti]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: SiO$_2$, Al$_2$O$_3$, TiO$_2$',TX{:},FL{:})

subplot(1,3,2)
RGB = OxdVec(:,[Fe,Mg,Ca]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: FeO, MgO, CaO',TX{:},FL{:})

subplot(1,3,3)
RGB = OxdVec(:,[K,Na,Ca]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: K$_2$O, Na$_2$O, CaO',TX{:},FL{:})

%[text] **Fig. 3:** False-colour images of raw oxide data showing images of (left to right) RGB = \[TiO2, SiO2, Al2O3\]; \[FeO, MgO, CaO\]; \[K2O, Na2O, CaO\].
%%
%[text] ## Filter and Scale Data
  %[control:button:56e1]{"position":[1,2]}

smth = 1; %[control:slider:6051]{"position":[8,9]}

for i = 1:k
    MAP = reshape(OxdVec0(:,i).*valvec,nx,nz);
    MAP = imnlmfilt(MAP,'DegreeOfSmoothing',smth);
    OxdVec(:,i) = MAP(:);
end

% normalise data to unit sum for relative intensities
OxdVec(:,Si:K)  =  OxdVec(:,Si:K)./(sum(OxdVec(:,Si:K),2)+1e-32);

% plot filtered and rescaled results
fh4 = figure(4); clf;
set(fh4,UN{:},'Position',[1 1 12 8]);

subplot(1,3,1)
RGB = OxdVec(:,[Si,Al,Ti]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: SiO$_2$, Al$_2$O$_3$, TiO$_2$',TX{:},FL{:})

subplot(1,3,2)
RGB = OxdVec(:,[Fe,Mg,Ca]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: FeO, MgO, CaO',TX{:},FL{:})

subplot(1,3,3)
RGB = OxdVec(:,[K,Na,Ca]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: K$_2$O, Na$_2$O, CaO',TX{:},FL{:})
%[text] **Fig. 4:** False-colour images of filtered and rescaled oxide data showing images of (left to right) RGB = \[TiO2, SiO2, Al2O3\]; \[FeO, MgO, CaO\]; \[K2O, Na2O, CaO\].
%%
%[text] ## Perform Principal Component Analysis
  %[control:button:809e]{"position":[1,2]}

% perform principal component analysis
[PC, PA, PV] = pca(OxdVec(valvec,Si:K),'Algorithm','svd','Centered','on','VariableWeights','variance');
PC = PC.';
CV = cumsum(PV./sum(PV));
Ap = zeros(size(OxdVec,1),k);
Ap(valvec,:) = PA(:,1:k);

% plot tradeoff curve
fh5 = figure(5); clf;
set(fh5,UN{:},'Position',[1 1 7 5]);

plot(1:k,CV*100,'k-',1:k,CV*100,'r*',LW{:},MS{:}); hold on
plot(1:k,PV./sum(PV)*100,'k--',LW{:},MS{:});
title('PCA tradeoff',TX{:},FL{:})
xlabel('principal components',TX{:},FL{:})
ylabel('\% variance',TX{:},FL{:})
set(gca,TL{:},FS{:},'Xtick',0:k)
%[text] **Fig. 5:** Principal component tradeoff curve showing individual (dashed) and cumulative percentage (solid) of variance versus number of principal components retained.

% plot PCA loading maps
fh6 = figure(6); clf;
set(fh6,'Units','inches','Position',[1 1 16 12]);

Nrow = floor(sqrt(k+1));
Ncol = ceil((k+1)/Nrow);

for nplt=1:k
    subplot(Nrow,Ncol,nplt)
    imagesc(X,Z,reshape(Ap(:,nplt),nx,nz).'); colormap(gray); colorbar(TL{:},FS{:}); axis equal tight;
    set(gca,TL{:})
    title(['PC ',int2str(nplt)],FL{:},TX{:})
end
%[text] **Fig. 6:** Principal component loadings per component showing the spatial patterns in each component,  indicating which PC's carry meaningful signal versus noise.
%%
%[text] ## Reduce Data Dimensions
  %[control:button:2fd1]{"position":[1,2]}

p =1; %[control:slider:14fb]{"position":[4,5]}

% reduce data to p principal components
Fp = PC(1:p,:);
Ap = zeros(size(OxdVec,1),p);
Ap(valvec,:) = PA(:,1:p);
OxdPC = Ap*Fp + mean(OxdVec(:,Si:K).*valvec);
Rp = sum((OxdPC-OxdVec(:,Si:K).*valvec).^2,2)./sum((OxdVec(:,Si:K).*valvec).^2,2);

% plot PCA false colour images
fh7 = figure(7); clf;
set(fh7,UN{:},'Position',[1 1 12 8]);

subplot(1,3,1)
RGB = OxdPC(:,[Si,Al,Ti]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: SiO$_2$, Al$_2$O$_3$, TiO$_2$',TX{:},FL{:})

subplot(1,3,2)
RGB = OxdPC(:,[Fe,Mg,Ca]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: FeO, MgO, CaO',TX{:},FL{:})

subplot(1,3,3)
RGB = OxdPC(:,[K,Na,Ca]);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title('RGB: K$_2$O, Na$_2$O, CaO',TX{:},FL{:})
%[text] **Fig. 7:** False-colour images of reduced data showing images of (left to right) RGB = \[TiO2, SiO2, Al2O3\]; \[FeO, MgO, CaO\]; \[K2O, Na2O, CaO\].
fh8 = figure(8); clf;
set(fh8,UN{:},'Position',[1 1 12 8]);

subplot(1,2,1)
ic = [1,min(2,p),min(3,p)];
RGB = Ap(:,ic);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title(['RGB: PC',int2str(ic(1)),', PC',int2str(ic(2)),', PC',int2str(ic(3))],TX{:},FL{:})

subplot(1,2,2)
ic = [max(1,p-2),max(1,p-1),max(1,p)];
RGB = Ap(:,ic);
RGB = valvec.*(RGB - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:)))) ./ ((mean(RGB(valvec,:))+sat*std(RGB(valvec,:))) - (mean(RGB(valvec,:))-sat*std(RGB(valvec,:))));
imagesc(X,Z,permute(reshape(RGB,nx,nz,[]),[2,1,3])); axis equal tight;
set(gca,TL{:},Fs{:})
title(['RGB: PC',int2str(ic(1)),', PC',int2str(ic(2)),', PC',int2str(ic(3))],TX{:},FL{:})
%[text] **Fig. 8:** False-colour images of reduced principal component loading.
%%
%[text] ## Perform Clustering Analysis
  %[control:button:8985]{"position":[1,2]}

c =2; %[control:slider:981f]{"position":[4,5]}

% perform k-means clustering analysis
opts = statset('Display','final');
rng(15);
[Ic,Fc] = kmeans(Ap(valvec,:),c,'MaxIter',1e3,'Replicates',10,'Options',opts);
Icfull = zeros(size(valvec));
Icfull(valvec,1) = Ic;

% get cluster compositions in oxides
ClstOxdMean = zeros(c,k);
ClstOxdStd  = zeros(c,k);
for ic = 1:c
    ClstOxdMean(ic,:) = mean(OxdVec(Icfull==ic,Si:K));
    ClstOxdStd(ic,:)  =  std(OxdVec(Icfull==ic,Si:K));
end

% sort clusters for ascending SiO2 content
[~,isort]   = sort(ClstOxdMean(:,1),'ascend');
ClstOxdMean = ClstOxdMean(isort,:);
ClstOxdStd  = ClstOxdStd (isort,:);
Icfull_sort = zeros(size(valvec));
for ic = 1:c
    Icfull_sort(Icfull==isort(ic)) = ic;
end
Icfull = Icfull_sort;

% plot trained model map
ColorClass = batlowK(max(1,min(256,1+round((1:256)/(256/c))*round(256/c))),:);

fh9 = figure(9); clf;
set(fh9,'Units','inches','Position',[1 1 10 8]);

imagesc(X,Z,reshape(Icfull,nx,nz).'); colormap(ColorClass); colorbar(TL{:},FS{:}); axis equal tight;
title('Classified model map',FL{:},TX{:})
set(gca,TL{:})
%[text] **Fig. 9:** Cluster classification map.

% plot clusters separately
fh10 = figure(10); clf;
set(fh10,'Units','inches','Position',[1 1 16 12]);

Nrow = floor(sqrt(c+1));
Ncol = ceil((c+1)/Nrow);

for nplt=1:c+1
    subplot(Nrow,Ncol,nplt)
    imagesc(X,Z,reshape(Icfull==(nplt-1),nx,nz).'); colormap(gray); colorbar(TL{:},FS{:}); axis equal tight;
    set(gca,TL{:})
    title(['Cluster ',int2str(nplt-1)],FL{:},TX{:})
end
%[text] **Fig. 10:** Cluster membership maps.
%[text] 
%[text] Cluster compositions mean (wt% SiO$\_2$, TiO$\_2$, Al$\_2$O$\_3$, FeO, MgO, CaO, Na$\_2$O, K$\_2$O)
disp(ClstOxdMean*100)
%[text] Cluster compositions standard deviation (wt% SiO$\_2$, TiO$\_2$, Al$\_2$O$\_3$, FeO, MgO, CaO, Na$\_2$O, K$\_2$O)
disp(ClstOxdStd*100)
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"hidecode","rightPanelPercent":40}
%---
%[control:button:32f5]
%   data: {"label":"Import data","run":"Section"}
%---
%[control:editfield:3ad4]
%   data: {"defaultValue":"\"\"","label":"filename","run":"Section","valueType":"String"}
%---
%[control:button:6481]
%   data: {"label":"Convert data","run":"Section"}
%---
%[control:button:47ac]
%   data: {"label":"Exclude invalid points","run":"Section"}
%---
%[control:slider:4b2b]
%   data: {"defaultValue":90,"label":"min. Total","max":100,"min":80,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[control:slider:8c5c]
%   data: {"defaultValue":110,"label":"min. Total","max":120,"min":100,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[control:button:619a]
%   data: {"label":"Plot oxide maps","run":"Section"}
%---
%[control:button:910e]
%   data: {"label":"Plot false colour images","run":"Section"}
%---
%[control:slider:1b7b]
%   data: {"defaultValue":2,"label":"saturation","max":4,"min":1,"run":"Section","runOn":"ValueChanged","step":0.1}
%---
%[control:button:56e1]
%   data: {"label":"Filter and scale data","run":"Section"}
%---
%[control:slider:6051]
%   data: {"defaultValue":1,"label":"smth","max":2,"min":0.1,"run":"Section","runOn":"ValueChanging","step":0.1}
%---
%[control:button:809e]
%   data: {"label":"Perform PCA","run":"Section"}
%---
%[control:button:2fd1]
%   data: {"label":"Reduce data dimensions","run":"Section"}
%---
%[control:slider:14fb]
%   data: {"defaultValue":4,"label":"p = ","max":8,"min":1,"run":"Section","runOn":"ValueChanged","step":1}
%---
%[control:button:8985]
%   data: {"label":"Perform clustering","run":"Section"}
%---
%[control:slider:981f]
%   data: {"defaultValue":4,"label":"k = ","max":10,"min":2,"run":"Section","runOn":"ValueChanged","step":1}
%---
