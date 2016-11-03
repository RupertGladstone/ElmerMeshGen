
function [arr_out] = extendArray(arr_in)

[nx,ny] = size(arr_in);

%imagesc(arr_in)

%arr_in_dummy = zeros(size(arr_in));
%arr_in_dummy(:,:) = nan;

numNans_last = 0; % set these just to start while loop...
numNans      = 1;

count = 0;
%while numNans_last ~= numNans
for nn=1:200
  count = count + 1
  numNans_last = numNans;
  arr_in_dummy(:,:) = arr_in;
  for x = 2:nx-1
    for y = 2:ny-1
      if (isnan(arr_in(x,y)))
	patch = arr_in(x-1:x+1,y-1:y+1);
	numNonNans = numel(patch(not(isnan(patch))));
	if numNonNans > 0
	  arr_in_dummy(x,y) = mean(patch(not(isnan(patch))));
	end
      end
    end
  end
  arr_in = arr_in_dummy;
  numNans = numel(arr_in(isnan(arr_in)));
  %  count,numNans_last,numNans
end
arr_in(isnan(arr_in))=0.0000;
arr_out = arr_in;

return