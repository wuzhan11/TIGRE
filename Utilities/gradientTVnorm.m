function [ tvgrad ] = gradientTVnorm(f,type)
%GRADIENTTVNORM Computes the gradient of the TV-norm fucntional
if strcmp(type,'central')
    warning('It seems that central does not give correct results. Please consider using back or forward')
    tvgrad= gradientTVnormCentral(f);
    return;
end
if strcmp(type,'back')
    tvgrad= gradientTVnormBackward(f);
    return;
end
if strcmp(type,'forward')
    tvgrad= gradientTVnormForward(f);
    return;
end
error('Undefined type of gradient. Check spelling');
end
%% Backward differences
function tvg=gradientTVnormBackward(f)
Gx=diff(f,1,1);
Gy=diff(f,1,2);
Gz=diff(f,1,3);
tvg=zeros(size(f));
clear f
% these are not defined, but we will define them just for indexing
% readability. They shoudl never be used.
Gx=cat(1,Gx(1,:,:),Gx);
Gy=cat(2,Gy(:,1,:),Gy);
Gz=cat(3,Gz(:,:,1),Gz);

nrm=safenorm(Gx,Gy,Gz); 

tvg(2:end,2:end,2:end)= tvg(2:end,2:end,2:end)+(Gx(2:end,2:end,2:end)+Gy(2:end,2:end,2:end)+Gz(2:end,2:end,2:end))./nrm(2:end,2:end,2:end);
tvg(2:end-1,:,:)=tvg(2:end-1,:,:)-Gx([2:end-1]+1,:,:)./nrm([2:end-1]+1,:,:);
tvg(:,2:end-1,:)=tvg(:,2:end-1,:)-Gy(:,[2:end-1]+1,:)./nrm(:,[2:end-1]+1,:);
tvg(:,:,2:end-1)=tvg(:,:,2:end-1)-Gz(:,:,[2:end-1]+1)./nrm(:,:,[2:end-1]+1);

end
%% Forward differences
function tvg=gradientTVnormForward(f)
Gx=diff(f,1,1);
Gy=diff(f,1,2);
Gz=diff(f,1,3);
tvg=zeros(size(f));
clear f
% these are not defined, but we will define them just for indexing
% readability. They shoudl never be used.
Gx=cat(1,Gx,Gx(end,:,:));
Gy=cat(2,Gy,Gy(:,end,:));
Gz=cat(3,Gz,Gz(:,:,end));
nrm=safenorm(Gx,Gy,Gz); 
tvg(1:end-1,1:end-1,1:end-1)=tvg(1:end-1,1:end-1,1:end-1)-(Gx(1:end-1,1:end-1,1:end-1)+Gy(1:end-1,1:end-1,1:end-1)+Gz(1:end-1,1:end-1,1:end-1))./nrm(1:end-1,1:end-1,1:end-1);
tvg(2:end-1,:,:)=tvg(2:end-1,:,:)+Gx([2:end-1]-1,:,:)./nrm([2:end-1]-1,:,:);
tvg(:,2:end-1,:)=tvg(:,2:end-1,:)+Gy(:,[2:end-1]-1,:)./nrm(:,[2:end-1]-1,:);
tvg(:,:,2:end-1)=tvg(:,:,2:end-1)+Gz(:,:,[2:end-1]-1)./nrm(:,:,[2:end-1]-1);
end
%% Central differences
% Doesnt accound for edges of the image!!!
% https://math.stackexchange.com/questions/1612017/gradient-of-the-tv-norm-of-an-image
function tvg=gradientTVnormCentral(f)
[Gx,Gy,Gz]=gradient(f);
tvg=zeros(size(Gx));
nrm=safenorm(Gx,Gy,Gz);
tvg(2:end,:,:)   = tvg(2:end,:,:)   + Gx(1:end-1,:,:)./nrm(1:end-1,:,:);
tvg(1:end-1,:,:) = tvg(1:end-1,:,:) - Gx(2:end,:,:)  ./nrm(2:end,:,:);
tvg(:,2:end,:)   = tvg(:,2:end,:)   + Gy(:,1:end-1,:)./nrm(:,1:end-1,:);
tvg(:,1:end-1,:) = tvg(:,1:end-1,:) - Gy(:,2:end,:)  ./nrm(:,2:end,:);
tvg(:,:,2:end)   = tvg(:,:,2:end)   + Gz(:,:,1:end-1)./nrm(:,:,1:end-1);
tvg(:,:,1:end-1) = tvg(:,:,1:end-1) - Gz(:,:,2:end)  ./nrm(:,:,2:end);
tvg = tvg/2;
end

%% Utils
function nrm=safenorm(Gx,Gy,Gz)

nrm=sqrt(Gx.^2+Gy.^2+Gz.^2);
nrm(nrm==0)=1;

end