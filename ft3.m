% function a = ft3(a)

function a = ft3(a)

for k=1:3
  a = fftshift(fft(fftshift(a,k),[],k),k);
end;

