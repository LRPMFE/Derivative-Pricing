function [price,CI] = asianoption(s0,r,sigma,K,T,N,paths,alpha)

dt=T/N;
s=zeros(paths,N+1);
s(:,1)=s0;  % s(i,j) stands for stock price at node (i,j)
randn('seed',0);
w=randn(paths,N);
y=zeros(paths,1);  % y(paths,1) stands for the payoff at time T

for j=2:N+1
    s(:,j)=s(:,j-1).*exp((r-0.5*sigma^2)*dt+sigma*sqrt(dt)*w(:,j-1));
end

y=max(mean(s(:,2:N+1),2)-K,0);
price=mean(y)*exp(-r*T);

% calculating confidence interval
CI=exp(-r*T)*[mean(y)-norminv(1-alpha/2)*std(y)/sqrt(paths),mean(y)+norminv(1-alpha/2)*std(y)/sqrt(paths)];

end
