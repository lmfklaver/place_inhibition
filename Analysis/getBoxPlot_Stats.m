function [pvalues_matrix_ranksum, pvalues_matrix_signrank] = getBoxPlot_Stats(boxplot_matrix)
% PURPOSE
%          Find the stats for a given boxplot matrix using ranksum. Compare
%          each boxplot with the other to see if there is a significant
%          difference.
% INPUT
%          boxplot_matrix          Matrix: (#samplesInBoxplot V #boxplots)
% OUTPUT
%          pvalues_matrix_ranksum  Matrix: (#comparisons X 3)
%                                          first column will be the row index
%                                          of one boxplot to compare, the
%                                          second column will be the row index
%                                          of the second boxplot to compare,
%                                          the third column is the pvalue
%                                          between the medians.
%          pvalues_matrix_signrank Matrix: (# comparisons X 3) same as
%                                          above, expcept signrank calculates 
%                                          difference between each point
%                                          in the boxplot
% HISTORY
%         Reagan Bullins 06.24.2021
%%

% First calculate how many comparisons need to be made
    % Get the number of boxplots
        num_boxplots = size(boxplot_matrix, 2);
    % Find number of combinations for comparing 2 boxplots (order does not matter)
        [col_idx_combo] = nchoosek(1:num_boxplots,2);
    % Allocate for speed
        pvalues_matrix_ranksum = zeros(size(col_idx_combo,1),3);
        pvalues_matrix_signrank = zeros(size(col_idx_combo,1),3);
    % For each combination find the p-value
        for icombo = 1:size(col_idx_combo,1)
            [p,~,~] = ranksum(boxplot_matrix(:,col_idx_combo(icombo,1)), boxplot_matrix(:,col_idx_combo(icombo,2)));
            pvalues_matrix_ranksum(icombo,1) = col_idx_combo(icombo,1);
            pvalues_matrix_ranksum(icombo,2) = col_idx_combo(icombo,2);
            pvalues_matrix_ranksum(icombo,3) = p;
            
            [p2,~,~] = signrank(boxplot_matrix(:,col_idx_combo(icombo,1)), boxplot_matrix(:,col_idx_combo(icombo,2)));
            pvalues_matrix_signrank(icombo,1) = col_idx_combo(icombo,1);
            pvalues_matrix_signrank(icombo,2) = col_idx_combo(icombo,2);
            pvalues_matrix_signrank(icombo,3) = p2;
        end


end