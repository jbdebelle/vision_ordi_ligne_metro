%% ************************************************************************
%% 
%% EVALUATION DES PERFORMANCES :
%%
% Inputs:
%      BDREF   : base de référence, i.e. vérité terrain sauvegardée dans un
%                fichier .mat. Entrer le nom (string) du fichier 
%
%      BDTEST  : résultats du programme. Entrer le nom du fichier qui
%                stocke ces résultats.
%
%      resizeFactor    : f si les les images sources ont été
%                        redimensionnées d'un facteur 1/f lors des
%                        traitements
%
%          NB : les fichiers .mat doivent contenir une matrice de N lignes
%               et de 6 colonnes. Chaque ligne correspond à un symbole. Les 
%               6 colonnes sont: le numéro d'image, la boite englobante et
%               la classification du symbole :
%               <numero fichier> <i1> <i2> <j1> <j2> <c>
% 
% Calcule : la matrice de confusion, les taux de reconnaissance,
% le pourcentage de symboles ajoutés pour chaque classe, le pourcentage
% de symboles manquants pour chaque classe.
%
%% ************************************************************************


function evaluation (BDREF, BDTEST,resizeFactor)

% Charger les bases de données
load(BDREF);
BDREF = BD ;

load (BDTEST)
BDTEST = BD;

% Ajuster les dimensions en fonction de la résolution des images traitées
BDTEST(:,2:5) = resizeFactor * BDTEST(:,2:5);

% Calculer les centroids (I,J) des panneaux dans la base de référence,
% la taille moyenne D des panneaux et la marge d'erreur permise comme
% pourcentage de D;

I           = sum(BDREF(:,2:3),2)/2;
J           = sum(BDREF(:,4:5),2)/2;
D           = round((BDREF(:,3) - BDREF(:,2) + BDREF(:,5) - BDREF(:,4))/2); 
maxDecPer   = 0.1;      % le décalage des centroides doit être inférieur à maxDec * D


% Initialiser les variables pour l'évaluation
confusionMatrix = zeros(14,14);             % Matrice de confusion
plusVector      = zeros(1,14);              % Symboles en plus
minusVector     = zeros(1,14);              % Symboles en moins

processed       = zeros(1,size(BDREF,1));  % Lister les symboles trouvés



% Parcourir tous les symboles reconnues, rechercher le symbole
% correspondant dans la base de référence et 

for k = 1:size(BDTEST,1)
    
    % Rechercher les symboles de l'image traitée
    n   = BDTEST(k,1);                      % Image
    ind = find(BDREF(:,1) == n);
    
    disp(sprintf('%5d -- IMAGE TESTEE = %3d - Classe  = %2d',k,n, BDTEST(k,6)));
    % Rechercher le plus proche et vérifier que les positions sont
    % compatibles
    i   = mean(BDTEST(k,2:3));      % centroid du panneau testé
    j   = mean(BDTEST(k,4:5));
    
    d           = sqrt((I(ind)-i).^2 + (J(ind)-j).^2);
    [mind,p]    = min(d);
    kref       = ind(p);
    
    if mind <= maxDecPer * D(kref)                              % Mise en correspondance du symbole testé avec le symbole ind(p)
        confusionMatrix(BDREF(kref,6),BDTEST(k,6)) = confusionMatrix(BDREF(kref,6),BDTEST(k,6)) + 1;
        % Indiquer que ce symbole a été trouvé dans la base de test
        processed(kref) = 1;
    else
        plusVector(BDTEST(k,6)) =  plusVector(BDTEST(k,6)) + 1 ;     % C'est un symbole qui n'a pas d'équivalent dans la base de référence
    end
    
end

% Déterminer tous les symboles de référence qui n'ont pas été trouvés dans
% la base de test: ce sont les symboles en moins
ind  = find(processed == 0);
for p = 1:length(ind)
    minusVector(BDTEST(ind(p),6))   = minusVector(BDTEST(ind(p),6)) + 1;
end


%% AFFICHER LES RESULTATS
disp(sprintf('\n\n'))
disp '---------------'

% Matrice de confusion
disp 'Confusion matrix ....'
disp ' '
for k = 1:14
    disp(sprintf('%3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d  : %3d : + %3d : - %3d :', ...
        confusionMatrix(k,1),confusionMatrix(k,2),confusionMatrix(k,3),confusionMatrix(k,4),confusionMatrix(k,5),...
        confusionMatrix(k,6),confusionMatrix(k,7),confusionMatrix(k,8),confusionMatrix(k,9),confusionMatrix(k,10),...
        confusionMatrix(k,11),confusionMatrix(k,12),confusionMatrix(k,13),confusionMatrix(k,14), ...
        sum(confusionMatrix(k,:)),plusVector(k), minusVector(k)  ));
end
  
disp(sprintf('... ... ... ... ... ... ... ... ... ... ... ... ... ...')) 
disp(sprintf('%3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d', ...
       sum(confusionMatrix(:,1)),sum(confusionMatrix(:,2)),sum(confusionMatrix(:,3)),sum(confusionMatrix(:,4)),sum(confusionMatrix(:,5)),...
       sum(confusionMatrix(:,6)),sum(confusionMatrix(:,7)),sum(confusionMatrix(:,9)),sum(confusionMatrix(:,9)),sum(confusionMatrix(:,10)),...
       sum(confusionMatrix(:,11)),sum(confusionMatrix(:,12)),sum(confusionMatrix(:,13)),sum(confusionMatrix(:,14)) ));
    
disp(sprintf('\n\n ---------------'))
disp 'Taux de reconnaissance'
reconnus = 0;
for k = 1:14
    disp(sprintf('%2d : %4.2f %%  - Ajouts : %4.2f %%',k,  confusionMatrix(k,k) / (sum(confusionMatrix(k,:)) +  minusVector(k) ) * 100,  plusVector(k) / (sum(confusionMatrix(k,:)) +  minusVector(k) ) * 100));
    reconnus = reconnus + confusionMatrix(k,k) ;
end
disp '---------------'
disp(sprintf ('Taux de reconnaissance global = %4.2f %%', reconnus / (sum(confusionMatrix(:))+ sum(minusVector))*100));
disp ' '
disp(sprintf ('Taux de symboles en plus = %4.2f %%', sum(plusVector) / (sum(confusionMatrix(:))+ sum(minusVector))*100));
disp '---------------'
