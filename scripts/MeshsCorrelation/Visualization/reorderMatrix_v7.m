% Written by: Erick Cobos T. (erick.cobos@epfl.ch)
% Date: 24-05-2014

% Reorders rows and columns of a matrix using the euclidean distance of the points in the mutidimensional space.
% Rows are reordered first. The row closest to the 0 vector is placed first, later the closest row is placed next to it
% Later the closest row to row 2 is placed next to it and so on. The matrix is constructed from bottom up, so that the
% smallest values(rows closer to 0) rest at the bottom.
% Columns are now reordered in a similar fashion.

% Complexity roughly O(m^2*n) where m = number of rows and n = number of cols. Summary: It's slow.

function [ans , numberOfRows, numberOfColumns]  = reorderMatrix_v7(matrix)
	% Get the first highest value 2000 rows in the matrix.
	ans = reorderRowsByValue(matrix)(1:min(2001,end),:);

	% Reorder rows
	ans = reorderRows(ans);
	
	% Reorder columns
	ans = reorderRows(ans')';

	numberOfRows = size(ans)(1);
	numberOfColumns = size(ans)(2);
end
	

function ans = reorderRows(matrix)
	% Remove the labels row
	labels = matrix(1,:);
	matrix(1,:) = [];

	% Set first row in the ans matrix.
	[minValue, minRowIndex] = min(sum(matrix(:,2:end),2));
	ans = matrix(minRowIndex,:);
	matrix(minRowIndex,:) = [];

	rowsToBeReordered = size(matrix)(1);
	for i = 1:rowsToBeReordered % Each row that needs to be added to ans
		bestRowIndex = -1;
		bestDistance = Inf;

		% Find best row of the remaining rows
		topRow = ans(1,2:end);
		[M N] = size(matrix); 
		for j = 1:M
			distanceTop = norm(matrix(j,2:N) - topRow);%Distance to the last row set		
			if distanceTop < bestDistance
				bestDistance = distanceTop;
				bestRowIndex = j;
			end
		end

		% Add the best row to ans
		ans = [matrix(bestRowIndex,:); ans];

		% Remove best row from matrix
		matrix(bestRowIndex,:) = [];
	end

	% Set label row in ans
	ans = [labels; ans];
end

function ans = reorderRowsByValue(matrix)
	ans = matrix;

	% Set rows
	rowWeights = [Inf; sum(ans(2:end, 2:end),2) ];
	[x, newOrder] = sort(rowWeights, 'descend');
	ans = ans(newOrder,:);
	numberOfRows = size(ans)(1);

end
