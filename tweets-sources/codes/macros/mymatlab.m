% create gifs
% Use znum2str() for consistent numbering
AutoCrop(rep, 'interp-'); %=  to crop the image generated using saveas
% > convert interp-*.png interp.gif % generate the gif using imagemagik
% > convert -delay 1x3 interp-*.png interp.gif % 3x slower

% create save repertory
addpath('../toolbox/');
rep = MkResRep();
% OLD
rep = '../results/soft-max/';
[~,~] = mkdir(rep);

saveas(gcf, [rep name num2str(it) '.png'], 'png');
imwrite(rescale(f), [rep name num2str(it) '.png']);

% rescale, quantized
Quant = @(x,q)min(floor( rescale(x)*q  ), q-1);
rescale = @(x)(x-min(x(:)))/(max(x(:))-min(x(:)));

% display
SetAR = @(ar)set(gca, 'PlotBoxAspectRatio', [1 ar 1], 'FontSize', 20);
set(gca, 'XTick', [], 'YTick', []);

% matrix
Xm = @(X)X-repmat(mean(X,1), [size(X,1) 1]);
Cov = @(X)Xm(X)'*Xm(X);
dotp = @(x,y)sum(x(:).*y(:));
rescale = @(x)(x-min(x(:)))/(max(x(:))-min(x(:)));

% figure docked by default
set(0,'DefaultFigureWindowStyle','docked')
% figure naming
figure('NumberTitle', 'off', 'Name', 'toto')

% stabilized log-sum-exp and soft max
max2 = @(S)repmat(max(S,[],2), [1 size(S,2)]);
LSE = @(S)log( sum(exp(S), 2) );
LSE = @(S)LSE( S-max2(S) ) + max(S,[],2);
SM = @(S)exp(S) ./ repmat( sum(exp(S),2), [1 size(S,2)]);
SM = @(S)SM(S-max2(S));

% click selection
it = 0;
clf; hold on;
while true
    axis([0 1 0 1]);
    [a,b,button] = ginput(1);
    plot(a,b, '.', 'MarkerSize', 15);
    if button==3
        break;
    end
    Z(end+1) = a+1i*b;
end

% display quantized colormap
r = 15; % #levellines
clf; hold on;
imagesc(t,t,R');
contour(t,t,R',linspace(0,1,r), 'k');
colormap(parula(r-1));
caxis([0 1]);
axis image; axis off;

% gaussian blur
t = [0:n/2,-n/2+1:-1]';
normalize = @(x)x/sum(x(:));
G = @(s)normalize(exp(-t.^2/(2*s^2))); G = @(s)G(s)*G(s)';
fconv = @(x,y)real( ifft2( fft2(x).*fft2(y) ) );
GFilt = @(f,s)fconv(f, G(s));

% smooth a bit an image
sm = @(f)( f + f([2:end 1],:) + f([end 1:end-1],:) + f(:,[2:end 1]) + f(:,[end 1:end-1]) )/5;
for k=1:4
    psi0 = sm(psi0);
end

% piecewise constant upsampling
S = @(k,p)floor(1:1/k:p+1-1/k);
Upsc = @(x,k)x(S(k,size(x,1)),S(k,size(x,2)));

% Point cloud in color
s = ones(N,1)*10; % size
clf; scatter3( c(:,1), c(:,2), c(:,3),s, c, 'filled' );

% histogram equalization
[fS,I] = sort(f(:)); f(I) = linspace(0,1,length(f(:)));

% display bar diagram with colorr
clf;
bar(fd, 'EdgeColor', [t 0 1-t], 'FaceColor', [t 0 1-t]);
axis([.5 m+.5 0 vmax*1.05]);


% display colors isosurface F, levelset T, color R
clf;
p = patch( isosurface( x,x,x,F, T ) );
isonormals( x,x,x,F,p );
isocolors(x,x,x,R(:,:,:,1),R(:,:,:,2),R(:,:,:,3),p);
p.FaceColor = 'interp';
p.EdgeColor = 'none';
box on; axis on; set(gca, 'XTick', [], 'YTick', [], 'ZTick', []);
axis equal; axis([0 1 0 1 0 1]);
lighting gouraud;
view(3);
camlight; drawnow;

% extract a level set as a planar curve
[C,h] = contour(I,[.5,.5]);
m = C(2,1);  c = C(:,2:m+1); c = c(1,:)'+1i*c(2,:)';

% colormap interpolating between two colors (here a color and white)
m = linspace(0,1,r+1)';
CM = m*[s 0 1-s] + (1-m)*[1 1 1];

% display an image using a masking region
imAlpha = ones(n); imAlpha(F>vmax) = 0; % Generate the mask
imagesc(t,t,F', 'AlphaData', imAlpha);

% store images at a fixed rate
q = 70; %#display frames
ndisp = round(linspace(1,niter,q)); k = 1;
for i=1:niter
    if i==ndisp(k)
        % ...
        k = k+1;
    end
    % ...
end
