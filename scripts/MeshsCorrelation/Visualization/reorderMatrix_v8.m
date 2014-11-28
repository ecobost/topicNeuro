% Written by: Erick Cobos T. (erick.cobos@epfl.ch)
% Date: 24-05-2014

% Reorders rows and columns of a matrix using the euclidean distance of the points in the mutidimensional space.
% Rows are reordered first. The row that is closer to the 0 vector is placed first, later the closest row is placed next to it
% Later the closest row to either row_1 or row_2 is placed next to the row (1 or 2, respectively).
% This procces is repeated now only considering either row_1 and row_3(if row_3 was placed next to row_2) or 
% row_2 and row_3(if row_3 was placed next to row_1). So the graph grows from the middle out until all rows are set.
% Columns are now reordered in a similar fashion.

% Complexity roughly O(m^2*n) where m = number of rows and n = number of cols. Summary: It's very slow.

function [ans , numberOfRows, numberOfColumns]  = reorderMatrix_v8(matrix)
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

	% Set first row in the ans matrix
	[minValue, minRowIndex] = min(sum(matrix(:,2:end),2));
	ans = matrix(minRowIndex,:);
	matrix(minRowIndex,:) = [];
	

	% Start looking to both sides.
	rowsToBeReordered = size(matrix)(1);
	for i = 1:rowsToBeReordered % Each row that needs to be added to ans
		bestRowIndex = -1;
		bestDistance = inf;
		addAtTop = false;
		% Find best row of the remaining rows
		for j = 1: size(matrix)(1)
			distanceBottom = norm(matrix(j,2:end) - ans(end,2:end));%Distance to the bottom row			
			distanceTop = norm(matrix(j,2:end) - ans(1,2:end));%Distance to the top row 
			if distanceBottom < bestDistance
				bestDistance = distanceBottom;
				addAtTop =false;
				bestRowIndex = j;
			end			
			if distanceTop < bestDistance
				bestDistance = distanceTop;
				addAtTop = true;
				bestRowIndex = j;
			end
		end
		% Add the best row to ans
		if addAtTop == true
			ans = [matrix(bestRowIndex,:); ans];
		else
			ans = [ans; matrix(bestRowIndex,:)];
		end
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
