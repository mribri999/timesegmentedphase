
function a = ft3(a)

for k=1:3
  a = ifftshift(ifft(ifftshift(a,k),[],k),k);
end;

