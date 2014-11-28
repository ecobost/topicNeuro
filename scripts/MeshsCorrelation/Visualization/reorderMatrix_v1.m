% Written by: Jean Cedric Chappelier
% Modified by: Erick Cobos T. (erick.cobos@epfl.ch)
% Date: 20-05-2014

% Reorders rows and columns of a matrix so as to maximize its diagonal. ans(1,1) will be the biggest value in the entire matrix,...
% ans(2,2) will be the biggest value of the rest of the matrix (after setting the first column and row) and so on.
% The matrix received will normally be MeshIDs X Topics, and use the first row and first column for Meshids and topic numbers.
% Returns the new reordered matrix, the numberOfRows and numberOfColumns (counting the first row and first column that are for bookeeping)

function [ans , numberOfRows, numberOfColumns]  = reorderMatrix_v1(matrix)

	% Select the minimum dimension of the matrix, normally the number of topics.
	minDimension = min(size(matrix));

	% Reorder the first part of the matrix. Set first minDimension columns and rows
	ans = matrix;
	numberOfRows = 1;
	numberOfColumns = 1;
	for i = 2:minDimension% Starts in 2 to avoid the 'titles' row and column
		restOfMatrix = ans(i:end,i:end);

		% Best next value
		value = max(restOfMatrix(:));
		if value > 0
			% Find indices of best value
			[maxRowIndex, maxColIndex] = find(restOfMatrix==value);

			% Swap it with the row i in the matrix ans 
			rowIndex = maxRowIndex(1) + i -1;
			ans([i, rowIndex], :) = ans([rowIndex, i] , :); 

			% Swap it in the matrix ans
			colIndex = maxColIndex(1) + i -1;
			ans(:,[i, colIndex]) = ans(:,[colIndex, i]);
	
			% Advance numberOfRows and numberOfColumns		
			numberOfRows = numberOfRows + 1;
			numberOfColumns = numberOfColumns + 1;
		else
			break;
		end
	end

	% After the square matrix (with maximized diagonal) is set, order the rest of rows
	% Reorder such as to find the maximum diagonal (as above)
	[M N] = size(ans);
	maxRowToSet = min(M, numberOfRows + min(numberOfColumns, N-1)); % Looks weird. But it works. 
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


