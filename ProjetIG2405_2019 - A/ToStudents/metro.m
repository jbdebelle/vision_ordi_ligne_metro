%% Programme principal de reconnaissance et de sauvegarde des résultats
% -------------------------------------------------------------------------
% Input :
%           type = 'Test' ou 'Learn' pour définir les images traitées
% Outputs
%           fileOut  :      nom (string) du fichier .mat des résultats de
%                           reconnaissance
%           resizeFactor :  facteur de redimensionnement qui a été appliqué
%                           aux images
% 
%--------------------------------------------------------------------------


function [fileOut,resizeFactor] = metro(type)
close all;


% Sélectionner les images en fonction de la base de données, apprentissage ou test

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
   % for n= 1
       % On récupère l'image
        disp("On traite imag "+n+"");
        imo = imread(sprintf('BD/IM (%d).jpg',n));
        
        %patie alex resize and circle 
        %compresse le nb de pixel pour trouver les cercles 
        [rows, columns, numColorChannels] = size(imo);
        numOutputRows = round(rows/resizeFactor);
        numOutputColumns = round(columns/resizeFactor);
        im = imresize(imo, [numOutputRows, numOutputColumns]);
        %imgResize = rgb2gray(imgResize);
        
        %segmentation -- trouver les cercles avec imfindcircles --%
       [centers,radius] = imfindcircles(im,[8 80],'ObjectPolarity','dark', ... 
            'Sensitivity',0.818,'EdgeThreshold',0.07);

