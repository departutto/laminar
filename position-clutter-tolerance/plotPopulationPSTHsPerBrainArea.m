function plotPopulationPSTHsPerBrainArea

    % V1.
    r430V1    = selectMUASitesAndProduceAveragePSTH(68430, 1);
    r474V1    = selectMUASitesAndProduceAveragePSTH(68474, 1);
    r481V1    = selectMUASitesAndProduceAveragePSTH(68481, 1);
    r547V1    = selectMUASitesAndProduceAveragePSTH(68547, 1);

    % LI.
    r520LI    = selectMUASitesAndProduceAveragePSTH(68520, 2);
    r481LI    = selectMUASitesAndProduceAveragePSTH(68481, 2);
    r547LI    = selectMUASitesAndProduceAveragePSTH(68547, 2);
    
    singleV1  = (mean(r430V1{1}) + mean(r474V1{1}) + mean(r481V1{1}) + mean(r547V1{1})) / 4;
    twoDiffV1 = (mean(r430V1{2}) + mean(r474V1{2}) + mean(r481V1{2}) + mean(r547V1{2})) / 4;
    twoIdenV1 = (mean(r430V1{3}) + mean(r474V1{3}) + mean(r481V1{3}) + mean(r547V1{3})) / 4;
    
    singleLI  = (mean(r520LI{1}) + mean(r481LI{1}) + mean(r547LI{1})) / 3;
    twoDiffLI = (mean(r520LI{2}) + mean(r481LI{2}) + mean(r547LI{2})) / 3;
    twoIdenLI = (mean(r520LI{3}) + mean(r481LI{3}) + mean(r547LI{3})) / 3;
    
    showFigure(singleV1, twoDiffV1, twoIdenV1, 4);
    showFigure(singleLI, twoDiffLI, twoIdenLI, 3);
    
end

function showFigure(single, twoDiff, twoIden, nRats)

    thickness = 1.5;
    
    figure;
    plot(single,  '-r', 'LineWidth', thickness), hold on;
    plot(twoDiff, '-b', 'LineWidth', thickness);
    plot(twoIden, '-g', 'LineWidth', thickness);
    legend('Single', 'Two different', 'Two identical', 'Location', 'NorthEast');
    xlabel('time, ms'), ylabel('normalized firing rate');
    title(['N(rats) = ' mat2str(nRats)]);
    
    ylim([-0.5 3.5]), set(gca, 'YTick', -0.5:0.5:3.5), yrange = get(gca, 'YLim');
    
    xlim([1 91]), set(gca, 'XTick', [1 31 61 91]), set(gca, 'XTickLabel', [-300 0 300 600]);
    plot([31 31], yrange, '--k');
    plot([61 61], yrange, '--k');
    
    % Baseline of [-95; 5) ms relative to stimulus onset.
    plot([21.5 31.5], [yrange(1) yrange(1)], '-k', 'LineWidth', thickness);
    % Time window of [25; 175) ms relative to stimulus onset.
    plot([33.5 48.5], [yrange(1) yrange(1)], '-m', 'LineWidth', thickness);
    % Time window of [175; 325) ms relative to stimulus onset.
    plot([48.5 63.5], [yrange(1) yrange(1)], '-c', 'LineWidth', thickness);

end
