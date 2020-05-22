%% Programme principal de reconnaissance et de sauvegarde des r�sultats
% -------------------------------------------------------------------------
% Input :
%           type = 'Test' ou 'Learn' pour d�finir les images trait�es
% Outputs
%           fileOut  :      nom (string) du fichier .mat des r�sultats de
%                           reconnaissance
%           resizeFactor :  facteur de redimensionnement qui a �t� appliqu�
%                           aux images
% 
%--------------------------------------------------------------------------


function [fileOut,resizeFactor] = metro(type)
close all;


% S�lectionner les images en fonction de la base de donn�es, apprentissage ou test

z = 1:261;
ok = 1;
if strcmp(type,'Test')
    numImages  = z(find(mod(z,3)));
    
elseif strcmp(type,'Learn')
    numImages  = z(find(~mod(z,3)));
    
else
    ok = 0;
    uiwait(errordlg('Bad identifier (should be ''Learn'' or ''Test'' ','ERRORDLG'));
end


if ok
    % Definir le facteur de redimensionnement

    resizeFactor = 2;
    BD= [];
    % Programme de reconnaissance des images
  %r  for n = numImages
    for n = numImages
       % On r�cup�re l'image
        disp("On traite imag "+n+"");
        im = imread(sprintf('BD/IM (%d).jpg',n));
        
        %patie alex resize and circle 
        %compresse le nb de pixel pour trouver les cercles 
        [rows, columns, numColorChannels] = size(im);
        numOutputRows = round(rows/resizeFactor);
        numOutputColumns = round(columns/resizeFactor);
        im = imresize(im, [numOutputRows, numOutputColumns]);
        %imgResize = rgb2gray(imgResize);
        
        %segmentation -- trouver les cercles avec imfindcircles --%
       [centers,radius] = imfindcircles(im,[8 80],'ObjectPolarity','dark', ... 
            'Sensitivity',0.818,'EdgeThreshold',0.07);

%         imshow(im)
%         title("Image "+ n + " ");
        
        h = viscircles(centers,radius);
        
        pic= [01 02 03 04 05 06 07 08 09 10 11 12 13 14];
        im = rgb2gray(im);

       %r figure;
        for m = 1: length(radius)
            disp("On traite le cercle "+m+"");
            maLignetrouve = [];
            try
                im2=im( centers(m,2)-radius(m,1):centers(m,2)+radius(m,1),centers(m,1)-radius(m,1):centers(m,1)+radius(m,1));
            catch ME
                break;
            end
            
           %r imshow(im2);
            level = graythresh(im2);
            BW = imbinarize(im2,level);
            
            matricedesimilitude = [];
            for elem = pic
                disp("On traite la ligne de metro "+elem+"");
                impan= [];
                if elem<10
                    impan = imread(sprintf('PICTO/0%d.png',elem));
                    [centerspan,radiuspan] = imfindcircles(impan,[20 120],'ObjectPolarity','dark', ... 
                    'Sensitivity',0.92,'EdgeThreshold',0.082); 
                    impan=impan(centerspan(1,2)-radiuspan(1):centerspan(1,2)+radiuspan(1),centerspan(1,1)-radiuspan(1):centerspan(1,1)+radiuspan(1));
                    %impan=rgb2gray(impan);
                    level = graythresh(impan);
                    if elem==6 
                       level=level-0.4; 
                    end    
                    BWpan = double(imbinarize(impan,level));
                    
                   
                else
                    impan = imread(sprintf('PICTO/%d.png',elem));
                    [centerspan,radiuspan] = imfindcircles(impan,[20 120],'ObjectPolarity','dark', ... 
                    'Sensitivity',0.92,'EdgeThreshold',0.082); 
                    impan=impan(centerspan(1,2)-radiuspan(1):centerspan(1,2)+radiuspan(1),centerspan(1,1)-radiuspan(1):centerspan(1,1)+radiuspan(1));
                   % impan=rgb2gray(impan);
                    level = graythresh(impan);
                    if elem==13
                       level=level-0.4;  
                    end    
                    BWpan = double(imbinarize(impan,level));
                    
                end
                
                BW = double(imresize(BW,size(BWpan)));
               %r imshowpair(BW,BWpan,'montage');
              %r  title("On compare image recuperer du metro et celle des ligne de metro BDD (iteration ligne par ligne)");
                [ssimval, ssimmap]  = ssim(BW, BWpan);
                matricedesimilitude= [matricedesimilitude;ssimval];
             %r   imshow(ssimmap,[]);
             %r   title(['Local SSIM Map with Global SSIM Value: ',num2str(ssimval)]);
                                        
            end
            [maxssimval,indexssimval]= max(matricedesimilitude);
            disp(matricedesimilitude);
            if maxssimval> 0.4
                    
                    maLignetrouve = [n floor(resizeFactor*centers(m,2)-resizeFactor*radius(m)) floor(resizeFactor*centers(m,2)+resizeFactor*radius(m)) floor(resizeFactor*centers(m,1)-resizeFactor*radius(m)) floor(resizeFactor*centers(m,1)+resizeFactor*radius(m)) indexssimval];
                    BD = [BD;maLignetrouve];
                    disp('Nous avons trouver un match avce la ligne de metro');
                   
            end

        end    

    end
%Sauvegarde dans un fichier .mat des r�sulatts

  fileOut  = ('myResults.mat');
  save(fileOut,'BD');  
end

