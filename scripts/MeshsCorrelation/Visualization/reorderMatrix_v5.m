% Written by: Erick Cobos T. (erick.cobos@epfl.ch)
% Date: 09-04-2014

% Reorders rows and columns of a matrix  as follows:
% Orders rows from biggest to smallest based on their weight (a sum over all rows of the column)
% Once rows are set, reorders columns in the same fahion
% The matrix received will normally be MeshIDs X Topics, and use the first row and first column for Meshids and topic numbers.
% Returns the new reordered matrix, the numberOfRows and numberOfColumns (counting the first row and first column that are for bookeeping)

function [ans , numberOfRows, numberOfColumns]  = reorderMatrix_v5(matrix)
	ans = reorderRows(matrix);
	ans = reorderRows(ans')';
	numberOfRows = size(ans)(1);
	numberOfColumns = size(ans)(2);
end

function ans = reorderRows(matrix)
	ans = matrix;

	% Set rows
	rowWeights = [Inf; sum(ans(2:end, 2:end),2) ];
	[x, newOrder] = sort(rowWeights, 'descend');
	ans = ans(newOrder,:);
	numberOfRows = size(ans)(1);

end
