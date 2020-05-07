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


% S�lectionner les images en fonction de la base de donn�es, apprentissage ou test

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
    for n = numImages   % n= num�ro de l'image%
        
       % On r�cup�re l'image
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
    
    % Sauvegarde dans un fichier .mat des r�sulatts
    fileOut  = 'myResuts.mat';
    save(fileOut,'BD');
    
end