%         imshow(im)
%         title("Image "+ n + " ");
        
      %  h = viscircles(centers,radius);
        
        pic= [01 02 03 04 05 06 07 08 09 10 11 12 13 14];
        im = rgb2gray(im);

       %r figure;
        for m = 1: length(radius)
          %  disp("On traite le cercle "+m+"");
            maLignetrouve = [];
            try
                im2=im( floor(centers(m,2)-radius(m,1)):floor(centers(m,2)+radius(m,1)),floor(centers(m,1)-radius(m,1)):floor(centers(m,1)+radius(m,1)));

                
              %  disp(abs(centers(m,2)*resizeFactor-radius(m,1)*resizeFactor));
              %  disp(abs(centers(m,1)*resizeFactor-radius(m,1)*resizeFactor));
                
                %im3=imo( abs(centers(m,2)*resizeFactor-radius(m,1)*resizeFactor):abs(centers(m,2)*resizeFactor+radius(m,1)*resizeFactor),abs(centers(m,1)*resizeFactor-radius(m,1)*resizeFactor):abs(centers(m,1)*resizeFactor+radius(m,1)*resizeFactor));
                im3 = imcrop(imo,[floor(centers(m,1)*resizeFactor-radius(m,1)*resizeFactor) floor(centers(m,2)*resizeFactor-radius(m,1)*resizeFactor) radius(m,1)*resizeFactor*2   radius(m,1)*resizeFactor*2]);
                
              %  figure;
              %  imshow(im3);
              %  title("Image cropper");
            catch ME
                break;
            end
            
           %r imshow(im2);
            level = graythresh(im2);
            BW = imbinarize(im2,level);
            
            coefficientdesmilitudecombiner=[];  % ici on ajoutera simitude et correlation
            matricedesimilitude = [];
            matricecorrelation =[];
            
            for elem = pic
                %disp("On traite la ligne de metro "+elem+"");
                impan= [];
                if elem<10
                    impan = imread(sprintf('PICTO/0%d.png',elem));
                    
                    [centerspan,radiuspan] = imfindcircles(impan,[20 120],'ObjectPolarity','dark', ... 
                    'Sensitivity',0.92,'EdgeThreshold',0.082); 
                    impan2 = imcrop(impan,[floor(centerspan(1,1)-radiuspan(1,1)) floor(centerspan(1,2)-radiuspan(1,1)) radiuspan(1,1)*2 radiuspan(1,1)*2]);
                    %figure;
                    %imshow(impan2);
                    %title("impan2");
                    %disp(size(impan2));
                    
                    impan=impan(floor(centerspan(1,2)-radiuspan(1)):floor(centerspan(1,2)+radiuspan(1)),floor(centerspan(1,1)-radiuspan(1)):floor(centerspan(1,1)+radiuspan(1)));
                    
                    %impan=rgb2gray(impan);
                    %figure ;
                    %imshow(impan);
                    
                    level = graythresh(impan);
                    if elem==6 
                       level=level-0.4; 
                    end    
                    BWpan = double(imbinarize(impan,level));
                    
                   
                else
                    impan = imread(sprintf('PICTO/%d.png',elem));
                    [centerspan,radiuspan] = imfindcircles(impan,[20 120],'ObjectPolarity','dark', ... 
                    'Sensitivity',0.92,'EdgeThreshold',0.082); 
                    impan2 = imcrop(impan,[floor(centerspan(1,1)-radiuspan(1,1)) floor(centerspan(1,2)-radiuspan(1,1)) radiuspan(1,1)*2   radius(1,1)*2]);
                    impan=impan(floor(centerspan(1,2)-radiuspan(1)):floor(centerspan(1,2)+radiuspan(1)),floor(centerspan(1,1)-radiuspan(1)):floor(centerspan(1,1)+radiuspan(1)));
                   % impan=rgb2gray(impan);
                   
                    level = graythresh(impan);
                    if elem==13
                       level=level-0.4;  
                    end    
                    BWpan = double(imbinarize(impan,level));
                    
                end
                [ROWS, COLS, map]=size(impan2);
                %disp(ROWS);
                %disp(COLS);
                im3 = imresize(im3, [ROWS COLS]);
                 
                %figure;
                %imshow(im2);
                %figure;
                %imshow(impan);
                BW = double(imresize(BW,size(BWpan)));
               %r imshowpair(BW,BWpan,'montage');
              %r  title("On compare image recuperer du metro et celle des ligne de metro BDD (iteration ligne par ligne)");
                [ssimval, ssimmap]  = ssim(BW, BWpan);
                matricedesimilitude= [matricedesimilitude;ssimval];
             %r   imshow(ssimmap,[]);
             %r   title(['Local SSIM Map with Global SSIM Value: ',num2str(ssimval)]);
                
                c1 = corr2(impan2(:,:,1),im3(:,:,1));
                c2 = corr2(impan2(:,:,2),im3(:,:,2));
                c3 = corr2(impan2(:,:,3),im3(:,:,3));
                [max_c1, imax] = max(abs(c1(:)));
                [max_c2, imax] = max(abs(c2(:)));
                [max_c3, imax] = max(abs(c3(:)));
                %disp("La correlation pour cette image et la ligne de metro")
               
                
                corr = max_c1 + max_c2 + max_c3;
                
                matricecorrelation= [matricecorrelation ; corr];
                                        
            end
            coefficientdesmilitudecombiner= matricecorrelation + matricedesimilitude;
            
            
            [maxssimval,indexssimval]= max(coefficientdesmilitudecombiner);
            
            disp("la valeur max pour cette image est : "+maxssimval+ "pour la ligne   "+ indexssimval+ " ");
            
            if maxssimval> 3
                    
                    maLignetrouve = [n floor(resizeFactor*centers(m,2)-resizeFactor*radius(m)) floor(resizeFactor*centers(m,2)+resizeFactor*radius(m)) floor(resizeFactor*centers(m,1)-resizeFactor*radius(m)) floor(resizeFactor*centers(m,1)+resizeFactor*radius(m)) indexssimval];
                    BD = [BD;maLignetrouve];
                    disp("Nous avons trouver un match avce la ligne de metro"+ indexssimval+" ");
                   
            end

        end    

    end
%Sauvegarde dans un fichier .mat des résulatts

   fileOut  = ('myResults.mat');
   save(fileOut,'BD');  
end

