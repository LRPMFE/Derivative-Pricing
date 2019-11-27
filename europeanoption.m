function [price,delta,B] = europeanoption(s0,r,div,divdates,u,d,h,T,K,type)

% p stands for the risk neutral probability of stock price going up
p=(exp(r*h)-d)/(u-d);
q=1-p;

s=zeros(T+1,T+1);
s(1,1)=s0;
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
    end    
end

% price stands for the option value
price=zeros(T+1,T+1);
for k=1:T+1
    if type=="call"
        price(k,T+1)=max(s(k,T+1)-K,0);
    elseif type=="put"
        price(k,T+1)=max(K-s(k,T+1),0);
    end
end

% delta and B stand for the number of stock shares and cash position
% respectively in the replicating portfolio

delta=zeros(T,T);
B=zeros(T,T);

for j=T:-1:1
    for i=1:j
        price(i,j)=exp(-r*h)*(p*price(i,j+1)+q*price(i+1,j+1));
        delta(i,j)=(price(i,j+1)-price(i+1,j+1))/(s(i,j)*(u-d));
        B(i,j)=price(i,j)-delta(i,j)*s(i,j);
    end
end

end