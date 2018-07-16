function cbfun(pdata,basePortfolioValue)
% Function for updating the graphs. Used automatically by cloudfor.
% global counter upinter

% Copyright 2017 Verhoog Consultancy
% Copyright 2017 Techila Technologies Ltd.

portfolioValue = pdata(find(pdata));
subplot(2,1,1), histfit(100*(portfolioValue/basePortfolioValue-1),100,'kernel');
title('Profit & Loss Distribution')
subplot(2,1,2), histfit(100*(portfolioValue/basePortfolioValue-1),100,'kernel');
title('Profit and Loss Distribution 0.1-1% percentile')
xlim([quantile(100*(portfolioValue/basePortfolioValue-1),0.001) quantile(100*(portfolioValue/basePortfolioValue-1),0.01)])

end