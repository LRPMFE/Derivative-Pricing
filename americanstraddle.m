function [price,delta,B,exdate] = americanstraddle(s0,r,div,divdates,u,d,h,T,K)

% p stands for the risk neutral probability of stock price going up
p=(exp(r*h)-d)/(u-d);
q=1-p;

s=zeros(T+1,T+1);
s(1,1)=s0;

% ycall(j,i) and yput(j,i) stand for the payoff of a call and a put respectively at node(j,i)
ycall=zeros(T+1,T+1);
yput=zeros(T+1,T+1);
ndates=length(divdates);

for j = 2:T+1
    for i=1:j
     %split the divdates to different intervals to calculate stock price
     %after dividend paid
        if div==0 || j<divdates(1)+1     
            s(i,j)=s0*u^(j-i)*d^(i-1);
        elseif j<divdates(ndates)+1
            for g=2:ndates
                if j>=divdates(g-1)+1 && j<divdates(g)+1
                    s(i,j)=s0*u^(j-i)*d^(i-1)*(1-div)^(g-1);
                end
            end
        else
            s(i,j)=s0*u^(j-i)*d^(i-1)*(1-div)^(ndates);
        end
        ycall(i,j)=max(s(i,j)-K,0);
        yput(i,j)=max(K-s(i,j),0);
    end    
end

% price(i,j) stands for the option value at node(i,j)
price=zeros(T+1,T+1);
for k=1:T+1
    price(k,T+1)=ycall(k,T+1)+yput(k,T+1);
end

% delta and B stand for the number of stock shares and cash position
% respectively in the replicating portfolio

delta=zeros(T,T);
B=zeros(T,T);

% exdate matrix stands for the early exercise nodes (1 means early exercise, 0 not)
exdate = zeros(T,T);

for j=T:-1:1
    for i=1:j
        price(i,j)=max(ycall(i,j)+yput(i,j),exp(-r*h)*(p*price(i,j+1)+q*price(i+1,j+1)));
        if ycall(i,j)+yput(i,j)>exp(-r*h)*(p*price(i,j+1)+q*price(i+1,j+1))
            exdate(i,j)=1;  
        end
        delta(i,j)=(price(i,j+1)-price(i+1,j+1))/(2*s(i,j)*(u-d));
        B(i,j)=price(i,j)-delta(i,j)*(2*s(i,j));
    end
end

end