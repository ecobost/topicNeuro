% Written by: Erick Cobos T. (erick.cobos@epfl.ch)
% Date: 09-04-2014

% Reorders rows and columns of a matrix  as follows:
% Orders columns from biggest to smallest based on the overall weight (a sum over all rows of the column)
% Once columns are set, reorders row so as to maximize the value on the diagonal.
% The matrix received will normally be MeshIDs X Topics, and use the first row and first column for Meshids and topic numbers.
% Returns the new reordered matrix, the numberOfRows and numberOfColumns (counting the first row and first column that are for bookeeping)

function [ans , numberOfRows, numberOfColumns]  = reorderMatrix_v4(matrix)
	
	ans = matrix;

	% Set columns
	columnWeights = [Inf sum(ans(2:end,2:end)) ];
	[x, newOrder] = sort(columnWeights, 'descend');
	ans = ans(:,newOrder);
	numberOfColumns = size(ans)(2);

	% Set rows on the already set columns. Reorder such as to find the maximum diagonal.
	numberOfRows = 1;
	[M N] = size(ans);
	for j = 1:2 % Do 2 cycles of reordering rows

		maxRowToSet = min(M, numberOfRows + numberOfColumns - 1); % Looks weird. But it works. 
		col = 2;
		for i = numberOfRows+1 : maxRowToSet % Starts in the next row to set and does another loop
		
			% Best next value in the col to set
			[value, maxRowIndex] = max(ans(i:end, col));

			if value > 0
				% Swap it with the row i in the matrix ans 
				rowIndex = maxRowIndex + i -1;
				ans([i, rowIndex], :) = ans([rowIndex, i] , :); 

				% Advance numberOfRows			
				numberOfRows = numberOfRows + 1;
				col =  col + 1;
			else
				break;
			end
		end
	end
end

