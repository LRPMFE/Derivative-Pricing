function [u,d] = stockchange(r,sigma,h)

u=exp(r*h+sigma*sqrt(h));
d=exp(r*h-sigma*sqrt(h));

end
