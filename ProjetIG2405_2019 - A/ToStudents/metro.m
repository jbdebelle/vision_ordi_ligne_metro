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

% Ici, nous allons cree un cell contenant les 14 images correspondant au
% differentes version des symboles de lignes de metro que nous avons besoin 
% pour notre algorithme

matimpan2= {}; % cell contenant les 14 symboles de metro en format RGB redimensioner 
               %  de maniere a retirer les contours superflus sur les symboles de
               %  meme facon que sur les cercles trouver sur l'image
matBWpan= {}; % cell contenant les 14 symboles de metro en format binaire 
pic= [01 02 03 04 05 06 07 08 09 10 11 12 13 14];
for elem = pic
    if elem<10  % pour recuperer images de 1 a 10 dans la BDD 
        impan = imread(sprintf('PICTO/0%d.png',elem)); % Nous avons du separer les chiffres inferieur a 10
                                                       % a cause du format de nomage dans la BDD
        [centerspan,radiuspan] = imfindcircles(impan,[20 120],'ObjectPolarity','dark', ... 
        'Sensitivity',0.92,'EdgeThreshold',0.082); 
        % on enleve les contours superflus afin d'avoir le meme format que
        % les cercles recuperer dans l'image
        impan2 = imcrop(impan,[floor(centerspan(1,1)-radiuspan(1,1)) floor(centerspan(1,2)-radiuspan(1,1)) radiuspan(1,1)*2 radiuspan(1,1)*2]);
        matimpan2=[matimpan2;impan2 ]; % on ajoute le nouveaux symbole de metro a la cell
        impan=impan(floor(centerspan(1,2)-radiuspan(1)):floor(centerspan(1,2)+radiuspan(1)),floor(centerspan(1,1)-radiuspan(1)):floor(centerspan(1,1)+radiuspan(1)));
        matimpan=[matimpan;impan ];
        
        % passage des images en format binaire
        level = graythresh(impan);
        if elem==6  % POur l'image 6, le threshold fait que le symbole binaire est tout noire car la couleur
                    % en background est proche du noir du chiffre donc on
                    % diminue le threshold
           level=level-0.4; 
        end    
        BWpan = double(imbinarize(impan,level));  % ici on passe l'image en format binaire en utilisant le level trouver
        matBWpan=[matBWpan;BWpan ]; % on ajoute le nouveaux symbole de metro binaire a la cell contenant les symboles en format binaire
    else  % ici on fait le meme traitement mais pour les images allant de 10 a 14
        impan = imread(sprintf('PICTO/%d.png',elem));
        [centerspan,radiuspan] = imfindcircles(impan,[20 120],'ObjectPolarity','dark', ... 
        'Sensitivity',0.92,'EdgeThreshold',0.082); 
        impan2 = imcrop(impan,[floor(centerspan(1,1)-radiuspan(1,1)) floor(centerspan(1,2)-radiuspan(1,1)) radiuspan(1,1)*2   radiuspan(1,1)*2]);
        matimpan2=[matimpan2;impan2 ];
        impan=impan(floor(centerspan(1,2)-radiuspan(1)):floor(centerspan(1,2)+radiuspan(1)),floor(centerspan(1,1)-radiuspan(1)):floor(centerspan(1,1)+radiuspan(1)));
        matimpan=[matimpan;impan ];

        level = graythresh(impan);
        if elem==13
           level=level-0.4;  
        end    
        BWpan = double(imbinarize(impan,level));
        matBWpan=[matBWpan;BWpan ];
    end
