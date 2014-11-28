% Written by: Erick Cobos T. (erick.cobos@epfl.ch)
% Date: 29-02-2014

% Reorders rows and columns of a matrix so that the k-th biggest value of the matrix is (at least) inside the k-sized box in the left upper corner
% Thus, the biggest values are pushed upwards and to the side, generating a matrix with high values closer to teh top left corner and to the diagonal.
% ans(2,2) will be the biggest value of the rest of the matrix (after setting the first column and row) and succesively.
% The matrix received will normally be MeshIDs X Topics, and use the first row and first column for Meshids and topic numbers.
% Returns the new reordered matrix, the numberOfRows and numberOfColumns (counting the first row and first column that are for bookeeping)

function [ans , numberOfRows, numberOfColumns]  = reorderMatrix_v2(matrix)

	% Selects the best value in the entire matrix and assigns ans(1,1) = the best value (swaps the rows and the columns)
	% Then look for the second biggest value, if it is in a row or column already assigned it gets pushed towards the upper left corner
	% if the second highest value is not in a row or corner already set, it is put in the next row and column free to set.
	% Once a row or columns is assigned it cannot be moved

	[M,N] = size(matrix); % Dimensions
	ans = matrix; % Answer matrix (to be reordered)
	nextToSetRow = 2; % Next row to be set. Starts in 2 to avoid the 'titles' row and column
	nextToSetCol = 2; % Next column to be set
	bestColValue = -1; % Best value on the columns already set (rows unset).
	bestRowValue = -1; % Best value on the rows already set (cols unset).
	bestNewValue = -1; % Best value on the new part of the matrix(unset cols and rows)

	% Set the first row and column. This repeats some code but will make it easy to write the code inside the while loop
	[value , maxColIndex] = max( max(ans(nextToSetRow:end,nextToSetCol:end), [], 1) );
	colIndex = nextToSetCol + maxColIndex - 1;
	[value , maxRowIndex] = max(ans(nextToSetRow:end, colIndex));
	rowIndex = nextToSetRow + maxRowIndex - 1;

	ans([nextToSetRow, rowIndex], :) = ans([rowIndex, nextToSetRow], :);
	ans(:, [nextToSetCol, colIndex]) = ans(:, [colIndex, nextToSetCol]);
	nextToSetRow = nextToSetRow + 1;	
	nextToSetCol = nextToSetCol + 1;	

	while nextToSetRow <= M && nextToSetCol <= N  % Stop when we run out of columns or rows to assignx (typically the number of topics)

		% Calculate new best values
		bestRowValue = max( max(ans(2:nextToSetRow-1, nextToSetCol:end)) );
		bestColValue = max( max(ans(nextToSetRow:end, 2:nextToSetCol-1)) );
		bestNewValue = max( max(ans(nextToSetRow:end, nextToSetCol:end)) );

		% Choose in which region does the next value lie
		[value, rowColOrNew] = max( [ bestRowValue bestColValue bestNewValue] );
	
		% Calculate best value indices, swap it accordingly and update nextToSetCol and nextToSetRow
		if rowColOrNew == 1 % Best value in an already set row
			[value , maxColIndex] = max( max(ans(2:nextToSetRow-1,nextToSetCol:end), [], 1) );
			colIndex = nextToSetCol + maxColIndex - 1;

			ans(:,[nextToSetCol, colIndex]) = ans(:, [colIndex, nextToSetCol]);
			nextToSetCol = nextToSetCol + 1;
		end
		if rowColOrNew == 2 % Best value in already set column
			[value , maxRowIndex] = max( max(ans(nextToSetRow:end, 2:nextToSetCol-1), [], 2) );
			rowIndex = nextToSetRow + maxRowIndex - 1;

			ans([nextToSetRow, rowIndex], :) = ans([rowIndex, nextToSetRow], :);
			nextToSetRow = nextToSetRow + 1;	
		end
		if rowColOrNew == 3 % Best value in a new position (unset cols and rows)
			[value , maxColIndex] = max( max(ans(nextToSetRow:end,nextToSetCol:end), [], 1) );
			colIndex = nextToSetCol + maxColIndex - 1;
			[value , maxRowIndex] = max(ans(nextToSetRow:end, colIndex));
			rowIndex = nextToSetRow + maxRowIndex - 1;

			ans([nextToSetRow, rowIndex], :) = ans([rowIndex, nextToSetRow], :);
			ans(:,[nextToSetCol, colIndex]) = ans(:, [colIndex, nextToSetCol]);
			nextToSetRow = nextToSetRow + 1;	
			nextToSetCol = nextToSetCol + 1;		
		end
	end

	% Assign number of rows and number of columns to the rows and columns set.
	numberOfRows = nextToSetRow - 1;
	numberOfColumns = nextToSetCol -1;
end
