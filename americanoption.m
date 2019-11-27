function [price,delta,B,exdate] = americanoption(s0,r,div,divdates,u,d,h,T,K,type)

% p stands for the risk neutral probability of stock price going up
p=(exp(r*h)-d)/(u-d);
q=1-p;

s=zeros(T+1,T+1);
s(1,1)=s0;
ndates=length(divdates);
% y(i,j) stands for the payoff at node(i,j)
y=zeros(T+1,T+1);
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
        if type=="call"
            y(i,j)=max(s(i,j)-K,0);
        elseif type=="put"
            y(i,j)=max(K-s(i,j),0);
        end
    end    
end

% price(j,i) stands for the option value at node(j,i)
price=zeros(T+1,T+1);
for k=1:T+1
    price(k,T+1)=y(k,T+1);
end

% delta and B stand for the number of stock shares and cash position
% respectively in the replicating portfolio

delta=zeros(T,T);
B=zeros(T,T);

% exdate matrix stands for the early exercise nodes (1 means early exercise, 0 not)
exdate = zeros(T,T);

for j=T:-1:1
    for i=1:j
        price(i,j)=max(y(i,j),exp(-r*h)*(p*price(i,j+1)+q*price(i+1,j+1)));
        if y(i,j)>exp(-r*h)*(p*price(i,j+1)+q*price(i+1,j+1))
            exdate(i,j)=1;  
        end
        delta(i,j)=(price(i,j+1)-price(i+1,j+1))/(s(i,j)*(u-d));
        B(i,j)=price(i,j)-delta(i,j)*s(i,j);
    end
end

end