end
    
    resizeFactor = 2;
    BD= [];
    % Programme de reconnaissance des images
    for n = numImages
       % On récupère l'image
        disp("On traite image "+n+"");
        imo = imread(sprintf('BD/IM (%d).jpg',n));
        
        %compresse le nb de pixel pour trouver les cercles plus rapidement 
        [rows, columns, numColorChannels] = size(imo);
        numOutputRows = round(rows/resizeFactor);
        numOutputColumns = round(columns/resizeFactor);
        im = imresize(imo, [numOutputRows, numOutputColumns]);

        %segmentation -- trouver les cercles avec imfindcircles --%
       [centers,radius] = imfindcircles(im,[11 80],'ObjectPolarity','dark', ... 
            'Sensitivity',0.818,'EdgeThreshold',0.07);
        pic= [01 02 03 04 05 06 07 08 09 10 11 12 13 14];
        im = rgb2gray(im);
        
        for m = 1: length(radius)
            maLignetrouve = [];
            try
              im2=im( floor(centers(m,2)-radius(m,1)):floor(centers(m,2)+radius(m,1)),floor(centers(m,1)-radius(m,1)):floor(centers(m,1)+radius(m,1)));  
              im3 = imcrop(imo,[floor(centers(m,1)*resizeFactor-radius(m,1)*resizeFactor) floor(centers(m,2)*resizeFactor-radius(m,1)*resizeFactor) radius(m,1)*resizeFactor*2   radius(m,1)*resizeFactor*2]);
            catch ME
                break;
            end
            level = graythresh(im2);
            BW = imbinarize(im2,level);
            
            coefficientdesmilitudecombiner=[];  % ici on ajoutera simitude et correlation
            matricedesimilitude = [];
            matricecorrelation =[];
            
            for elem = pic
                %on recupere les images des symboles des lignes de metro 
                % pour les comparer avec le contenu du cercle
                impan2= matimpan2{elem};
                BWpan = matBWpan{elem};
                    
                
                [ROWS, COLS, map]=size(impan2);
                im3 = imresize(im3, [ROWS COLS]);
                BW = double(imresize(BW,size(BWpan)));
                % On calcule la simmilitude entre l'image pris dans du
                % cercle et l'image de la base de donnée des lignes
                [ssimval, ssimmap]  = ssim(BW, BWpan);
                matricedesimilitude= [matricedesimilitude;ssimval];
                
                %Ici on calcule la corrélation sur chaque couleur entre ces images pour avoir
                %un résultat plus robuste
                c1 = corr2(impan2(:,:,1),im3(:,:,1));
                c2 = corr2(impan2(:,:,2),im3(:,:,2));
                c3 = corr2(impan2(:,:,3),im3(:,:,3));
                [max_c1, imax] = max(abs(c1(:)));
                [max_c2, imax] = max(abs(c2(:)));
                [max_c3, imax] = max(abs(c3(:)));
                
               
                %On fait la somme des trois coefficients max 
                corr = max_c1 + max_c2 + max_c3;
                matricecorrelation= [matricecorrelation ; corr];
                                        
            end
            %On additionne le résultat des deux méthodes pour avoir un meilleur résultat
            coefficientdesmilitudecombiner= matricecorrelation + matricedesimilitude;
            % On prend le max pour être sur d'avoir la bonne ligne de métro
            [maxssimval,indexssimval]= max(coefficientdesmilitudecombiner);
            disp("la valeur max pour cette image est : "+maxssimval+ " pour la ligne "+ indexssimval+ " ");
            
            if maxssimval> 2.3
                    %On créer la ligne avec les résultat pour ensuite
                    %l'ajouter dans la matrice BD
                    maLignetrouve = [n floor(resizeFactor*centers(m,2)-resizeFactor*radius(m)) floor(resizeFactor*centers(m,2)+resizeFactor*radius(m)) floor(resizeFactor*centers(m,1)-resizeFactor*radius(m)) floor(resizeFactor*centers(m,1)+resizeFactor*radius(m)) indexssimval];
                    BD = [BD;maLignetrouve];
                    disp("Nous avons trouver un match avce la ligne de metro "+ indexssimval+" ");
                   
            end

        end    

    end
%Sauvegarde des résultats dans le fichier myResults.mat 

   fileOut  = ('myResults.mat');
   save(fileOut,'BD');  
end
