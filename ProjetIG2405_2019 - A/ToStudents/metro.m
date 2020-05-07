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


% Sélectionner les images en fonction de la base de données, apprentissage ou test

n = 1:261;
ok = 1;
if strcmp(type,'Test')
    numImages  = n(find(mod(n,3)));
elseif strcmp(type,'Learn')
    numImages  = n(find(~mod(n,3)));
else
    ok = 0;
    uiwait(errordlg('Bad identifier (should be ''Learn'' or ''Test'' ','ERRORDLG'));
end


if ok
    % Definir le facteur de redimensionnement
resizeFactor = 2.2;
    
    % Programme de reconnaissance des images
    for n = numImages   % n= numéro de l'image%
        
       % On récupère l'image
        im = imread(sprintf('BD/IM (%d).jpg',n));
        
        %compresse le nb de pixel pour trouver les cercles 
        [rows, columns, numColorChannels] = size(im);
        numOutputRows = round(rows/resizeFactor);
        numOutputColumns = round(columns/resizeFactor);
        imgResize = imresize(im, [numOutputRows, numOutputColumns]);
        
        %segmentation -- trouver les cercles avec imfindcircles --%
       [centers,radius] = imfindcircles(imgResize,[8 80],'ObjectPolarity','dark', ... 
            'Sensitivity',0.855,'EdgeThreshold',0.1);
        
        imshow(imgResize)
        title("Image "+ n + " ");
        h = viscircles(centers,radius);
        pause(1);
        
    end
    
    % Sauvegarde dans un fichier .mat des résulatts
    fileOut  = 'myResuts.mat';
    save(fileOut,'BD');
    
end