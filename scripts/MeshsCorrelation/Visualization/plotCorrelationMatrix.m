% Written by: Erick Cobos T. (erick.cobos@epfl.ch)
% Date: 20-03-2014

% Plots a correlation matrix. Next to its p(m) and p(z)

% Assign the color for all our plots. 
colormap( flipud( colormap('gray') ) ); % Grayscale. Black is highest value, white is low value

% Set parameters
inputFile = 'results/descriptorMatrix_MD.tsv';
outputStem = 'plots_v1/descriptorMatrix_MD';
graphTitle = 'Correlation matrix MD';
typeOfID = 'MeSH Descriptors';
padding = 4;
maxRowsToPrint = 401;

% Read unordered matrix
matrix = dlmread(inputFile,'\t');
[M,N] = size(matrix);

% Reorder matrix
[matrix, numberOfRows, numberOfColumns] = reorderMatrix_v1(matrix);
% Get the resulting matrix and pad it with zeros
paddedMatrix = matrix(2:min(numberOfRows, maxRowsToPrint), 2:numberOfColumns);
paddedMatrix = [zeros( size(paddedMatrix)(1), padding) paddedMatrix zeros(size(paddedMatrix)(1), padding)];
paddedMatrix = [zeros(padding, size(paddedMatrix)(2)); paddedMatrix; zeros(padding, size(paddedMatrix)(2))];

%Plot matrix
image(paddedMatrix);
title(graphTitle);
xlabel('Topics');
ylabel(typeOfID);
axis equal;
set(gcf, 'PaperSize', [size(paddedMatrix)]);
print(strcat(outputStem,'.eps'), '-depsc');
set(gcf, 'PaperType', 'usletter'); % Back to default

% Plot probabilities
sumC = sum(matrix(2:end,2:end));
totalProb = sum(sumC);
plot(sumC./totalProb);
xlabel('Topics');
ylabel('Probability');
print(strcat(outputStem,'.pz','.eps'), '-depsc');

sumR = sum(matrix(2:maxRowsToPrint,2:end),2);
plot(sumR./totalProb)
xlabel(typeOfID);
ylabel('Probability');
print(strcat(outputStem,'.pm','.eps'), '-depsc');

%Save new matrix to file (as .tsv)
%dlmwrite('reorderedMatrix_MD.tsv',c3,'\t');
