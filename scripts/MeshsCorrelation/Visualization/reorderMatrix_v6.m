% Written by: Erick Cobos T. (erick.cobos@epfl.ch)
% Date: 09-04-2014

% Reorders rows and columns of a matrix  as follows:
% Orders columns from biggest to smallest based on the overall weight (a sum over all rows of the column)
% Once columns are set, reorders rows lexycographically
% The matrix received will normally be MeshIDs X Topics, and use the first row and first column for Meshids and topic numbers.
% Returns the new reordered matrix, the numberOfRows and numberOfColumns (counting the first row and first column that are for bookeeping)

function [ans , numberOfRows, numberOfColumns]  = reorderMatrix_v6(matrix)
	ans = matrix;

	% Set columns
	columnWeights = [Inf sum(ans(2:end,2:end)) ];
	[x, newOrder] = sort(columnWeights, 'descend');
	ans = ans(:,newOrder);
	numberOfColumns = size(ans)(2);

	% Set rows
	[x, newOrder] = sort([Inf; ans(2:end,2)], 'descend');
	ans = ans(newOrder,:);
	numberOfRows = size(ans)(1);
end
